import 'dart:async';
import 'dart:math';

import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  const AnimatedWave({super.key, required this.height, required this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: height,
        width: constraints.biggest.width,
        child: LoopAnimationBuilder(
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value, child) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween(
          "color1",
          duration: const Duration(seconds: 3),
          ColorTween(
              begin: Colors.lightBlue.shade500, end: Colors.lightBlue.shade900))
      ..tween(
          "color2",
          duration: const Duration(seconds: 3),
          ColorTween(begin: Colors.blue.shade200, end: Colors.blue.shade600));

    return MirrorAnimationBuilder(
      tween: tween,
      duration: tween.duration,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                const Color.fromARGB(165, 114, 248, 128),
                Colors.blueAccent.shade100
              ])),
          child: child,
        );
      },
    );
  }
}

class FancyBackgroundApp extends StatelessWidget {
  final Widget child;
  const FancyBackgroundApp({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(child: AnimatedBackground()),
        onBottom(const AnimatedWave(
          height: 180,
          speed: 1.0,
        )),
        onBottom(const AnimatedWave(
          height: 120,
          speed: 0.9,
          offset: pi,
        )),
        onBottom(const AnimatedWave(
          height: 220,
          speed: 1.2,
          offset: pi / 2,
        )),
        child
      ],
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final UserStore _userStore = getIt<UserStore>();
  final ThemeStore _themeStore = getIt<ThemeStore>();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 3500), vsync: this)
      ..addListener(() async {
        if (_controller.isCompleted) {
          await _controller.playReverse(
              duration: const Duration(milliseconds: 3500));
          await Future.delayed(const Duration(seconds: 1));
          await _controller.play();
        }
      });
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
      await Future.delayed(const Duration(seconds: 15));
//      await controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
      _controller.stop();
    } finally {
      try {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute2(
                routeName: _userStore.isLoggedIn ? Routes.home : Routes.login));
      // ignore: empty_catches
      } catch (e) {}
    }
  }

  @override
  void dispose() {
        _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeStore.darkMode ? Colors.black : Colors.white,
      body: FancyBackgroundApp(
        child: GestureDetector(
          onTap: () {
            _controller.stop();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute2(
                    routeName:
                        _userStore.isLoggedIn ? Routes.home : Routes.login));
          },
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/animations/splash_animation.json', // Replace with the path to your Lottie JSON file
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 200
                          : 400, // Adjust the width and height as needed
                      height: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 200
                          : 400,
                      repeat:
                          true, // Set to true if you want the animation to loop
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
                      : const SizedBox(
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
                      : const SizedBox(
                          width: 0,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
