import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Side_bar.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

class PremiumSubscriptionPage extends StatefulWidget {
  const PremiumSubscriptionPage({super.key});

  @override
  _PremiumSubscriptionPageState createState() => _PremiumSubscriptionPageState();
}

class _PremiumSubscriptionPageState extends State<PremiumSubscriptionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String remainingDays = "";

  @override
  void initState() {
    super.initState();
    _fetchRemainingDays();
  }

  // Fetch the subscription expiration date from Firestore and calculate remaining days
  Future<void> _fetchRemainingDays() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          var expirationData = userDoc['subscriptionExpirationDate'];

          DateTime expirationDate;
          if (expirationData is Timestamp) {
            expirationDate = expirationData.toDate();
          } else if (expirationData is String) {
            expirationDate = DateTime.parse(expirationData);
          } else {
            setState(() {
              remainingDays = "Invalid expiration date format.";
            });
            return;
          }

          DateTime today = DateTime.now();
          int daysLeft = expirationDate.difference(today).inDays;

          setState(() {
            remainingDays = daysLeft > 0
                ? "$daysLeft days left until renewal"
                : "Your subscription has expired.";
          });
        } else {
          setState(() {
            remainingDays = "No subscription information available.";
          });
        }
      } catch (e) {
        setState(() {
          remainingDays = "Error fetching subscription details: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Manage Subscription',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF41B1F1),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/images/premium-sub.png', // Ensure this path is correct
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Placeholder(
                  fallbackHeight: 200,
                  fallbackWidth: double.infinity,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Subscription Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              remainingDays,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Non-clickable "Manage Subscription" button
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0), // Light gray background color
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
                'Manage Subscription',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Update billing information'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Billing_info');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF41B1F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel Subscription'),
              trailing: ElevatedButton(
                onPressed: _showCancelConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF41B1F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Change Plan'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Premium Benefits',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const ListTile(
              leading: Icon(Icons.block, color: Color(0xFF41B1F1)),
              title: Text('Ad-free Experience'),
            ),
            const ListTile(
              leading: Icon(Icons.discount, color: Color(0xFF41B1F1)),
              title: Text('Exclusive Discount'),
              subtitle: Text('New'),
            ),
            const ListTile(
              leading: Icon(Icons.star, color: Color(0xFF41B1F1)),
              title: Text('Custom Access'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/Terms");
              },
              child: const Text('Terms and Conditions'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/Privacy");
              },
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show a confirmation dialog for cancelling subscription
  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Subscription'),
          content: Text(
            'Are you sure you want to cancel your subscription?\n\n$remainingDays',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription cancelled successfully.'),
                    backgroundColor: Color(0xFF41B1F1),
                  ),
                );
              },
              child: const Text('Yes', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
