import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yaredubal/screen/CustomerDashboard.dart';
import 'package:yaredubal/components/elements.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _profileImageController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instrumentController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedRole = 'User'; // Default role
  String? _selectedGender; // Gender dropdown value
  bool _isLoading = false;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  Future<void> _signUp() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store user details in Firestore
      Map<String, dynamic> userData = {
        'id': userCredential.user?.uid,
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'profileImage': _profileImageController.text.trim(),
        'role': _selectedRole,
        'phone': _phoneController.text.trim(),
        'gender': _selectedGender,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add additional fields for musicians
      if (_selectedRole == 'Musician') {
        userData.addAll({
          'expertise': _expertiseController.text.trim(),
          'hourlyRate': _hourlyRateController.text.trim(),
          'bio': _bioController.text.trim(),
          'instrument': _instrumentController.text.trim(),
          'searchableAttributes': [_expertiseController.text.trim(), _instrumentController.text.trim()]
        });
      }

      await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account Created Successfully')),
      );
      navigateBasedOnRole();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign Up Failed')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 48),
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Role: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 16),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          items: ['User', 'Musician'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SimpleComponents.buildTextField(
                  _nameController,
                  "Name",
                  "Enter your name",
                ),
                SizedBox(height: 16),
                SimpleComponents.buildTextField(
                  _emailController,
                  "Email",
                  "Enter your email",
                ),
                SizedBox(height: 16),
                SimpleComponents.buildTextField(
                  _phoneController,
                  "Phone Number",
                  "Enter your Phone Number",
                ),
                SizedBox(height: 16),
                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                SimpleComponents.buildTextField(
                  _passwordController,
                  "Password",
                  "Enter your password",
                  isPassword: true,
                ),
                SizedBox(height: 16),
                SimpleComponents.buildTextField(
                  _confirmPasswordController,
                  "Confirm Password",
                  "Re-enter your password",
                  isPassword: true,
                ),
                SizedBox(height: 24),

                // Additional fields for Musicians
                if (_selectedRole == 'Musician') ...[
                  SimpleComponents.buildTextField(
                    _expertiseController,
                    "Expertise",
                    "e.g., Pianist, Guitarist",
                  ),
                  SizedBox(height: 16),
                  SimpleComponents.buildTextField(
                    _hourlyRateController,
                    "Hourly Rate",
                    "e.g., 200",
                  ),
                  SizedBox(height: 16),
                  SimpleComponents.buildTextField(
                    _bioController,
                    "Bio",
                    "Tell us about yourself",
                  ),
                  SizedBox(height: 16),
                  SimpleComponents.buildTextField(
                    _instrumentController,
                    "Instrument or Enter None",
                    "e.g., Piano, Guitar",
                  ),
                  SizedBox(height: 24),
                ],

                SimpleComponents.buildButton(
                  isLoading: _isLoading,
                  onTap: _signUp,
                  buttonText: 'Sign Up',
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> navigateBasedOnRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = doc.data()?['role'];

      if (role == 'User') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CustomerDashboard(name: doc.data()?['name'] ?? ''),
          ),
        );
      } else {
        // Handle musician navigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDashboard(
              name: doc.data()?['name'] ?? '',
              isMusician: true,
            ),
          ),
        );
      }
    }
  }
}
