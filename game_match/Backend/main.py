import json
import logging
import threading
import firebase_admin
import keyring  # Securely store/retrieve credentials
#import pandas as pd
import requests
from firebase_admin import credentials, firestore, storage
from flask import Flask, jsonify
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from apscheduler.schedulers.background import BackgroundScheduler

# Initialize Firebase
cred = credentials.Certificate('c:/Users/abale/Recommand/firebase_credentials.json') # Path to your Firebase service account key
firebase_admin.initialize_app(cred,{
    'storageBucket': 'gamematch-e492c.appspot.com'
})

# Initialize Firestore DB
db = firestore.client()
app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.DEBUG)

# Game model
class Game:
    # Initialize game object
    def __init__(self, id, name, summary, genres, coverUrl, websiteUrl, platforms, releaseDates, price, screenshotUrls,gameModes,playerPerspectives,rating):
        self.id = id
        self.name = name
        self.summary = summary
        self.genres = genres
        self.coverUrl = coverUrl
        self.websiteUrl = websiteUrl
        self.platforms = platforms
        self.releaseDates = releaseDates
        self.rating = rating
        self.isFree = price == 0.0
        self.screenshotUrls = screenshotUrls
        self.gameModes = gameModes
        self.playerPerspectives = playerPerspectives

    @staticmethod
    def from_json(json_data):
        screenshotUrls = [
            f"https://images.igdb.com/igdb/image/upload/t_720p/{s['image_id']}.jpg"
            for s in json_data.get('screenshots', [])
        ]
        coverUrl = f"https://images.igdb.com/igdb/image/upload/t_720p/{json_data['cover']['image_id']}.jpg" if json_data.get('cover') else None
        genres = [genre['name'] for genre in json_data.get('genres', [])]
        
        # Use get() to avoid KeyError for missing 'platforms' key
        platforms = [platform.get('name', 'Unknown') for platform in json_data.get('platforms', [])] if 'platforms' in json_data else []

        releaseDates = [date['human'] for date in json_data.get('release_dates', [])]
        websiteUrl = json_data.get('websites', [{}])[0].get('url')
        gameModes = [mode['name'] for mode in json_data.get('game_modes', [])]
        playerPerspectives = [perspective['name'] for perspective in json_data.get('player_perspectives', [])]
        rating = json_data.get('rating', 0.0)
        return Game(
            id=json_data.get('id', 'Unknown'),
            name=json_data.get('name', 'No title'),
            summary=json_data.get('summary', 'No description available'),
            genres=genres,
            coverUrl=coverUrl,
            websiteUrl=websiteUrl,
            platforms=platforms,
            releaseDates=releaseDates,
            rating=rating,
            price=0.0,  
            screenshotUrls=screenshotUrls,
            gameModes=gameModes,
            playerPerspectives=playerPerspectives

        )
    # Convert game object to dictionary
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'summary': self.summary,
            'genres': self.genres,
            'coverUrl': self.coverUrl,
            'websiteUrl': self.websiteUrl,
            'platforms': self.platforms,
            'releaseDates': self.releaseDates,
            'rating': self.rating,
            'isFree': self.isFree,
            'screenshotUrls': self.screenshotUrls,
            'gameModes': self.gameModes,
            'playerPerspectives': self.playerPerspectives
        }

# Load Game Data from API
def load_game_data():
    access_token = get_access_token()
    if not access_token:
        logging.error("Access token not available")
        return []

    headers = {
        'Client-ID': 'v5v1uyyo05m4ttc8yvd26yrwslfimc',
        'Authorization': f'Bearer {access_token}'
    }

    response = requests.post(
        'https://api.igdb.com/v4/games',
        headers=headers,
        data="fields id, name, genres.name, platforms.name, game_modes.name, player_perspectives.name, summary, cover.image_id, websites.url, release_dates.human, screenshots.image_id, involved_companies.company.name, rating;"
             "where cover != null & summary != null & genres != null & platforms != null & release_dates != null & websites != null & screenshots != null & rating != null;"
             "limit 400;"
    )
    # Check if response is successful
    if response.status_code == 200:
        games_json = response.json()
        logging.debug(f"Fetched games: {games_json}")
        # Filter out games with missing genres or summary
        games = [
            Game.from_json(game) for game in games_json
            if game.get('genres') and game.get('summary')
        ]
        return games
    else:
        logging.error(f"Error fetching games: {response.status_code} {response.text}")
        if response.status_code == 401:
            logging.warning("Access token might be expired; attempting to re-authenticate.")
            authenticate()  # Try to refresh the token
        return []
# Retrieve access token from keyring
def get_access_token():
    token = retrieve_access_token()
    if not token:
        authenticate()
        token = retrieve_access_token()
    return token
# Store access token in keyring
def store_access_token(token):
    keyring.set_password('game_match', 'access_token', token)
# Retrieve access token from keyring
def retrieve_access_token():
    return keyring.get_password('game_match', 'access_token')
