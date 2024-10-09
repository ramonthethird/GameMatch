import 'dart:convert'; // For JSON encoding and decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OAuth Test'),
        ),
        body: const Center(
          child: OAuthTestButton(),
        ),
      ),
    );
  }
}

class OAuthTestButton extends StatefulWidget {
  const OAuthTestButton({super.key});

  @override
  _OAuthTestButtonState createState() => _OAuthTestButtonState();
}

class _OAuthTestButtonState extends State<OAuthTestButton> {
  String _accessToken = '';
  String _errorMessage = '';

  Future<void> getAccessToken() async {
    const String clientId = 'v5v1uyyo05m4ttc8yvd26yrwslfimc';
    const String clientSecret = 'hu3w4pwpc344uwdp2k77xfjozbaxc5';
    final Uri url = Uri.parse('https://id.twitch.tv/oauth2/token');
    final Map<String, String> body = {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'client_credentials',
    };

    try {
      // Sending the POST request
      final http.Response response = await http.post(url, body: body);

      // Print the raw response body to check its content
      print('Response Body: ${response.body}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        // Checking if the response is a JSON type
        if (response.headers['content-type'] != null &&
            response.headers['content-type']!.contains('application/json')) {
          // Try to decode the JSON
          final Map<String, dynamic> responseData = json.decode(response.body);
          setState(() {
            _accessToken = responseData['access_token'];
            _errorMessage = ''; // Clear any previous error messages
          });
          print('Access Token: $_accessToken');
        } else {
          // Handle cases where the response isn't JSON
          setState(() {
            _errorMessage =
                'Unexpected content type: ${response.headers['content-type']}';
          });
          print('Unexpected content type: ${response.headers['content-type']}');
        }
      } else {
        // Handle any non-200 status codes
        setState(() {
          _errorMessage = 'Failed to get access token: ${response.statusCode}';
        });
        print('Failed to get access token: ${response.statusCode}');
      }
    } catch (error) {
      // Catch any decoding or network-related errors
      setState(() {
        _errorMessage = 'Error: $error';
      });
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: getAccessToken,
          child: const Text('Get Access Token'),
        ),
        const SizedBox(height: 20),
        Text(_accessToken.isEmpty ? 'No Token' : 'Access Token: $_accessToken'),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
