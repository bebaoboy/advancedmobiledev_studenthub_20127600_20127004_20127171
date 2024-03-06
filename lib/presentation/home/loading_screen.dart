import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                fit: BoxFit.cover,
                width: 200, // Adjust the width and height as needed
                height: 200,
                repeat: true, // Set to true if you want the animation to loop
              ),
            ),
            const Center(
              child: Text(
                "Please wait...",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            )
          ],
        ),
      ),
    );
  }
}