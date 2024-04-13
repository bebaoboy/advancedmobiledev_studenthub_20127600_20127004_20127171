// ignore_for_file: unused_field, unused_element, avoid_print, empty_catches

import 'dart:async';
import 'dart:math';

import 'package:boilerplate/core/widgets/refresh_indicator/indicators/ice_cream_indicator.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class Cloud {
  static const light = Color.fromARGB(255, 185, 222, 150);
  static const dark = Color(0xFF6AABBF);
  static const normal = Color(0xFFACCFDA);
  static const red = Color.fromARGB(255, 203, 158, 158);

  static const assets = [
    "assets/plane_indicator/cloud1.png",
    "assets/plane_indicator/cloud2.png",
    "assets/plane_indicator/cloud3.png",
    "assets/plane_indicator/cloud4.png",
  ];

  AnimationController? controller;
  final Color color;
  final AssetImage image;
  final double width;
  final double wR = Random().nextInt(65) + 30.0;
  final double dy;
  final int dry = 1;
  final double r = Random().nextInt(1000).truncateToDouble();
  late final Duration dr;
  final double r2 = (Random().nextDouble()).clamp(0, 1);
  final double initialValue;
  final Duration duration;

  Cloud({
    required this.color,
    required this.image,
    required this.width,
    required this.dy,
    required this.initialValue,
    required this.duration,
  }) {
    dr = Duration(milliseconds: Random().nextInt(3000) + 2000);
  }
}

class PlaneIndicator extends StatefulWidget {
  final Widget child;
  final bool leadingScrollIndicatorVisible;
  final bool trailingScrollIndicatorVisible;
  final RefreshCallback onRefresh;
  const PlaneIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.leadingScrollIndicatorVisible = false,
    this.trailingScrollIndicatorVisible = false,
    this.offsetToArmed = 80.0,
  });
  final double offsetToArmed;

  @override
  State<PlaneIndicator> createState() => _PlaneIndicatorState();
}

