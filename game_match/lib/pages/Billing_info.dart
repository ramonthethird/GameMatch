import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'subscriptionPremium.dart';
import 'package:intl/intl.dart';

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
            color: Colors.white,
            fontSize: 24, // Set text size to 24
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF41B1F1), // Set AppBar background color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                _buildTextField(
                  creditCardController,
                  'Credit Card',
                  'Credit Card Number',
                  isNumeric: true,
                  validator: validateCreditCard,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildExpDateField(
                        expDateController,
                        'Exp. Date',
                        'MM/YY',
                        validator: validateExpDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        securityCodeController,
                        'Security Code',
                        'CVV',
                        isNumeric: true,
                        validator: validateCVV,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  streetAddressController,
                  'Street Address',
                  'Street Address',
                ),
                const SizedBox(height: 20),
                _buildTextField(cityController, 'City', 'City'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        stateController,
                        'State',
                        'State',
                        validator: validateLettersOnly,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        zipCodeController,
                        'Zip Code',
                        'Zip Code',
                        isNumeric: true,
                        validator: validateZipCode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  countryController,
                  'Country',
                  'Country',
                  validator: validateLettersOnly,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _submitBillingInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF41B1F1), // Button background color
                    foregroundColor: Colors.white, // Button text color set to white
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
  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {bool isNumeric = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  // Helper method to build expiration date field
  Widget _buildExpDateField(TextEditingController controller, String label, String hint,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Allow digits only
        ExpDateFormatter(), // Apply custom formatter
      ],
      validator: validator,
    );
  }

  // Validators
  String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) return 'Credit Card Number is required';
    if (!RegExp(r'^\d{16}$').hasMatch(value)) return 'Enter a valid 16-digit credit card number';
    return null;
  }

  String? validateExpDate(String? value) {
    if (value == null || value.isEmpty) return 'Expiration Date is required';
    if (!RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$').hasMatch(value)) {
      return 'Enter a valid date in MM/YY format (01-12 for months)';
    }
    return null;
  }

  String? validateCVV(String? value) {
    if (value == null || value.isEmpty) return 'CVV is required';
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) return 'Enter a valid 3-4 digit CVV';
    return null;
  }

  String? validateZipCode(String? value) {
    if (value == null || value.isEmpty) return 'ZIP Code is required';
    if (!RegExp(r'^\d{5}$').hasMatch(value)) return 'Enter a valid 5-digit ZIP Code';
    return null;
  }

  String? validateLettersOnly(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Enter letters only';
    return null;
  }

  // Method to submit billing information
  Future<void> _submitBillingInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          DateTime currentDate = DateTime.now();
          String formattedStartDate = DateFormat('yyyy-MM-dd').format(currentDate);

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
          }, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are now a premium member!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PremiumSubscriptionPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not logged in. Please log in and try again.'),
              backgroundColor: Colors.red,
            ),
          );
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
  }

  @override
  void dispose() {
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

class ExpDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Restrict input to a maximum of 5 characters (MM/YY)
    if (text.length > 5) {
      return oldValue;
    }

    // Add '/' after the second character if not already present
    if (text.length == 2 && !text.contains('/')) {
      return TextEditingValue(
        text: '$text/',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    // Ensure '/' remains in the correct position
    if (text.length > 2 && text[2] != '/') {
      String correctedText = '${text.substring(0, 2)}/${text.substring(2)}';
      return TextEditingValue(
        text: correctedText,
        selection: TextSelection.collapsed(offset: correctedText.length),
      );
    }

    return newValue;
  }
}


