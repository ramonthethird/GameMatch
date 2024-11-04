import 'package:flutter/material.dart';

class SettingsPrivacyPage extends StatelessWidget {
  const SettingsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        backgroundColor: Color(0xFF41B1F1),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to Game Match! Your privacy is important to us. This Privacy Policy explains how we collect, use, and share your information when you use our mobile application ("GameMatch").',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                '1. Information We Collect',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We collect information in the following ways:\n'
                '\t- **Personal Information**: This includes your username, email address, and any other information you provide when creating an account.\n'
                '\t- **Usage Information**: We collect information about how you interact with the App, such as your swipes, game likes, and the time spent using different features.\n'
                '\t- **Device Information**: We collect data about the device you use to access the App, including your IP address, operating system, and device model.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '2. How We Use Your Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We use the information we collect to:\n'
                '\t- Provide and improve our services.\n'
                '\t- Personalize your experience and recommend games based on your preferences.\n'
                '\t- Communicate with you about your account, updates, and promotional offers.\n'
                '\t- Monitor and analyze usage trends to enhance the App’s features and user experience.\n'
                '\t- Ensure the security of the App and protect against fraudulent activities.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '3. Sharing Your Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We do not sell or rent your personal information to third parties. However, we may share your information with:\n'
                '\t- **Service Providers**: We may share your information with third-party service providers who assist us in operating the App, such as hosting providers and analytics services.\n'
                '\t- **Legal Obligations**: We may disclose your information if required by law or to comply with legal processes, enforce our terms, or protect the rights and safety of our users.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '4. Data Security',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We implement appropriate technical and organizational measures to protect your information from unauthorized access, alteration, disclosure, or destruction. However, please note that no method of transmission over the Internet or electronic storage is completely secure, and we cannot guarantee absolute security.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '5. Your Rights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Depending on your location, you may have the right to:\n'
                '\t- Access and update your personal information.\n'
                '\t- Request the deletion of your personal data.\n'
                '\t- Opt out of marketing communications.\n'
                '\t- Object to or restrict certain processing activities related to your data.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '6. Changes to This Policy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We may update this Privacy Policy from time to time to reflect changes in our practices or legal requirements. We will notify you of any material changes by posting the updated policy in the App or through other communication channels. We encourage you to review this policy periodically for the latest information.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
