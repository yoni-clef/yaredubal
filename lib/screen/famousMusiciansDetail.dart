import 'package:flutter/material.dart';
import 'package:yaredubal/screen/musicianModel.dart';

class MusicianDetailsScreen extends StatelessWidget {
  final Musician musician;
  MusicianDetailsScreen({super.key, required this.musician});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(musician.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(musician.imagePath, fit: BoxFit.cover),
              SizedBox(height: 16),
              Text(
                musician.name,
                style: Theme.of(context).textTheme.headlineSmall,
                selectionColor: Colors.amberAccent,
              ),
              SizedBox(height: 8),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Text(musician.achievements),
              SizedBox(height: 16),
              Text(
                'Biography',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(musician.biography),
            ],
          ),
        ),
      ),
    );
  }
}
