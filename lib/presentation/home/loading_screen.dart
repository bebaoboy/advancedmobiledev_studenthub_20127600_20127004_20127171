import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Background extends StatelessWidget {
  const Background({super.key, required this.child});
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

// ignore: must_be_immutable
class LoadingScreen extends StatefulWidget {
  final String? text;
  const LoadingScreen({super.key, this.text});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      setState(() {
        opacity = 1;
      });
    });
  }

  var dioClient = getIt<DioClient>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: dioClient.dioText,
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor: _themeStore.darkMode
                ? Colors.black.withOpacity(0)
                : Colors.white.withOpacity(0),
            body: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 200),
              child: Background(
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
                          repeat:
                              true, // Set to true if you want the animation to loop
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.text != null
                              ? Lang.get(widget.text ?? "loading")
                              : dioClient.dioText.value ?? Lang.get("loading"),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

// ignore: must_be_immutable
class LoadingScreenWidget extends StatelessWidget {
  final String? text;
  const LoadingScreenWidget({super.key, this.size = 60, this.text});
  final double size;

  @override
  Widget build(BuildContext context) {
    final dioClient = getIt<DioClient>();

    return ValueListenableBuilder(
        valueListenable: dioClient.dioText,
        builder: (context, value, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Lottie.asset(
                  'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                  fit: BoxFit.cover,
                  width: size, // Adjust the width and height as needed
                  height: size,
                  repeat: true, // Set to true if you want the animation to loop
                ),
              ),
              Center(
                child: Text(
                  text != null
                      ? Lang.get(text ?? "loading")
                      : dioClient.dioText.value ?? Lang.get("loading"),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
              )
            ],
          );
        });
  }
}
