// Billing_info.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'subscriptionPremium.dart'; // Import the SubscriptionPremium page
import 'package:intl/intl.dart'; // For date formatting

class BillingInfoPage extends StatefulWidget {
  const BillingInfoPage({super.key});

  @override
  _BillingInfoPageState createState() => _BillingInfoPageState();
}

class _BillingInfoPageState extends State<BillingInfoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController creditCardController = TextEditingController();
  final TextEditingController expDateController = TextEditingController();
  final TextEditingController securityCodeController = TextEditingController();
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Billing Info',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        //backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/gamematchlogoresize.png', // Replace with your logo path
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Update Billing Credit Card Info',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField(creditCardController, 'Credit Card', 'Credit Card Number', isNumeric: true),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(expDateController, 'Exp. Date', 'MM/YY', isNumeric: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(securityCodeController, 'Security Code', 'CVV', isNumeric: true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(streetAddressController, 'Street Address', 'Street Address'),
                const SizedBox(height: 20),
                _buildTextField(cityController, 'City', 'City'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(stateController, 'State', 'State'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(zipCodeController, 'Zip Code', 'Zip Code', isNumeric: true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(countryController, 'Country', 'Country'),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _submitBillingInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF41B1F1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  // Method to submit billing information
  Future<void> _submitBillingInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Get current authenticated user
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Get the current date and calculate the expiration date (1 month later)
          DateTime currentDate = DateTime.now();
          DateTime expirationDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);

          // Format the dates to store as strings
          String formattedStartDate = DateFormat('yyyy-MM-dd').format(currentDate);
          String formattedExpirationDate = DateFormat('yyyy-MM-dd').format(expirationDate);

          // Save billing information and update subscription status to "paid" with start and expiration dates in Firestore
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
            'creditCard': creditCardController.text,
            'expDate': expDateController.text,
            'securityCode': securityCodeController.text,
            'streetAddress': streetAddressController.text,
            'city': cityController.text,
            'state': stateController.text,
            'zipCode': zipCodeController.text,
            'country': countryController.text,
            'subscription': 'paid',
            'subscriptionStartDate': formattedStartDate,
            'subscriptionExpirationDate': formattedExpirationDate,
          }, SetOptions(merge: true));

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are now a premium member!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to SubscriptionPremiumPage if subscription is paid
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PremiumSubscriptionPage()),
          );
        } else {
          // Show an error if the user is not logged in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not logged in. Please log in and try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error: $e');
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    creditCardController.dispose();
    expDateController.dispose();
    securityCodeController.dispose();
    streetAddressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }
}