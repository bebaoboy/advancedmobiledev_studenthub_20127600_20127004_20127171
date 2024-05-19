import 'package:boilerplate/core/widgets/swipable_page_route/src/page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
              return
                  // SharedAxisTransition(
                  //   fillColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.01),
                  //   animation: animation,
                  //   secondaryAnimation: secondaryAnimation,
                  //   transitionType: SharedAxisTransitionType.scaled,
                  //   child: child,
                  // );
                  SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation.drive(Tween(begin: 0.9, end: 1.0)),
                        child: child,
                      ));
              // FadeTransition(
              //   opacity: animation,
              //   child: child,
              // );
            });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
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
      SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation.drive(Tween(begin: 0.9, end: 1.0)),
            child: child,
          )),
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
