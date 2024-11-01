import 'package:flutter/material.dart';
import 'Side_bar.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

class PremiumSubscriptionPage extends StatefulWidget {
  const PremiumSubscriptionPage({super.key});

  @override
  _PremiumSubscriptionPageState createState() => _PremiumSubscriptionPageState();
}

class _PremiumSubscriptionPageState extends State<PremiumSubscriptionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for the scaffold

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
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change here
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
              'assets/images/premium-sub.png', // Update the path with your image
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Subscription Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for managing subscription
              },
              child: const Text('Manage Subscription'),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Update billing information'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Billing_info');
                },
                child: const Text('Open'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel Subscription'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Logic to change subscription plan
                },
                child: const Text('Change Plan'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save any changes made (if applicable)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Premium Benefits',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const ListTile(
              leading: Icon(Icons.block, color: Colors.blue),
              title: Text('Ad-free Experience'),
            ),
            const ListTile(
              leading: Icon(Icons.discount, color: Colors.blue),
              title: Text('Exclusive Discount'),
              subtitle: Text('New'),
            ),
            const ListTile(
              leading: Icon(Icons.star, color: Colors.blue),
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
}
