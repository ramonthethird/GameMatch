import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'billing_info.dart';
import 'Sign_up.dart';
import 'Side_bar.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

class SubscriptionManagementScreen extends StatelessWidget {
  SubscriptionManagementScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Subscription Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16, // Text size set to 24
          ),
        ),
        backgroundColor: const Color(0xFF41B1F1), // AppBar background color
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            themeNotifier.toggleTheme(isDarkMode);
          },
          isDarkMode: themeNotifier.isDarkMode,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTileTheme(
                selectedColor: Color(0xFF41B1F1),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Free Member'),
                  trailing: Radio(
                    value: 'free',
                    groupValue: 'free',
                    onChanged: (_) {},
                    activeColor: Color(0xFF41B1F1),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text('Premium Member'),
              ),
              const SizedBox(height: 20),
              const Text('Subscription Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Plan Name'),
                subtitle: const Text('Free'),
              ),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Billing Status'),
                subtitle: const Text('Not Active'),
              ),
              const SizedBox(height: 20),
              const Text('Why Upgrade?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Access exclusive content and discounts'),
              ),
              const ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Ad-free experience'),
              ),
              const ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Priority customer support'),
              ),
              const SizedBox(height: 20), // Add spacing before the bottom card
              Card(
                elevation: 2,
                child: ListTile(
                  title: const Text('Monthly Plan'),
                  subtitle: const Text('\$5'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Billing_info');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF41B1F1),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Upgrade'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}