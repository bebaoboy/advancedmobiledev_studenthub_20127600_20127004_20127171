import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Background extends StatelessWidget {
  const Background({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade500,
          ],
        ),
      ),
      child: child,
    );
  }
}


class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
    final ThemeStore _themeStore = getIt<ThemeStore>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeStore.darkMode ? Colors.black.withOpacity(0) : Colors.white.withOpacity(0),
      body: Background(
        child: Center(
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
      ),
    );
  }
}