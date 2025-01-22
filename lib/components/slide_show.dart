import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SlideshowComponent extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> slides;
  final Duration autoScrollDuration;

  const SlideshowComponent({
    super.key,
    required this.slides,
    this.autoScrollDuration = const Duration(seconds: 3),
  });

  @override
  State<SlideshowComponent> createState() => _SlideshowComponentState();
}

class _SlideshowComponentState extends State<SlideshowComponent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % widget.slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 18,
      child: Stack(
        children: [
          GestureDetector(
            onTapDown: (_) => _stopAutoScroll(), // Stop on touch
            onTapCancel: _startAutoScroll, // Restart after touch
            onTapUp: (_) => _startAutoScroll(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.slides.length,
              itemBuilder: (context, index) {
                final musician = widget.slides[index];
                final musicianData = musician.data() as Map<String, dynamic>;
                print('-----------RECOMMENDATION USERS');
                print(widget.slides[0].data());
                print('-----------RECOMMENDATION USERS');
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/mozart.jpeg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(1), // Black at the bottom
                            Colors.transparent, // Transparent at the top
                          ],
                          stops: [0.0, 0.6], // Adjust to control fade effect
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20, // Adjust the distance from the bottom
                      left: 20,
                      right: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${musicianData['name']!}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Expertise: ${musicianData['expertise']!}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Rating: ${musicianData['rating'].toString().substring(0, 3)}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 10 : 6,
                  height: _currentPage == index ? 10 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
