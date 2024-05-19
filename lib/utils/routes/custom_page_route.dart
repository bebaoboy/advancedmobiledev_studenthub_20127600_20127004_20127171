import 'package:boilerplate/core/widgets/swipable_page_route/src/page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class TransitionPageWrapper extends Page {
//   const TransitionPageWrapper(
//       {required this.screen, required this.transitionKey})
//       : super(key: transitionKey);

//   final Widget screen;
//   final ValueKey transitionKey;

//   @override
//   Route createRoute(BuildContext context) {
//     return PageRouteBuilder(
//         settings: this,
//         transitionDuration: Duration(milliseconds: 800),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return SharedAxisTransition(
//             fillColor: Theme.of(context).cardColor,
//             animation: animation,
//             secondaryAnimation: secondaryAnimation,
//             transitionType: SharedAxisTransitionType.scaled,
//             child: child,
//           );
//         },
//         pageBuilder: (context, animation, secondaryAnimation) {
//           return screen;
//         });
//   }
// }

class MaterialPageRoute2 extends SwipeablePageRoute {
  final String routeName;
  final Object? arguments;
  final Widget? child;

  MaterialPageRoute2({this.routeName = "/", this.arguments, this.child})
      : super(
            canOnlySwipeFromEdge: true,
            settings: RouteSettings(name: routeName, arguments: arguments),
            transitionDuration:
                Duration(milliseconds: arguments != null ? 300 : 500),
            builder: (context) =>
                child ?? getRoute(routeName, context, arguments: arguments),
            transitionBuilder:
                (context, animation, secondaryAnimation, b, child) {
              var realChild = SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation.drive(Tween(begin: 0.9, end: 1.0)),
                    child: child,
                  ));
              return realChild;
              // FadeTransition(
              //   opacity: animation,
              //   child: child,
              // );
            });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    var realChild = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation.drive(Tween(begin: 0.9, end: 1.0)),
          child: child,
        ));
    return super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        // SlideTransition(
        //   position: Tween<Offset>(
        //     begin: Offset(0, 1),
        //     end: Offset.zero,
        //   ).animate(animation),
        //   child: child,
        // )
        // ScaleTransition(scale: animation, child: child,),
        // SharedAxisTransition(
        //   fillColor: Theme.of(context).cardColor,
        //   animation: animation,
        //   secondaryAnimation: secondaryAnimation,
        //   transitionType: SharedAxisTransitionType.scaled,
        //   child: child,
        // ),
        realChild
        // )
        // ScaleTransition(
        //     scale: animation.drive(Tween(begin: 1.5, end: 1.0)
        //         .chain(CurveTween(curve: Curves.ease))),
        //     child: FadeTransition(
        //       opacity: animation.drive(Tween(begin: 0.0, end: 1.0)),
        //       child: child,
        //     ))
        );
  }
}

class PredictiveBackGestureDetector extends StatefulWidget {
  const PredictiveBackGestureDetector({super.key, 
    required this.route,
    required this.builder,
  });

  final WidgetBuilder builder;
  final PredictiveBackRoute route;

  @override
  State<PredictiveBackGestureDetector> createState() =>
      _PredictiveBackGestureDetectorState();
}

class _PredictiveBackGestureDetectorState
    extends State<PredictiveBackGestureDetector> with WidgetsBindingObserver {
  /// True when the predictive back gesture is enabled.
  bool get _isEnabled {
    return widget.route.isCurrent && widget.route.popGestureEnabled;
  }

  /// The back event when the gesture first started.
  PredictiveBackEvent? get startBackEvent => _startBackEvent;
  PredictiveBackEvent? _startBackEvent;
  set startBackEvent(PredictiveBackEvent? startBackEvent) {
    if (_startBackEvent != startBackEvent && mounted) {
      setState(() {
        _startBackEvent = startBackEvent;
      });
    }
  }

  /// The most recent back event during the gesture.
  PredictiveBackEvent? get currentBackEvent => _currentBackEvent;
  PredictiveBackEvent? _currentBackEvent;
  set currentBackEvent(PredictiveBackEvent? currentBackEvent) {
    if (_currentBackEvent != currentBackEvent && mounted) {
      setState(() {
        _currentBackEvent = currentBackEvent;
      });
    }
  }

  // Begin WidgetsBindingObserver.

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    final bool gestureInProgress = !backEvent.isButtonEvent && _isEnabled;
    if (!gestureInProgress) {
      return false;
    }

    widget.route.handleStartBackGesture(progress: 1 - backEvent.progress);
    startBackEvent = currentBackEvent = backEvent;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    widget.route
        .handleUpdateBackGestureProgress(progress: 1 - backEvent.progress);
    currentBackEvent = backEvent;
  }

  @override
  void handleCancelBackGesture() {
    widget.route.handleCancelBackGesture();
    startBackEvent = currentBackEvent = null;
  }

  @override
  void handleCommitBackGesture() {
    widget.route.handleCommitBackGesture();
    startBackEvent = currentBackEvent = null;
  }

  // End WidgetsBindingObserver.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

