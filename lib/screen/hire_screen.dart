import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yaredubal/components/slide_show.dart';
import 'package:yaredubal/screen/BookingPage.dart';
import 'package:yaredubal/screen/musicianProfilePage.dart';
import 'package:rxdart/rxdart.dart';

class HireScreen extends StatefulWidget {
  const HireScreen({super.key});

  @override
  State<HireScreen> createState() => _HireScreenState();
}

class _HireScreenState extends State<HireScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<QuerySnapshot> getRecommendedmusicians() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Musician')
        // .orderBy('rating', descending: true)
        .limit(5)
        .snapshots();
  }

  Stream<QuerySnapshot> searchmusicians(String query) {
    if (query.isEmpty) {
      return getRecommendedmusicians(); // Return recommended musicians if the query is empty
    }

    // Convert the query to lowercase for case-insensitive search
    String lowercaseQuery = query.toLowerCase();

    // Search by expertise
    Stream<QuerySnapshot> expertiseQuery = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Musician')
        .where('expertise', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('expertise', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .snapshots();

    // Search by instrument
    Stream<QuerySnapshot> instrumentQuery = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Musician')
        .where('instrument', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('instrument', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .snapshots();

    // Combine the results of both queries using MergeStream
    return expertiseQuery;
  }

  Stream<QuerySnapshot> searchMusicians(String query) {
    if (query.isEmpty) {
      return getRecommendedmusicians(); // Return recommended musicians if the query is empty
    }

    // Convert the query to lowercase for case-insensitive search
    String lowercaseQuery = query.toLowerCase();

    // Perform a single query on the `searchableAttributes` array
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Musician')
        .where('searchableAttributes', arrayContains: lowercaseQuery)
        .snapshots();
  }

  Stream<QuerySnapshot> getUpcomingBookings() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('customerId', isEqualTo: userId)
        .snapshots();
  }

  void navigateToBookingPage(Map<String, dynamic> musicianData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(musicianData: musicianData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Hire Musician')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by expertise or instrument',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: searchMusicians(_searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      final musicians = snapshot.data!.docs;
                      // print(musicians[0].data());
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * .7,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: musicians.length,
                          itemBuilder: (context, index) {
                            final musician = musicians[index];
                            print('------ MUSUC');
                            print(musician.data());
                            print('------ MUSUC');
                            final musicianData =
                                musician.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 300,
                                height: 170,
                                child: Container(
                                  margin: EdgeInsets.only(right: 16),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border:
                                        Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image.network(
                                      //   "${musicianData['profileImage']}",
                                      //   height: 150,
                                      //   width: 300,
                                      //   fit: BoxFit.cover,
                                      //   errorBuilder: (context, error, stackTrace) {
                                      //     return Image.asset(
                                      //       'assets/images/mozart.jpeg',
                                      //       height: 150,
                                      //       width: 300,
                                      //     );
                                      //   },
                                      // ),
                                      const SizedBox(width: 24),
                                      Text(
                                        musicianData['name'] ?? 'No Name',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Expertise: ${musicianData['expertise']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),

                                      SizedBox(height: 4),

                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.orange, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            musicianData['rating']
                                                .toString()
                                                .substring(0, 3),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MusicianProfilePage(
                                                  musicianId: musician['id'],
                                                  musicianData: musicianData,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('View profile'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amberAccent,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            minimumSize: Size(double.infinity,
                                                36), // Stretch button to full width
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                    // return Center(child: Text('No musicians found.'));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