class _PlaneIndicatorState extends State<PlaneIndicator>
    with TickerProviderStateMixin {
  final _planeTween = CurveTween(curve: Curves.easeInOut);
  late AnimationController _planeController;

  @override
  void initState() {
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _spoonController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _setupCloudsAnimationControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheImages());
    super.initState();
  }

  void _precacheImages() {
    for (final config in _clouds) {
      unawaited(precacheImage(config.image, context));
    }
  }

  static final _clouds = [
    Cloud(
      color: Cloud.dark,
      initialValue: 0.6,
      dy: 10.0,
      image: AssetImage(Cloud.assets[1]),
      width: 100,
      duration: const Duration(milliseconds: 1200),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 25.0,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
  ];

  void _setupCloudsAnimationControllers() {
    for (final cloud in _clouds) {
      cloud.controller = AnimationController(
        vsync: this,
        duration: cloud.duration,
        value: cloud.initialValue,
      );
    }
  }

  void _startPlaneAnimation() {
    _planeController.repeat(reverse: true);
  }

  void _stopPlaneAnimation() {
    _planeController
      ..stop()
      ..animateTo(0.0, duration: const Duration(milliseconds: 100));
  }

  void _stopCloudAnimation() {
    for (final cloud in _clouds) {
      cloud.controller!.stop();
    }
  }

  void _startCloudAnimation() {
    for (final cloud in _clouds) {
      cloud.controller!.repeat();
    }
  }

  void _disposeCloudsControllers() {
    for (final cloud in _clouds) {
      cloud.controller!.dispose();
    }
  }

  @override
  void dispose() {
    try {
      _planeController.stop();
      // _disposeCloudsControllers();
      _spoonController.stop();
    } catch (e) {}
    super.dispose();
  }

  Widget _buildImage(IndicatorController controller, ParallaxConfig asset) {
    return Transform.translate(
      offset: Offset(
        0,
        -(asset.level * (controller.value.clamp(1.0, 1.5) - 1.0) * 20) + 10,
      ),
      child: OverflowBox(
        maxHeight: _imageSize,
        minHeight: _imageSize * 0.5,
        child: Image(
          image: asset.image,
          fit: BoxFit.contain,
          height: _imageSize * 0.5,
        ),
      ),
    );
  }

  static const _assets = <ParallaxConfig>[
    ParallaxConfig(
      image: AssetImage("assets/ice_cream_indicator/cup2.png"),
      level: 0,
    ),
    ParallaxConfig(
      image: AssetImage("assets/ice_cream_indicator/spoon.png"),
      level: 1,
    ),
    ParallaxConfig(
      image: AssetImage("assets/ice_cream_indicator/ice1.png"),
      level: 3,
    ),
    ParallaxConfig(
      image: AssetImage("assets/ice_cream_indicator/ice3.png"),
      level: 4,
    ),
    ParallaxConfig(
      image: AssetImage("assets/ice_cream_indicator/ice2.png"),
      level: 2,
    ),
    ParallaxConfig(
      image: AssetImage("assets/ice_cream_indicator/cup.png"),
      level: 0,
    ),
    ParallaxConfig(
      image: AssetImage("assets/ice_cream_indicator/mint.png"),
      level: 5,
    ),
  ];

  bool complete = false;
  // static const _indicatorSize = 150.0;
  static const _imageSize = 140.0;

  late AnimationController _spoonController;
  final _spoonTween = CurveTween(curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final plane = AnimatedBuilder(
          animation: _planeController,
          child: Image.asset(
            "assets/plane_indicator/plane.png",
            width: 172,
            height: 50,
            fit: BoxFit.contain,
          ),
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: Offset(0.0,
                  10 * (0.5 - _planeTween.transform(_planeController.value))),
              child: child,
            );
          },
        );
        return CustomRefreshIndicator(
          // durations: const RefreshIndicatorDurations(
          //   completeDuration: Duration(seconds: 2),
          // ),
          offsetToArmed: widget.offsetToArmed,
          autoRebuild: false,
          onStateChanged: (change) {
            try {
              // if (change.didChange(
              //   from: IndicatorState.armed,
              //   to: IndicatorState.settling,
              // )) {
              //   // _spoonController.stop();
              //   _startCloudAnimation();
              //   _startPlaneAnimation();
              //   print("plane start");
              // }
              // if (change.didChange(
              //   from: IndicatorState.loading,
              // )) {
              //   _stopPlaneAnimation();
              //   print("plane stop");
              // }
              // if (change.didChange(
              //   to: IndicatorState.idle,
              // )) {
              //   _stopCloudAnimation();
              //   print("cloud stop");
              //   setState(() {
              //     complete = false;
              //   });
              //   print("ice cream stop");
              // }
              // if (change.didChange(to: IndicatorState.complete)) {
              //   setState(() {
              //     complete = true;
              //   });
              //   // _spoonController.repeat(reverse: true);
              //   // print("ice cream start");

              //   /// set [_renderCompleteState] to false when controller.state become idle
              // }
              if (change.didChange(
                from: IndicatorState.armed,
                to: IndicatorState.settling,
              )) {
                _startCloudAnimation();
                _startPlaneAnimation();
              }
              if (change.didChange(
                from: IndicatorState.loading,
              )) {
                _stopPlaneAnimation();
              }
              if (change.didChange(
                to: IndicatorState.idle,
              )) {
                _stopCloudAnimation();
              }
            } catch (e) {}
          },
          // trailingScrollIndicatorVisible: widget.trailingScrollIndicatorVisible,
          // leadingScrollIndicatorVisible: widget.leadingScrollIndicatorVisible,
          onRefresh: widget.onRefresh,
          builder: (BuildContext context, Widget child,
              IndicatorController controller) {
            return AnimatedBuilder(
              animation: controller,
              child: child,
              builder: (context, child) {
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: <Widget>[
                    if (!controller.side.isNone)
                      Container(
                        height: widget.offsetToArmed * controller.value * 3,
                        color: Colors.transparent,
                        width: double.infinity,
                        child: AnimatedBuilder(
                          animation: _clouds.first.controller!,
                          builder: (BuildContext context, Widget? child) {
                            return Stack(
                              clipBehavior: Clip.hardEdge,
                              children: <Widget>[
                                for (final cloud in _clouds)
                                  Transform.translate(
                                    offset: Offset(
                                      (((screenWidth + cloud.width) *
                                              cloud.controller!.value) -
                                          cloud.width),
                                      cloud.dy * controller.value * 2,
                                    ),
                                    child: OverflowBox(
                                      minWidth: cloud.width,
                                      minHeight: cloud.width,
                                      maxHeight: cloud.width,
                                      maxWidth: cloud.width,
                                      alignment: Alignment.topLeft,
                                      child: Image(
                                        color: cloud.color,
                                        image: cloud.image,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                /// plane
                                // if (complete) // icecream (complete widget)
                                //   for (int i = 0; i < _assets.length; i++)

                                //     /// checking for spoon build animation and attaching the spoon controller
                                //     if (i == 1)
                                //       AnimatedBuilder(
                                //         animation: _spoonController,
                                //         child:
                                //             _buildImage(controller, _assets[i]),
                                //         builder: (context, child) {
                                //           return Transform.rotate(
                                //             angle: (-_spoonTween.transform(
                                //                     _spoonController.value)) *
                                //                 1.25,
                                //             child: child,
                                //           );
                                //         },
                                //       )
                                //     else
                                //       _buildImage(controller, _assets[i])
                                // else
                                Center(
                                  child: OverflowBox(
                                    maxWidth: 172,
                                    minWidth: 172,
                                    maxHeight: 50,
                                    minHeight: 50,
                                    alignment: Alignment.center,
                                    child: plane,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    Transform.translate(
                      offset: Offset(0.0, widget.offsetToArmed * controller.value),
                      child: child,
                    ),
                  ],
                );
              },
            );
          },
          child: widget.child,
        );
      },
    );
  }
}
