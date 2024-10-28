import 'package:flutter/material.dart';

class AdPageTemplate extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;
  final String? learnButtonText;
  final String closeButtonText;
  final VoidCallback? onLearnPressed;
  final VoidCallback onClosePressed;

  const AdPageTemplate({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.description,
    this.learnButtonText,
    required this.closeButtonText,
    this.onLearnPressed,
    required this.onClosePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 250,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            if (learnButtonText != null && onLearnPressed != null)
              ElevatedButton(
                onPressed: onLearnPressed,
                child: Text(learnButtonText!),
              ),
            ElevatedButton(
              onPressed: onClosePressed,
              child: Text(closeButtonText),
            ),
          ],
        ),
      ),
    );
  }
}
