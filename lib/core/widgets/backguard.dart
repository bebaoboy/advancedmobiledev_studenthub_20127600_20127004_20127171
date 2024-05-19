// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';

typedef CanGoBackCallback = Future<bool> Function();

/// Allows the user to close the app by double tapping the back-button.
///
/// You must specify a [SnackBar], so it can be shown when the user taps the
/// back-button.
///
/// Since the back-button is an Android feature, this Widget is going to be
/// nothing but the own [child] if the current platform is anything but Android.
class BackGuard extends StatefulWidget {
  /// The [SnackBar] shown when the user taps the back-button.
  /// The widget below this widget in the tree.
  final Widget child;
  final Future<bool> Function()? onWillPop;

  /// Creates a widget that allows the user to close the app by double tapping
  /// the back-button.
  const BackGuard({super.key, required this.child, this.onWillPop});

  @override
  BackGuardState createState() => BackGuardState();
}

class BackGuardState extends State<BackGuard> {
  /// Completer that gets completed whenever the current snack-bar is closed.
  var _closedCompleter = Completer<SnackBarClosedReason>()
    ..complete(SnackBarClosedReason.remove);

  /// Returns whether the current platform is Android.
  bool get _isAndroid => Theme.of(context).platform == TargetPlatform.android;

  /// Returns whether the [BackGuard.snackBar] is currently visible.
  bool get _isSnackBarVisible => !_closedCompleter.isCompleted;

  /// Returns whether the next back navigation of this route will be handled
  /// internally.
  ///
  /// Returns true when there's a widget that inserted an entry into the
  /// local-history of the current route, in order to handle pop. This is done
  /// by [Drawer], for example, so it can close on pop.
  bool get _willHandlePopInternally =>
      ModalRoute.of(context)?.willHandlePopInternally ?? false;

  @override
  Widget build(BuildContext context) {
    assert(() {
      _ensureThatContextContainsScaffold();
      return true;
    }());

    if (_isAndroid) {
      return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }
          var p = await widget.onWillPop!();
          print(p);
          if (widget.onWillPop != null && !p) return;
          if (await _handleWillPop()) {
            if (!mounted) return;
            if (!Navigator.of(context).canPop()) {
              MoveToBackground.moveTaskToBack();
            } else {
              Navigator.of(context).pop();
            }
          }
        },
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }

  /// Handles [WillPopScope.onWillPop].
  Future<bool> _handleWillPop() async {
    if (_isSnackBarVisible || _willHandlePopInternally) {
      return true;
    } else {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.hideCurrentSnackBar();
      _closedCompleter = ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
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
            duration: const Duration(seconds: 3),
            showCloseIcon: true,
          ))
          .closed
          .wrapInCompleter();
      return false;
    }
  }

  /// Throws a [FlutterError] if this widget was not wrapped in a [Scaffold].
  void _ensureThatContextContainsScaffold() {
    if (Scaffold.maybeOf(context) == null) {
      throw FlutterError(
        '`BackGuard` must be wrapped in a `Scaffold`.',
      );
    }
  }
}

extension<T> on Future<T> {
  /// Returns a [Completer] that allows checking for this [Future]'s completion.
  ///
  /// See https://stackoverflow.com/a/69731240/6696558.
  Completer<T> wrapInCompleter() {
    final completer = Completer<T>();
    then(completer.complete).catchError(completer.completeError);
    return completer;
  }
}
