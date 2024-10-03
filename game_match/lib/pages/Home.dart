import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameMatch Home'), // Title in the AppBar
      ),
      body: const Center(
        child: Text(
          'Welcome to GameMatch!', // Welcome message
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
