import 'dart:async';

import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final UserStore _userStore = getIt<UserStore>();

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _playAnimation(context);
    // Timer(
    //     Duration(seconds: 3),
    //     () => Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute2(
    //             child: _userStore.isLoggedIn ? HomeScreen() : LoginScreen())));
  }

  Future<Null> _playAnimation(BuildContext context) async {
    try {
      await _controller.forward().orCancel;
//      await controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
      _controller.stop();
    } finally {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute2(
              child: _userStore.isLoggedIn ? HomeScreen() : LoginScreen()));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
                'assets/animations/splash_animation.json', // Replace with the path to your Lottie JSON file
                fit: BoxFit.cover,
                width:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 200
                        : 400, // Adjust the width and height as needed
                height:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 200
                        : 400,
                repeat: false, // Set to true if you want the animation to loop
                controller: _controller,
              ),
            ),
            MediaQuery.of(context).orientation != Orientation.landscape
                ? Center(
                    child: Text(
                      "StudentHub",
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        // color: Colors.blueAccent,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 0,
                  ),
            MediaQuery.of(context).orientation != Orientation.landscape
                ? Center(
                    child: Text(
                      // "20127600 - 20127004 - 20127171",
                      "Copyright © 2024",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 0,
                  ),
          ],
        ),
      ),
    );
  }
}
