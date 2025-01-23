import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yaredubal/screen/CustomerDashboard.dart';
import 'package:yaredubal/screen/login.dart';
import 'package:yaredubal/screen/landingPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yaredubal',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: OnboardingPage(),
    );
    //     home: FutureBuilder<Map<String, dynamic>?>(
    //       future: navigateBasedOnRole(),
    //       builder: (context, snapshot) {
    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return Scaffold(
    //             body: Center(
    //               child: CircularProgressIndicator(),
    //             ),
    //           );
    //         }

    //         if (snapshot.hasData) {
    //           final name = snapshot.data!['name'];
    //           final role = snapshot.data!['role'];
    //           if (role == 'User') {
    //             return CustomerDashboard(
    //               name: name,
    //             );
    //           } else if (role == 'Musician') {
    //             return CustomerDashboard(
    //               name: name,
    //               isMusician: true,
    //             );
    //           }
    //         }

    //         return CustomerDashboard(name: 'user');
    //       },
    //     ),
    //   );
    // }

    // Future<Map<String, dynamic>?> navigateBasedOnRole() async {
    //   final user = FirebaseAuth.instance.currentUser;
    //   print(user);
    //   if (user != null) {
    //     final doc = await FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(user.uid)
    //         .get();
    //     final res = doc.data();

    //     return res;
    //   }

    //   return null;
  }
}