/// Android's predictive back page transition.
class PredictiveBackPageTransition extends StatelessWidget {
  const PredictiveBackPageTransition({super.key, 
    required this.animation,
    required this.secondaryAnimation,
    required this.getIsCurrent,
    required this.child,
  });

  // These values were eyeballed to match the native predictive back animation
  // on a Pixel 2 running Android API 34.
  static const double _scaleFullyOpened = 1.0;
  static const double _scaleStartTransition = 0.95;
  static const double _opacityFullyOpened = 1.0;
  static const double _opacityStartTransition = 0.95;
  static const double _weightForStartState = 65.0;
  static const double _weightForEndState = 35.0;
  static const double _screenWidthDivisionFactor = 20.0;
  static const double _xShiftAdjustment = 8.0;

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final ValueGetter<bool> getIsCurrent;
  final Widget child;

  Widget _secondaryAnimatedBuilder(BuildContext context, Widget? child) {
    final Size size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double xShift =
        (screenWidth / _screenWidthDivisionFactor) - _xShiftAdjustment;

    final bool isCurrent = getIsCurrent();
    final Tween<double> xShiftTween = isCurrent
        ? ConstantTween<double>(0)
        : Tween<double>(begin: xShift, end: 0);
    final Animatable<double> scaleTween = isCurrent
        ? ConstantTween<double>(_scaleFullyOpened)
        : TweenSequence<double>(<TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: Tween<double>(
                begin: _scaleStartTransition,
                end: _scaleFullyOpened,
              ),
              weight: _weightForStartState,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(
                begin: _scaleFullyOpened,
                end: _scaleFullyOpened,
              ),
              weight: _weightForEndState,
            ),
          ]);
    final Animatable<double> fadeTween = isCurrent
        ? ConstantTween<double>(_opacityFullyOpened)
        : TweenSequence<double>(<TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: Tween<double>(
                begin: _opacityFullyOpened,
                end: _opacityStartTransition,
              ),
              weight: _weightForStartState,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(
                begin: _opacityFullyOpened,
                end: _opacityFullyOpened,
              ),
              weight: _weightForEndState,
            ),
          ]);

    return Transform.translate(
      offset: Offset(xShiftTween.animate(secondaryAnimation).value, 0),
      child: Transform.scale(
        scale: scaleTween.animate(secondaryAnimation).value,
        child: Opacity(
          opacity: fadeTween.animate(secondaryAnimation).value,
          child: child,
        ),
      ),
    );
  }

  Widget _primaryAnimatedBuilder(BuildContext context, Widget? child) {
    final Size size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double xShift =
        (screenWidth / _screenWidthDivisionFactor) - _xShiftAdjustment;

    final Animatable<double> xShiftTween =
        TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: _weightForStartState,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: xShift, end: 0.0),
        weight: _weightForEndState,
      ),
    ]);
    final Animatable<double> scaleTween =
        TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: _scaleFullyOpened,
          end: _scaleFullyOpened,
        ),
        weight: _weightForStartState,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: _scaleStartTransition,
          end: _scaleFullyOpened,
        ),
        weight: _weightForEndState,
      ),
    ]);
    final Animatable<double> fadeTween =
        TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: _weightForStartState,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: _opacityStartTransition,
          end: _opacityFullyOpened,
        ),
        weight: _weightForEndState,
      ),
    ]);

    return Transform.translate(
      offset: Offset(xShiftTween.animate(animation).value, 0),
      child: Transform.scale(
        scale: scaleTween.animate(animation).value,
        child: Opacity(
          opacity: fadeTween.animate(animation).value,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: secondaryAnimation,
      builder: _secondaryAnimatedBuilder,
      child: AnimatedBuilder(
        animation: animation,
        builder: _primaryAnimatedBuilder,
        child: child,
      ),
    );
  }
}
