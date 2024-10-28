//Subscription_check_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SubscriptionPremium.dart'; // Update the import with your actual file path

class SubscriptionCheckScreen extends StatefulWidget {
  const SubscriptionCheckScreen({super.key});

  @override
  _SubscriptionCheckScreenState createState() => _SubscriptionCheckScreenState();
}

class _SubscriptionCheckScreenState extends State<SubscriptionCheckScreen> {
  String? subscriptionStatus;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        setState(() {
          subscriptionStatus = userDoc['subscription'];
        });

        if (subscriptionStatus == 'paid') {
          Navigator.pushReplacementNamed(context, '/Subscription');
        } else {
          Navigator.pushReplacementNamed(context, '/Sign_up');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
