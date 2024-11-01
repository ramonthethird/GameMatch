// SubscriptionPremium.dart
import 'package:flutter/material.dart';

class PremiumSubscriptionPage extends StatelessWidget {
  const PremiumSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscription'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/images/premium_banner.png', // Update the path with your image
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
                  Navigator.pushNamed(context, '/Billing');
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
                // Navigate to terms and conditions or privacy policy
              },
              child: const Text('Terms and Conditions'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to terms and conditions or privacy policy
              },
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}
