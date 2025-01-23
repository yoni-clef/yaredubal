import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> musicianData;

  BookingPage({required this.musicianData});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
   
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> bookmusician() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You need to be logged in to book a musician.')),
        );
        return;
      }

      print(widget.musicianData['id']);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final customerId = user.uid;
      final customerName = doc['name'] ?? 'Customer Name';
      final musicianId = widget.musicianData['id'];
      final musicianName = widget.musicianData['name'];
      final musicianPhone = widget.musicianData['phone'];
      final date = _dateController.text.trim();
      final time = _timeController.text.trim();

      if (date.isEmpty || time.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all fields.')),
        );
        return;
      }

      // Check if booking conflicts exist (Optional)
      final existingBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('musicianId', isEqualTo: musicianId)
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: time)
          .get();

      if (existingBookings.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('The musician is not available at this time.')),
        );
        return;
      }

      // Create booking
      await FirebaseFirestore.instance.collection('bookings').add({
        'customerId': customerId,
        'customerName': customerName,
        'musicianId': musicianId,
        'musicianName': musicianName,
        'date': date,
        'time': time,
        'phone': musicianPhone,
        'status': 'pending', // Optional field
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book musician: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book musician'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // musician Details

            SizedBox(height: 24),

            // Booking Form
            Text(
              'Schedule a Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Preferred Date (e.g., 2024-12-30)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusColor: Colors.amberAccent,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amberAccent),
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Preferred Time (e.g., 10:00 AM)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusColor: Colors.amberAccent,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amberAccent),
                ),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: bookmusician,
              child: Text('Confirm Booking'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.amberAccent,
                backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
