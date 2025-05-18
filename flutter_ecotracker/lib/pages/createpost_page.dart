import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  String _selectedCategory = "401";
  bool _isSubmitting = false;
  String? _userId;

  final List<Map<String, String>> _categories = [
    {"id": "401", "name": "near you"},
    {"id": "402", "name": "Events"},
    {"id": "403", "name": "Residential Area"},
    {"id": "404", "name": "Beach & Coastal"},
    {"id": "405", "name": "Public Space Cleaning"},
    {"id": "406", "name": "Urban & Institutional Clean-Up"},
    {"id": "407", "name": "Forest & Mountain Clean-Up"},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id');
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageFile = null;
        });
      } else {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedImageBytes = null;
        });
      }
    }
  }

  Future<void> _submitPost() async {
    if (_postController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter some text before posting.")),
      );
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID not found. Please log in again.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final int? categoryId = int.tryParse(_selectedCategory);
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid category selected.")),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final response = await ApiService.createPost(
      _postController.text.trim(),
      categoryId,
      _selectedImageFile,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (response != null && response['status'] == 'success') {
      final pointsEarned = response['points_earned'] ?? 0;

      // Save notification locally
      final prefs = await SharedPreferences.getInstance();
      final currentNotifs = prefs.getStringList('local_notifications') ?? [];
      currentNotifs.add('Earned $pointsEarned points for your post!');
      await prefs.setStringList('local_notifications', currentNotifs);
      _postController.clear();
      setState(() {
        _selectedImageFile = null;
        _selectedImageBytes = null;
      });

      // Optional: Navigate back or refresh posts
      Navigator.pop(context, true);
    } else {
      final errorMessage = response?['message'] ?? "Failed to create post";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _postController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category["id"],
                    child: Text(category["name"]!),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
                decoration: InputDecoration(labelText: "Select Category"),
              ),
              SizedBox(height: 10),
              if (_selectedImageFile != null || _selectedImageBytes != null)
                Column(
                  children: [
                    kIsWeb
                        ? Image.memory(_selectedImageBytes!, height: 200)
                        : Image.file(_selectedImageFile!, height: 200),
                    SizedBox(height: 10),
                  ],
                ),
              ElevatedButton.icon(
                icon: Icon(Icons.image),
                label: Text("Pick Image"),
                onPressed: _pickImage,
              ),
              SizedBox(height: 20),
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitPost,
                      child: Text("Post"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
