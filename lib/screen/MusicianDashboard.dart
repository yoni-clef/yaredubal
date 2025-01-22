import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yaredubal/components/BookingCard.dart';
import 'package:yaredubal/screen/login.dart';

class MusicianDashboard extends StatefulWidget {
  @override
  _MusicianDashboardState createState() => _MusicianDashboardState();
}

class _MusicianDashboardState extends State<MusicianDashboard> {
  Future<Map<String, dynamic>?> fetchmusicianProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<void> updatemusicianProfile(Map<String, dynamic> updatedData) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update(updatedData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
    setState(() {});
  }

  Stream<QuerySnapshot> fetchmusicianBookings() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('musicianId', isEqualTo: userId)
        .snapshots();
  }

  void showEditProfileDialog(Map<String, dynamic> profileData) {
    final nameController = TextEditingController(text: profileData['name']);
    final expertiseController =
        TextEditingController(text: profileData['expertise']);
    final bioController = TextEditingController(text: profileData['bio']);
    final hourlyRateController =
        TextEditingController(text: profileData['hourlyRate']?.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: expertiseController,
                  decoration: InputDecoration(labelText: 'Expertise'),
                ),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(labelText: 'Bio'),
                ),
                TextField(
                  controller: hourlyRateController,
                  decoration: InputDecoration(labelText: 'Hourly Rate (\$)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'expertise': expertiseController.text.trim(),
                  'bio': bioController.text.trim(),
                  'hourlyRate':
                      double.tryParse(hourlyRateController.text.trim()) ?? 0.0,
                };
                await updatemusicianProfile(updatedData);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showEditFieldDialog(String fieldKey, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $fieldKey'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Enter your $fieldKey',
            ),
            maxLines: fieldKey == 'bio' ? 5 : 1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedValue = controller.text.trim();
                if (updatedValue.isNotEmpty) {
                  await updatemusicianProfile({fieldKey: updatedValue});
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchmusicianProfile(),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!profileSnapshot.hasData || profileSnapshot.data == null) {
            return Center(child: Text('Failed to load Bookings.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // musician Profile Section

              // Bookings Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Bookings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: fetchmusicianBookings(),
                  builder: (context, bookingsSnapshot) {
                    if (bookingsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!bookingsSnapshot.hasData ||
                        bookingsSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No bookings available.'));
                    }

                    final bookings = bookingsSnapshot.data!.docs;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          final bookingData =
                              booking.data() as Map<String, dynamic>;

                          return BookingCard(
                              bookingData: bookingData,
                              bookingId: booking.id,
                              ismusician: true);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
