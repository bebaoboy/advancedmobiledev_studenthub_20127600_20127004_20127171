import 'package:boilerplate/core/widgets/onboarding/background_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  final int totalPage;
  final List<Widget> background;
  final double speed;
  final double imageVerticalOffset;
  final double imageHorizontalOffset;
  final bool centerBackground;

  const Background({
    super.key,
    required this.imageVerticalOffset,
    required this.child,
    required this.centerBackground,
    required this.totalPage,
    required this.background,
    required this.speed,
    required this.imageHorizontalOffset,
  });

  @override
  Widget build(BuildContext context) {
    assert(background.length == totalPage);
    return Stack(
      children: [
        for (int i = 0; i < totalPage; i++)
          MediaQuery.of(context).size.width > 600
              ? Container()
              : BackgroundImage(
                  centerBackground: centerBackground,
                  imageHorizontalOffset: imageHorizontalOffset,
                  imageVerticalOffset: imageVerticalOffset,
                  id: totalPage - i,
                  speed: speed,
                  background: background[totalPage - i - 1]),
        MediaQuery.of(context).size.width > 600
            ? Positioned.fill(child: child)
            : Positioned.fill(top: 480, child: child),
      ],
    );
  }
}
