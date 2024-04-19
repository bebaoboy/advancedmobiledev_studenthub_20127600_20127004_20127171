import 'package:boilerplate/core/widgets/pip/picture_in_picture.dart';
import 'package:boilerplate/core/widgets/pip/pip_widget.dart';
import 'package:flutter/material.dart';

class NavigatablePiPWidget extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final Function onPiPClose;
  final double elevation;
  final double pipBorderRadius;

  static void closePiP() {
    PictureInPicture.stopPiP(true);
  }

  const NavigatablePiPWidget({
    super.key,
    required this.onPiPClose,
    this.pipBorderRadius = 12,
    this.elevation = 10,
    required this.builder,
  });

  @override
  State<NavigatablePiPWidget> createState() => _NavigatablePiPWidgetState();
}

class _NavigatablePiPWidgetState extends State<NavigatablePiPWidget> {
  @override
  Widget build(BuildContext context) {
    return HeroControllerScope.none(
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              return PiPWidget(
                onPiPClose: widget.onPiPClose,
                pipBorderRadius: widget.pipBorderRadius,
                elevation: widget.elevation,
                child: widget.builder(context),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
