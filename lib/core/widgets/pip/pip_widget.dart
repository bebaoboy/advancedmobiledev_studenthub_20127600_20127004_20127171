import 'package:boilerplate/core/widgets/pip/picture_in_picture.dart';
import 'package:flutter/material.dart';

class PiPWidget extends StatefulWidget {
  final Widget child;
  final Function onPiPClose;
  final double elevation;
  final double pipBorderRadius;

  static void closePiP() {
    PictureInPicture.stopPiP();
  }

  const PiPWidget({
    super.key,
    required this.onPiPClose,
    this.pipBorderRadius = 5,
    this.elevation = 10,
    required this.child,
  });

  @override
  State<PiPWidget> createState() => _PiPWidgetState();
}

class _PiPWidgetState extends State<PiPWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(widget.pipBorderRadius),
      elevation: widget.elevation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.onPiPClose();
    super.dispose();
  }
}
