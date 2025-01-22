import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _image;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _hourlyRateController = TextEditingController();
  TextEditingController _yearsOfExperienceController = TextEditingController();

  bool _isEditing = false;
  bool _isMusician = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _isMusician = doc['role'] == 'Musician';
        _nameController.text = doc['name'];
        _emailController.text = doc['email'];
        _phoneController.text = doc['phone'];
        _bioController.text = doc['bio'] ?? '';
        _hourlyRateController.text = doc['hourlyRate'] ?? '';
        _yearsOfExperienceController.text = doc['yearsOfExperience'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'bio': _bioController.text,
        'hourlyRate': _hourlyRateController.text,
        'yearsOfExperience': _yearsOfExperienceController.text,
      });
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/mozart.jpeg")),
            SizedBox(height: 20),
            _buildEditableField('Name', _nameController),
            _buildEditableField('Phone', _phoneController),
            if (_isMusician)
              _buildEditableField('Bio', _bioController, maxLines: 3),
            if (_isMusician)
              _buildEditableField('Hourly Rate', _hourlyRateController),
            if (_isMusician)
              _buildEditableField(
                  'Years of Experience', _yearsOfExperienceController),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: _isEditing
                ? Colors.black
                : Colors.grey[600], // Change label color based on edit mode
          ),
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.black), // Border color when enabled
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                    Colors.black), // Border color when enabled but not focused
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey[400]!), // Border color when disabled
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .amberAccent), // Border color when enabled but not focused
          ),
          filled: true,
          fillColor: _isEditing
              ? Colors.white
              : Colors.grey[200], // Background color based on edit mode
        ),
        maxLines: maxLines,
        enabled: _isEditing,
        style: TextStyle(
          color: _isEditing
              ? Colors.black
              : Colors.grey[800], // Text color based on edit mode
        ),
      ),
    );
  }
}