# Authenticate with Twitch API
def authenticate():
    url = 'https://id.twitch.tv/oauth2/token'
    body = {
        'client_id': 'v5v1uyyo05m4ttc8yvd26yrwslfimc',
        'client_secret': 'hu3w4pwpc344uwdp2k77xfjozbaxc5',
        'grant_type': 'client_credentials',
    }
    response = requests.post(url, headers={'Content-Type': 'application/x-www-form-urlencoded'}, data=body)

    if response.status_code == 200:
        token_data = response.json()
        store_access_token(token_data['access_token'])
    else:
        logging.error(f'Failed to fetch token: {response.status_code} {response.text}')
# Store game data in Firestore
def user_preferences(user_id):
    """Retrieve and format user preferences from Firestore."""
    user_doc = db.collection('users').document(user_id).get()

    if not user_doc.exists:
        logging.error(f"User {user_id} not found")
        return None

    user_data = user_doc.to_dict()
    logging.debug(f"User data for user_id {user_id}: {user_data}")

    # Use get with default values to avoid KeyErrors
    user_preferences = {
        'rating': user_data.get('interests', {}).get('rating', 0.0),  # Defaults to 0.0 if missing"),
        'selectedGenres': [genre.lower() for genre in user_data.get('selectedGenres', [])],
        'platform': user_data.get('interests', {}).get('platform', ""),  # Defaults to empty string if missing
        'gameMode': user_data.get('interests', {}).get('gameMode', ""),  # Defaults to empty string if missing
        'playerPerspective': user_data.get('interests', {}).get('playerPerspective', ""),  # Defaults to empty string if missing
        'likedGames': user_data.get('wishlist', []), # Defaults to empty list if missing
    }

    logging.debug(f"User preferences for user_id {user_id}: {user_preferences}")
    return user_preferences

def get_reviews_data():
    # Initialize an empty list to store retrieved reviews
    reviews_data = []
    try:
        # Retrieve all documents from the 'reviews' collection in Firebase
        reviews_collection = db.collection('reviews').stream()
        for review in reviews_collection:
            # Convert the document to a dictionary
            review_data = review.to_dict()
            # Add the document ID if needed
            review_data['id'] = review.id
            reviews_data.append(review_data)
    except Exception as e:
        print(f"Error fetching reviews data: {e}")
        reviews_data = []
    return reviews_data

# Enhanced filtering logic with additional debugging
def content_based_recommendation(user_preferences, games, reviews_data):
    # Set weightings for each preference type
    GENRE_WEIGHT = 1.0      
    PLATFORM_WEIGHT = 1.0    
    GAMEMODE_WEIGHT = 1.0   
    RATING_WEIGHT = 1.0  


    # Secondary weights
    SUMMARY_WEIGHT = 0.3
    LIKED_GAMES_WEIGHT = 0.3
    REVIEW_WEIGHT = 0.5
    PLAYERPERSPECTIVE_WEIGHT = 0.2  # Reduced from 0.5 as it's less critical

    # Extract user preferences
    preferred_genres = [genre.lower() for genre in user_preferences.get('selectedGenres', [])]
    preferred_platform = user_preferences.get('platform', "").lower()
    preferred_gamemode = user_preferences.get('gameMode', "").lower()

    liked_games_ids = [game['id'] for game in user_preferences.get('likedGames', [])]

    # Filter games based on MUST-HAVE criteria first
    filtered_games = []
    for game in games:
        # Critical criteria - all must match if specified
        genre_match = any(genre in [g.lower() for g in game.genres] for genre in preferred_genres) if preferred_genres else True
        platform_match = preferred_platform in [platform.lower() for platform in game.platforms] if preferred_platform else True
        gamemode_match = preferred_gamemode in [gameMode.lower() for gameMode in game.gameModes] if preferred_gamemode else True
        rating_match = game.rating >= user_preferences.get('rating', 0.0)
        # Only include games that match ALL critical criteria
        if genre_match and platform_match and gamemode_match and rating_match:
            filtered_games.append(game)

    if not filtered_games:
        logging.warning("No games matched critical criteria (genre, platform, gamemode).")
        return []

    # Process remaining games with TF-IDF for content similarity
    combined_texts = []
    for game in filtered_games:
        game_reviews = [review['body'] for review in reviews_data if review['gameId'] == game.id]
        combined_text = game.summary if game.summary else ""
        combined_text += " " + " ".join(game_reviews)
        combined_texts.append(combined_text)

    tfidf_vectorizer = TfidfVectorizer(stop_words='english')
    tfidf_matrix = tfidf_vectorizer.fit_transform(combined_texts)
    cosine_similarities = cosine_similarity(tfidf_matrix, tfidf_matrix)

    # Score remaining games that passed critical criteria
    scored_games = []
    for i, game in enumerate(filtered_games):
        # Primary criteria scores (these will always be maximum weight since we filtered for them)
        genre_score = GENRE_WEIGHT
        platform_score = PLATFORM_WEIGHT
        gamemode_score = GAMEMODE_WEIGHT
        
        # Secondary criteria scores
        rating_score = RATING_WEIGHT if game.rating >= user_preferences.get('rating', 0.0) else 0
        summary_score = SUMMARY_WEIGHT * cosine_similarities[i].sum()
        liked_games_score = LIKED_GAMES_WEIGHT if game.id in liked_games_ids else 0
        perspective_score = PLAYERPERSPECTIVE_WEIGHT if user_preferences.get('playerPerspective', "").lower() in [pp.lower() for pp in game.playerPerspectives] else 0

        # Review scoring
        game_reviews = [review for review in reviews_data if review['gameId'] == game.id]
        review_score = sum(REVIEW_WEIGHT * (review.get('likes', 0) + review.get('rating', 0)) for review in game_reviews) / len(game_reviews) if game_reviews else 0

        # Calculate total score with weighted components
        total_score = (genre_score + platform_score + gamemode_score +
                      rating_score + summary_score + liked_games_score +
                      perspective_score + review_score)
        
        scored_games.append((game, total_score))

    # Sort games by total score
    scored_games.sort(key=lambda x: x[1], reverse=True)

    # Return top 10 matches
    return [game.to_dict() for game, score in scored_games[:10]]

