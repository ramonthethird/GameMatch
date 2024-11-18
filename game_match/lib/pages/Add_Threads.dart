import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AddThreadsPage extends StatefulWidget {
  final String gameId;

  const AddThreadsPage({super.key, required this.gameId});

  @override
  _AddThreadsPageState createState() => _AddThreadsPageState();
}

class _AddThreadsPageState extends State<AddThreadsPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedPhoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Thread', style: TextStyle(fontSize: 18,)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Thread Description'),
            _buildDescriptionField(),
            const SizedBox(height: 32),
            _buildPostButton(),
            const SizedBox(height: 16),
            const Text(
              'Please ensure your thread follows our community guidelines.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Stack(
      children: [
        TextField(
          controller: _descriptionController,
          maxLines: 20,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'Describe your thread in detail...',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        if (_selectedPhoto != null)
          Positioned(
            bottom: 40,
            left: 20,
            child: Stack(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_selectedPhoto!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: _deletePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          bottom: 20,
          right: 1,
          child: IconButton(
            icon: Icon(Icons.add_photo_alternate, color: Colors.grey[700]),
            onPressed: _pickImage,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    await _requestStoragePermission();

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _requestStoragePermission() async {
    PermissionStatus status;
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      status = await Permission.photos.request(); // For API 33+
    } else {
      status = await Permission.storage.request(); // For older Android versions
    }

    if (status.isDenied) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Permission denied to access photos. Please allow it from settings.')),
      // );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _deletePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo removed.')),
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _postThread,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
        ),
        child: const Text('Post Thread'),
      ),
    );
  }

  Future<void> _postThread() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out the description.')),
      );
      return;
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to post a thread.')),
        );
        return;
      }

      String? imageUrl;
      if (_selectedPhoto != null) {
        imageUrl = await _uploadImage();
      }

      await FirebaseFirestore.instance.collection('threads').add({
        'gameId': widget.gameId,
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'content': _descriptionController.text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'comments': 0,
        'shares': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thread posted successfully.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error posting thread: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting thread: $e')),
      );
    }
  }

  Future<String> _uploadImage() async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('thread_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      await storageRef.putFile(_selectedPhoto!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw 'Error uploading image';
    }
  }
}