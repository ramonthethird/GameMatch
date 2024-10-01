
## GameMatch
GameMatch is an app that recommends games to users based on their preferences. Users can input their gaming preferences, and through the help of AI, the app searches through a list of games and matches them accordingly. The app uses various APIs to gather game information, considering platform, price, and genre.

## Getting Started
These instructions will help you set up the project locally for development and testing purposes. See the deployment section for notes on deploying the project in a live environment.

## Prerequisites
To get started, ensure you have the following installed:

- Flutter (version ....)
- Dart
- Android Studio with the Android emulator
- An API key for accessing game data from the RAWG API or a similar game database
- Git for version control
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
## APIs and Configuration
- The app uses the following APIs to fetch game data:

- SteamDB- Provides information on game genres, platforms, pricing, and more.
- 
- 
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
- Android Studio - Development environment
- SteamDB API - Game data API
## Contributing
Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## Versioning
We use Semantic Versioning for versioning. For the versions available, see the tags on this repository.

## Authors
- Ramon Quintana
- Marc Lim
- Paul Ortiz
- Jacob Phillips
- Abrham Tamiru
- Ella Pitre
 
## License
This project is licensed under the CC0 1.0 Universal Creative Commons License - see the LICENSE.md file for details.

## Acknowledgments
- Inspiration from similar game recommendation apps
- Special thanks to the open-source Flutter and Dart communities
=======
# GameMatch
An app that recommends users to different games based on preferences. 

We want to create an app that allows users to input their gaming preferences and from this input recommmend games that follow their input.  Through the help of AI we will try to search through a list of games and match users to them.  The user swipes through the suggestions and is given information on each game to further assist in their decision.  The user swipes one direction if they like it and the opposite if they do not find it interesting.
