import 'package:flutter/material.dart';

class SettingsTermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use', style: TextStyle(color: Colors.black, fontSize: 24)),
        backgroundColor: const Color(0xFF74ACD5),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to Settings Page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms of Use',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                ,
              ),
              SizedBox(height: 16),
              Text(
                'Here are the terms of use for the app...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '1. You agree to follow these rules...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '2. You are responsible for your actions...',
                style: TextStyle(fontSize: 16),
              ),
              // Add terms here
            ],
          ),
        ),
      ),
    );
  }
}
