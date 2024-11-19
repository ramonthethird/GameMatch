import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _favoriteGame1Controller =
      TextEditingController();
  final TextEditingController _favoriteGame2Controller =
      TextEditingController();
  final TextEditingController _favoriteGame3Controller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
// Load user data from Firestore
  Future<void> _loadUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _usernameController.text = userDoc.data()?['username'] ?? 'User';
        _bioController.text = userDoc.data()?['bio'] ?? ''; // Check if field exists
        _favoriteGame1Controller.text = userDoc.data()?['favoriteGames']?['game1'] ?? '';
        _favoriteGame2Controller.text = userDoc.data()?['favoriteGames']?['game2'] ?? '';
        _favoriteGame3Controller.text = userDoc.data()?['favoriteGames']?['game3'] ?? '';
        _profileImageUrl = userDoc.data()?['profileImageUrl'];
      });
    }
  }
}

  // Select an image from the gallery
  Uint8List? _imageData;
  final ImagePicker _imagePicker = ImagePicker(); // Initialize once

  void selectImage() async {
    XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _profileImage = File(file.path);  // This will work for mobile/desktop
      });
      
      // Use the web-compatible method to get the image data
      Uint8List? imageBytes = await file.readAsBytes();
      setState(() {
        _imageData = imageBytes;  // Used for displaying the image
      });
    } else {
      print('No image selected.');
    }
  }

  // Upload the image to Firebase Storage
  Future<void> _uploadImageToFirebase() async {
    if (_profileImage == null) {
      print("No profile image selected");
      return;
    }

    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      final uploadTask = storageRef.putFile(_profileImage!);
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL for the uploaded image
      final downloadURL = await snapshot.ref.getDownloadURL();

      // Update Firestore with the download URL and other user data
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _saveUserDataToFirestore(userId, downloadURL);
      }

      setState(() {
        _profileImageUrl = downloadURL;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
  // Save user data to Firestore
  Future<void> _saveUserDataToFirestore(
      String userId, String downloadURL) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profileImageUrl': downloadURL,
        'username': _usernameController.text,
        'bio': _bioController.text,
        'favoriteGames': {
          'game1': _favoriteGame1Controller.text,
          'game2': _favoriteGame2Controller.text,
          'game3': _favoriteGame3Controller.text,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update profile. Please try again.')),
      );
    }
  }
  // Update the user profile
  Future<void> _updateProfile() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // First, upload the profile image if it's selected
    if (_profileImage != null) {
      await _uploadImageToFirebase();
    }

    // Save the user data with the updated profile image URL
    await _saveUserDataToFirestore(userId, _profileImageUrl ?? '');

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacementNamed(context, '/Side_bar', arguments: {
      'username': _usernameController.text,
      'profileImageUrl': _profileImageUrl,
      'bio': _bioController.text,
      'favoriteGames': {
        'game1': _favoriteGame1Controller.text,
        'game2': _favoriteGame2Controller.text,
        'game3': _favoriteGame3Controller.text,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        // backgroundColor: const Color(0xFF74ACD5),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [//Color(0xFFF1F3F4), Color(0xFFF1F3F4)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _imageData != null
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: MemoryImage(_imageData!),
                                )
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundImage: _profileImageUrl != null &&
                                          _profileImageUrl!.isNotEmpty
                                      ? NetworkImage(_profileImageUrl!)
                                      : null,
                                  child: _profileImageUrl == null ||
                                          _profileImageUrl!.isEmpty
                                      ? const Icon(Icons.person, size: 40)
                                      : null,
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(Icons.add_a_photo,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildTextField(
                      "Username", _usernameController, 1, Icons.person, true),
                  const SizedBox(height: 12),
                  _buildTextField(
                      "Bio", _bioController, 4, Icons.info_outline, true),
                  const SizedBox(height: 12),
                  const Text("Favorite Games",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildTextField("Favorite Game 1", _favoriteGame1Controller,
                      1, Icons.videogame_asset, true),
                  const SizedBox(height: 8),
                  _buildTextField("Favorite Game 2", _favoriteGame2Controller,
                      1, Icons.videogame_asset, true),
                  const SizedBox(height: 8),
                  _buildTextField("Favorite Game 3", _favoriteGame3Controller,
                      1, Icons.videogame_asset, true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            await _updateProfile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profile updated successfully')),
                            );
                            Navigator.pop(context); // Go back to previous page
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF41B1F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      int maxLines, IconData icon, bool enabled) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }
}