import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yaredubal/screen/musicial_details_screen.dart';
import 'package:yaredubal/screen/musician.dart';
import 'package:yaredubal/screen/musician.dart';
import 'package:yaredubal/screen/musicians.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Musician> filteredUsers = [];
  List<Musician> musician = [];

  List<dynamic> jsonList = json.decode(response);

  void updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      filteredUsers = musician
          .where((user) =>
              user.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    musician = jsonList.map((item) => Musician.fromJson(item)).toList();
    filteredUsers = musician;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Search Bar
              TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Find a musician...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          filteredUsers = [];
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: updateSearchQuery),

              Expanded(
                child: filteredUsers.isEmpty
                    ? Center(child: Text("No users found"))
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MusicianDetailsScreen(
                                    musician: filteredUsers[index],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.asset(
                                        filteredUsers[index].imagePath,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      filteredUsers[index].name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 4.0),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        filteredUsers[index].achievements,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