@app.route('/recommend/<user_id>', methods=['GET'])
# Fetch recommendations for a user
def recommend(user_id):
    logging.debug(f"Fetching recommendations for user_id: {user_id}")
    try:
        user_doc = db.collection('users').document(user_id).get()

        if not user_doc.exists:
            logging.error(f"User {user_id} not found")
            return jsonify({'error': 'User not found'}), 404

        user_preferences = user_doc.to_dict()
        games = load_game_data()

        if not games:
            logging.error("No game data available")
            return jsonify({'error': 'No game data available'}), 500

        reviews_data = get_reviews_data()
        recommendations = content_based_recommendation(user_preferences, games, reviews_data)

        # Update Firestore and Firebase Storage
        db.collection('users').document(user_id).update({'recommendedGames': recommendations})
        store_recommended_games(user_id, recommendations)

        logging.debug(f"Updated recommendations for user_id {user_id}: {recommendations}")
        return jsonify({'message': 'Recommendations updated successfully'}), 200
    except Exception as e:
        logging.error(f"Error fetching recommendations: {e}")
        return jsonify({'error': 'Internal server error'}), 500
# Listen to changes in user preferences
def listen_to_user_preferences():
    """Listen to changes in user preferences and trigger recommendation updates."""
    def on_snapshot(col_snapshot, changes, read_time):
        try:
            for change in changes:
                if change.type.name == 'MODIFIED':  # Preferences were updated
                    user_id = change.document.id
                    logging.info(f"Preferences updated for user {user_id}")
                    update_recommendations(user_id)  # Delegate to standalone function
        except Exception as e:
            logging.error(f"Error in Firestore snapshot listener: {e}")

    users_ref = db.collection('users')
    users_ref.on_snapshot(on_snapshot)
# Update recommendations for a user
def update_recommendations(user_id):
    """Update recommendations for the given user."""
    user_doc = db.collection('users').document(user_id).get()

    if not user_doc.exists:
        logging.error(f"User {user_id} not found")
        return

    user_preferences = user_doc.to_dict()
    games = load_game_data()
    reviews_data = get_reviews_data()
    recommendations = content_based_recommendation(user_preferences, games, reviews_data)

    # Update Firestore with new recommendations
    db.collection('users').document(user_id).update({
        'recommendedGames': recommendations
    })

    # Store recommended games in Firebase Storage
    store_recommended_games(user_id, recommendations)

    logging.info(f"Updated recommendations for user_id {user_id}")

# Start the listener in a separate thread to avoid blocking
listener_thread = threading.Thread(target=listen_to_user_preferences, daemon=True)
listener_thread.start()

# Store recommended games in Firebase Storage
def store_recommended_games(user_id, recommendations):
    try:
        bucket = storage.bucket()
        blob = bucket.blob(f'recommendations/{user_id}.json')
        blob.upload_from_string(json.dumps(recommendations), content_type='application/json')
        logging.debug(f"Stored recommendations for user_id {user_id} in Firebase Storage")
    except Exception as e:
        logging.error(f"Error storing recommendations for user_id {user_id}: {e}")

# Refresh recommendations for all users
def refresh_all_recommendations():
    """Refresh recommendations for all users."""
    users = db.collection('users').stream()
    for user in users:
        user_id = user.id
        update_recommendations(user_id)

# Set up a periodic task to refresh recommendations
scheduler = BackgroundScheduler()
scheduler.add_job(refresh_all_recommendations, 'interval', hours=6)  # Run every 6 hours
scheduler.start()


if __name__ == '__main__':
    app.run(debug=True)