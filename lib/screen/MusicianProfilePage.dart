import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:yaredubal/screen/BookingPage.dart';

class MusicianProfilePage extends StatefulWidget {
  final String musicianId;
  final Map<String, dynamic> musicianData;

  MusicianProfilePage({required this.musicianId, required this.musicianData});

  @override
  _MusicianProfilePageState createState() => _MusicianProfilePageState();
}

class _MusicianProfilePageState extends State<MusicianProfilePage> {
  late Future<Map<String, dynamic>?> musicianDetailsFuture;

  @override
  void initState() {
    super.initState();
    musicianDetailsFuture = fetchmusicianDetails();
  }

  Future<Map<String, dynamic>?> fetchmusicianDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.musicianId)
        .get();
    return doc.data();
  }

  Future<void> submitRating(double rating) async {
    final ratingsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.musicianId)
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
        .doc(widget.musicianId)
        .update({'rating': averageRating});

    setState(() {
      musicianDetailsFuture = fetchmusicianDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('musician Profile'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: musicianDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('musician details not found.'));
          }

          final musicianDetails = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Section
                // Stack(
                //   children: [
                //     Container(
                //       height: 200,
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           colors: [Colors.blue, Colors.blueAccent],
                //           begin: Alignment.topLeft,
                //           end: Alignment.bottomRight,
                //         ),
                //       ),
                //     ),
                //     Positioned(
                //       top: 50,
                //       left: MediaQuery.of(context).size.width / 2 - 50,
                //       child: CircleAvatar(
                //         radius: 50,
                //         backgroundImage: NetworkImage(
                //             musicianDetails['profileImage'] ??
                //                 'https://via.placeholder.com/150'),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 16),

                // musician Name and Rating
                Center(
                  child: Column(
                    children: [
                      Text(
                        musicianDetails['name'] ?? 'Name not available',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '${musicianDetails['rating'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Bio Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Me',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        musicianDetails['bio'] ?? 'Bio not available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Expertise Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expertise',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        musicianDetails['expertise'] ??
                            'Expertise not available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Hourly Rate Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hourly Rate',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        musicianDetails['hourlyRate'] != null
                            ? '\$${musicianDetails['hourlyRate']}/hour'
                            : 'Rate not available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Contact Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        musicianDetails['email'] ?? 'Email not available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingPage(musicianData: widget.musicianData),
                        ),
                      );
                    },
                    child: Text('Hire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: Size(
                          double.infinity, 36), // Stretch button to full width
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
