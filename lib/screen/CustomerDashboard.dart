import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yaredubal/screen/BookingPage.dart';
import 'package:yaredubal/screen/CustomerBookingsPage.dart';
import 'package:yaredubal/screen/musicianDashboard.dart';
import 'package:yaredubal/screen/musicianProfilePage.dart';
import 'package:yaredubal/screen/exploreFamousMusicians.dart';
import 'package:yaredubal/screen/hire_screen.dart';
import 'package:yaredubal/screen/login.dart';
import 'package:yaredubal/screen/profile_screen.dart';
import 'package:yaredubal/screen/landingPage.dart';

class CustomerDashboard extends StatefulWidget {
  final String name;
  final bool isMusician;

  CustomerDashboard({required this.name, this.isMusician = false});

  @override
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
      return getRecommendedmusicians();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Musician')
        .where(Filter.or(
          Filter.and(
            Filter(
              'name',
              isGreaterThanOrEqualTo: query,
            ),
            Filter('name', isLessThanOrEqualTo: '${query}\uf8ff'),
          ),
          Filter.and(
            Filter(
              'expertise',
              isGreaterThanOrEqualTo: query,
            ),
            Filter('expertise', isLessThanOrEqualTo: '$query\uf8ff'),
          ),
        ))
        // .where('name', isGreaterThanOrEqualTo: query)
        // .where('name', isLessThanOrEqualTo: query + '\uf8ff')
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
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text(
          'Yaredubal',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (user == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                style: TextButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.2, 50),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.amberAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                onPressed: () {
                  // Navigate to login page
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text(
                  'Login',
                ),
              ),
            ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                style: TextButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.2, 50),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.amberAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OnboardingPage()));
                },
                child: Text(
                  'Logout',
                ),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          if (index == 0) {
            return homePage();
          } else if (index == 1) {
            return widget.isMusician
                ? MusicianDashboard()
                : CustomerBookingsPage();
          } else {
            return ProfilePage();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentPage = index;
          });
        },

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _currentPage == 0 ? Colors.amberAccent : Colors.black),
            label: 'Home',
            backgroundColor: _currentPage == 0 ? Colors.blue : Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month,
                color: _currentPage == 1 ? Colors.amberAccent : Colors.black),
            label: 'Bookings',
            backgroundColor: _currentPage == 1 ? Colors.blue : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _currentPage == 2 ? Colors.amberAccent : Colors.black),
            label: 'Profile',
            backgroundColor:
                _currentPage == 2 ? Colors.amberAccent : Colors.black,
          ),
        ],
        currentIndex: 0, // Default to 'Home'
      ),
    );
  }

  Widget homePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            SizedBox(height: 24),
            _searchQuery.isEmpty
                ? Center(
                    child: Container(
                      height: 400,
                      child: Center(
                        child: Image(
                            image: AssetImage('assets/images/treble-clef.png')),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                      fixedSize:
                          Size(MediaQuery.of(context).size.width * 0.4, 50),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExploreScreen(),
                        ));
                  },
                  child: const Text(
                    'Explore Musicians',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                if (!widget.isMusician)
                  TextButton(
                    style: TextButton.styleFrom(
                        fixedSize:
                            Size(MediaQuery.of(context).size.width * 0.4, 50),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.amberAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        )),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HireScreen(),
                          ));
                    },
                    child: const Text(
                      'Hire Musicians',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
