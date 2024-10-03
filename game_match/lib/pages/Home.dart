import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameMatch Home'), // Title in the AppBar
      ),
      body: Center(
        child: const Text(
          'Welcome to GameMatch!', // Welcome message
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
