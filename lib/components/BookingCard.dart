import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookingCard extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final bool ismusician;
  final String bookingId;

  BookingCard(
      {required this.bookingData,
      required this.bookingId,
      this.ismusician = false});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  String userRoleG = "Loading...";
  double? userRating;
  bool ratingSubmitted = false;
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking status updated to $newStatus.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking canceled successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking: $e')),
      );
    }
  }

  late Future<Map<String, dynamic>?> musicianDetailsFuture;

  @override
  void initState() {
    super.initState();
    musicianDetailsFuture = fetchmusicianDetails();
  }

  Future<Map<String, dynamic>?> fetchmusicianDetails() async {
    final musicianId = widget.bookingData['musicianId'];
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(musicianId)
        .get();
    return doc.data();
  }

  Future<void> submitRating(double rating) async {
    final musicianId = widget.bookingData['musicianId'];
    final ratingsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(musicianId)
        .collection('ratings');

    // Save the user's rating
    await ratingsRef
        .add({'rating': rating, 'timestamp': FieldValue.serverTimestamp()});

    // Recalculate and update the average rating
    final ratingsSnapshot = await ratingsRef.get();
    final ratings =
        ratingsSnapshot.docs.map((doc) => doc['rating'] as double).toList();
    final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(musicianId)
        .update({'rating': averageRating});

    setState(() {
      musicianDetailsFuture = fetchmusicianDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        "Name : ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.ismusician
                            ? widget.bookingData['customerName']
                            : widget.bookingData['musicianName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        
                      ),
                      // Text(
                      //   widget.ismusician
                      //       ? musicianDetailsFuture[]
                      //       : widget.bookingData['musicianName'],
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                        
                      // )
                    ],
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Reschedule') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController newDateController =
                              TextEditingController();
                          TextEditingController newTimeController =
                              TextEditingController();

                          return AlertDialog(
                            title: Text('Reschedule Booking'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: newDateController,
                                  decoration: InputDecoration(
                                      labelText: 'New Date (e.g., 2024-12-30)'),
                                ),
                                TextField(
                                  controller: newTimeController,
                                  decoration: InputDecoration(
                                      labelText: 'New Time (e.g., 10:00 AM)'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (newDateController.text.isNotEmpty &&
                                      newTimeController.text.isNotEmpty) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('bookings')
                                          .doc(widget.bookingId)
                                          .update({
                                        'date': newDateController.text.trim(),
                                        'time': newTimeController.text.trim(),
                                        'status': 'rescheduled',
                                      });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Booking rescheduled successfully.')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to reschedule booking: $e')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please provide both date and time.')),
                                    );
                                  }
                                },
                                child: Text('Reschedule'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (value == 'Cancel') {
                      cancelBooking(widget.bookingId);
                    } else if (value == 'Confirm') {
                      updateBookingStatus(widget.bookingId, 'confirmed');
                    }
                  },
                  itemBuilder: (context) => [
                    if (widget.ismusician)
                      PopupMenuItem(
                          value: 'Confirm', child: Text('Confirm Booking')),
                    PopupMenuItem(
                        value: 'Reschedule', child: Text('Reschedule')),
                    PopupMenuItem(
                        value: 'Cancel', child: Text('Cancel Booking')),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey),
              SizedBox(width: 5),
              Text(
                'Date: ${widget.bookingData['date']}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey),
              SizedBox(width: 5),
              Text(
                'Time: ${widget.bookingData['time']}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 5),
          widget.bookingData['status'] == 'confirmed' && !widget.ismusician
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone Number: ${widget.bookingData['phone']}'),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: ratingSubmitted
                          ? Center(
                              child: Text(
                                'Thank you for your rating!',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rate this musician',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: RatingBar.builder(
                                    initialRating: userRating ?? 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        userRating = rating;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: userRating != null
                                        ? () async {
                                            await submitRating(userRating!);
                                            setState(() {
                                              ratingSubmitted = true;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Thank you for rating!'),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Text('Submit Rating'),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.info, color: Colors.grey),
              SizedBox(width: 5),
              Text(
                'Status: ${widget.bookingData['status']}',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.bookingData['status'] == 'confirmed' ||
                          widget.bookingData['status'] == 'completed' ||
                          widget.bookingData['status'] == 'accepted'
                      ? Colors.green
                      : widget.bookingData['status'] == 'rescheduled'
                          ? Colors.orange
                          : widget.bookingData['status'] == 'pending'
                              ? Colors.blue
                              : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
