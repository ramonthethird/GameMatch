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

  const AddThreadsPage({Key? key, required this.gameId}) : super(key: key);

  @override
  _AddThreadsPageState createState() => _AddThreadsPageState();
}

class _AddThreadsPageState extends State<AddThreadsPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedPhoto;
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create a New Thread',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
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
            Text(
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
        style: TextStyle(
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
          maxLines: 15,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'Describe your thread in detail...',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
        ),
        if (_selectedPhoto != null)
          Positioned(
            bottom: 45,
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
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
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
      SnackBar(content: Text('Photo removed.')),
    );
  }

  Widget _buildPostButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isPosting ? null : _postThread, // Disable button if posting
      style: ElevatedButton.styleFrom(
        backgroundColor: _isPosting
            ? Colors.grey // Disabled button color
            : const Color(0xFF41B1F1), // Enabled button color
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: _isPosting
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Text(
              'Post Thread',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
    ),
  );
}



  Future<void> _postThread() async {
  if (_isPosting) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please wait before posting again.')),
    );
    return;
  }

  if (_descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill out the description.')),
    );
    return;
  }

  setState(() {
    _isPosting = true;
  });

  try {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to post a thread.')),
      );
      setState(() {
        _isPosting = false;
      });
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
      SnackBar(content: Text('Thread posted successfully.')),
    );
    Navigator.of(context).pop();
  } catch (e) {
    print('Error posting thread: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error posting thread: $e')),
    );
  } finally {
    setState(() {
      _isPosting = false;
    });
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