// ignore_for_file: deprecated_member_use

import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

typedef CanGoBackCallback = Future<bool> Function();

class BackGuard extends StatefulWidget {
  const BackGuard({
    required this.child,
    this.duration = const Duration(seconds: 3),
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  State<BackGuard> createState() => _BackGuardState();
}

class _BackGuardState extends State<BackGuard> {
  DateTime oldTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var newTime = DateTime.now();
        int difference = newTime.difference(oldTime).inMilliseconds;
        oldTime = newTime;
        if (difference < widget.duration.inMilliseconds) {
          print("exit diff $difference");
          ScaffoldMessenger.of(context).clearSnackBars();
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            dismissDirection: DismissDirection.none,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            content: Text(
              Lang.get("exit_confirm"),
            ),
            duration: widget.duration,
            showCloseIcon: true,
          ));
          oldTime = DateTime.now();
          return false;
        }
      },
      child: widget.child,
    );
  }
}
