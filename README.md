# **GameMatch**

**GameMatch** is a cutting-edge app that recommends games to users based on their preferences. Users can input details like platform, price, and genre preferences, and the app leverages AI to analyze game databases, providing personalized recommendations. It also integrates APIs to fetch the latest game news and comprehensive game details.

---

## **Getting Started**

Follow these instructions to set up the project locally for development and testing. Refer to the deployment section for notes on releasing the project to a live environment.

---

## **Prerequisites**

Ensure the following tools and services are installed and set up before you begin:

 **Frontend Prerequisites:**
- Flutter (latest version)
- Dart SDK
- Android Studio with the Android emulator
- A valid IGDB API key for game data
- Git for version control

 **Backend Prerequisites:**
- Python 3.10+
- Flask (Python framework)
- Firebase Admin SDK for Python
- A valid Firebase project (Firestore and Firebase Storage configured)

## Installing
A step-by-step guide to getting a development environment running:

- Clone the repository:

        git clone https://github.com/yourusername/gamematch.git
- Navigate to the project directory:

        cd gamematch
- Install dependencies:

        flutter pub get
Set up an Android emulator:

- Open Android Studio, go to the "AVD Manager" and create a new virtual device.
- Choose your preferred hardware profile and system image.
- Run the app on the emulator:
  
        flutter run
**Backend setup**
  - Navigate to the backend directory:

        cd gamematch/backend
  - Install dependencies:

        pip install -r requirements.txt  
  -  Set up environment variables for Firebase and API keys in a .env file:

            FIREBASE_ADMIN_CREDENTIALS=path_to_your_firebase_adminsdk.json  
            IGDB_CLIENT_ID=your_igdb_client_id  
            IGDB_CLIENT_SECRET=your_igdb_client_secret  
            NEWS_API_KEY=your_news_api_key
  -   Run the backend server:

            Flask run 


## APIs and Configuration
- The app uses the following APIs to fetch game data:

- igdb- Provides information on game genres, platforms, pricing, and more.
- newsapi - provide informations about game news
You will need to obtain an API key from the service and configure the app with it. Add your API key to the .env file (or as required by the API documentation) under the lib/config directory.

## Running Tests
To run automated tests for the system:

- Unit tests:

        flutter test
- Integration tests:

        flutter drive --target=test_driver/app.dart
- Sample Tests

Example of what is tested and why:

- Preference Matching Test: 
Tests that users are matched to games based on their selected preferences.

        test('Matches user preferences to games', () {
            // Test logic here
        });
Style Test
Ensure the code follows best practices and Dart's coding standards:

Run the Dart formatter to check for style issues:

        dart format --fix .
## Deployment
To deploy the app to a live system:

Build the APK for Android:

        flutter build apk --release
Deploy the APK to the Play Store or distribute directly to users.

Built With
- Flutter - Mobile app framework
- Dart - Programming language
- Python - Backend service
- Android Studio - Development environment
- igdb API - Game data API
- newsapi - game news APi
## Contributing
Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## Versioning
We use Semantic Versioning for versioning. For the versions available, see the tags on this repository.

## Authors
- [Ramon Quintana](https://github.com/ramonthethird)
- [Marc Lim](https://github.com/Marclimon45)
- [Paul Ortiz](https://github.com/paulortiz21)
- [Jacob Phillips](https://github.com/jxke66)
- [Abrham Tamiru](https://github.com/AbrhamTamiru)
- [Ella Pitre](https://github.com/peaktwins)
- 
## License
This project is licensed under the CC0 1.0 Universal Creative Commons License - see the LICENSE.md file for details.

## Acknowledgments
- Inspiration from similar game recommendation apps
- Special thanks to the open-source Flutter and Dart communities
