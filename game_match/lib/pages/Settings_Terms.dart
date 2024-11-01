import 'package:flutter/material.dart';

class SettingsTermsPage extends StatelessWidget {
  const SettingsTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Use',
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
                'Terms of Use',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to Game Match! By accessing or using our mobile application and related services, you agree to be bound by the following terms and conditions. If you do not agree to these terms, please do not use the application.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                '1. Acceptance of Terms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'By downloading, installing, or using Game Match (referred to as "the App"), you acknowledge that you have read, understood, and agree to be bound by these Terms of Use and our Privacy Policy.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '2. User Accounts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You must create an account to access certain features of the App. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You must provide accurate and complete information when creating an account. Providing false information is a violation of these Terms.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '3. User Conduct',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You agree not to use the App for any illegal or unauthorized purpose. You must not, in the use of the App, violate any laws in your jurisdiction (including but not limited to copyright laws). You must not interfere with or disrupt the App’s servers, networks, or security features.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '4. Intellectual Property',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'The App and its original content, features, and functionality are and will remain the exclusive property of Game Match and its licensors. The App is protected by copyright, trademark, and other laws of [Insert Country]. You may not copy, modify, distribute, or reverse-engineer any part of the App without our prior written consent.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '5. User-Generated Content',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You may post reviews, ratings, and other content on the App ("User Content"). You retain ownership of your User Content, but by posting it, you grant Game Match a worldwide, non-exclusive, royalty-free license to use, reproduce, distribute, and display the User Content in connection with the App. You agree not to post any content that is illegal, defamatory, obscene, or otherwise harmful.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '6. In-App Purchases',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Game Match may offer in-app purchases for certain features or content. All in-app purchases are final and non-refundable, except as required by law. You are responsible for managing your purchase settings and understanding the charges that may apply.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '7. Privacy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              // Add more terms here if needed
            ],
          ),
        ),
      ),
    );
  }
}
