// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:badges/badges.dart';
import 'package:boilerplate/utils/routes/navbar_router.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// A customized badge/dot class for NavbarRouter.
/// Based on [badges] package of flutter.
class NavbarBadge {
  /// Your badge content, can be number (as string) of text.
  /// Please choose either [badgeText] or [badgeContent].
  ///
  /// If **[badgeContent]** is not null, **[badgeText]** will be **ignored**.
  final String badgeText;

  /// Text style for badge
  final TextStyle? badgeTextStyle;

  /// Content inside badge. Please choose either [badgeText] or [badgeContent].
  ///
  /// If not null, **[badgeText]** will be **ignored**.
  final Widget? badgeContent;

  /// Allows you to hide or show entire badge.
  /// The default value is false.
  final bool showBadge;

  /// Duration of the badge animations when the [badgeContent] changes.
  /// The default value is Duration(milliseconds: 500).
  final Duration animationDuration;

  /// Background color of the badge.
  /// The default value is white.
  final Color? color;

  /// Text color of the badge.
  /// The default value is black.
  final Color? textColor;

  /// Contains all badge style properties.
  ///
  /// Allows to set the shape to this [badgeContent].
  /// The default value is [BadgeShape.circle].
  /// ```
  /// final BadgeShape shape;
  /// ```
  /// Allows to set border radius to this [badgeContent].
  /// The default value is [BorderRadius.zero].
  /// ```
  /// final BorderRadius borderRadius;
  /// ```
  /// Background color of the badge.
  /// If [gradient] is not null, this property will be ignored.
  /// ```
  /// final Color badgeColor;
  /// ```
  /// Allows to set border side to this [badgeContent].
  /// The default value is [BorderSide.none].
  /// ```
  /// final BorderSide borderSide;
  /// ```
  /// The size of the shadow below the badge.
  /// ```
  /// final double elevation;
  /// ```
  /// Background gradient color of the badge.
  /// Will be used over [badgeColor] if not null.
  /// ```
  /// final BadgeGradient? badgeGradient;
  /// ```
  /// Background gradient color of the border badge.
  /// Will be used over [borderSide.color] if not null.
  /// ```
  /// final BadgeGradient? borderGradient;
  /// ```
  /// Specifies padding/**size** for [badgeContent].
  /// The default value is EdgeInsets.all(5.0).
  /// ```
  /// final EdgeInsetsGeometry padding;
  /// ```
  final BadgeStyle badgeStyle;

  /// Contains all badge animation properties.
  ///
  /// True to animate badge on [badgeContent] change.
  /// False to disable animation.
  /// Default value is true.
  /// ```
  /// final bool toAnimate;
  /// ```
  /// Duration of the badge animations when the [badgeContent] changes.
  /// The default value is Duration(milliseconds: 500).
  /// ```
  /// final Duration animationDuration;
  /// ```
  /// Duration of the badge appearance and disappearance fade animations.
  /// Fade animation is created with [AnimatedOpacity].
  ///
  /// Some of the [BadgeAnimationType] cannot be used for appearance and disappearance animation.
  /// E.g. [BadgeAnimationType.scale] can be used, but [BadgeAnimationType.rotation] cannot be used.
  /// That is why we need fade animation and duration for it when it comes to appearance and disappearance
  /// of these "non-disappearing" animations.
  ///
  /// There is a thing: you need this duration to NOT be longer than [animationDuration]
  /// if you want to use the basic animation as appearance and disappearance animation.
  ///
  /// Set this to zero to skip the badge appearance and disappearance animations
  /// The default value is Duration(milliseconds: 200).
  /// ```
  /// final Duration disappearanceFadeAnimationDuration;
  /// ```
  /// Type of the animation for badge
  /// The default value is [BadgeAnimationType.slide].
  /// ```
  /// final BadgeAnimationType animationType;
  /// ```
  /// Make it true to have infinite animation
  /// False to have animation only when [badgeContent] is changed
  /// The default value is false
  /// ```
  /// final bool loopAnimation;
  /// ```
  /// Controls curve of the animation
  /// ```
  /// final Curve curve;
  /// ```
  /// Used only for [SizeTransition] animation
  /// The default value is Axis.horizontal
  /// ```
  /// final Axis? sizeTransitionAxis;
  /// ```
  /// Used only for [SizeTransition] animation
  /// The default value is 1.0
  /// ```
  /// final double? sizeTransitionAxisAlignment;
  /// ```
  /// Used only for [SlideTransition] animation
  /// The default value is
  /// ```
  /// SlideTween(
  ///   begin: const Offset(-0.5, 0.9),
  ///   end: const Offset(0.0, 0.0),
  /// );
  /// ```
  /// ```
  /// final SlideTween? slideTransitionPositionTween;
  /// ```
  /// Used only for changing color animation.
  /// The default value is [Curves.linear]
  /// ```
  /// final Curve colorChangeAnimationCurve;
  /// ```
  /// Used only for changing color animation.
  /// The default value is [Duration.zero], meaning that
  /// no animation will be applied to color change by default.
  /// ```
  /// final Duration colorChangeAnimationDuration;
  /// ```
  /// This one is interesting.
  /// Some animations use [AnimatedOpacity] to animate appearance and disappearance of the badge.
  /// E.x. how would you animate disappearance of [BadgeAnimationType.rotation]? We should use [AnimatedOpacity] for that.
  /// But sometimes you may need to disable this fade appearance/disappearance animation.
  /// You can do that by setting this to false.
  /// Using disappearanceFadeAnimationDuration: Duration.zero is not correct, this will remove the animation entirely
  /// ```
  /// final bool appearanceDisappearanceFadeAnimationEnabled;
  /// ```
  final BadgeAnimation? badgeAnimation;

  /// Allows to set custom position of badge according to [child].
  /// If [child] is null, it doesn't make sense to use it.
  final BadgePosition? position;

  /// Can make your [badgeContent] interactive.
  /// The default value is false.
  /// Make it true to make badge intercept all taps
  /// Make it false and all taps will be passed through the badge
  final bool ignorePointer;

  /// Allows to edit fit parameter to [Stack] widget.
  /// The default value is [StackFit.loose].
  final StackFit stackFit;

  /// Will be called when you tap on the badge
  /// Important: if the badge is outside of the child
  /// the additional padding will be applied to make the full badge clickable
  final Function()? onTap;

  final Key? key;

  /// Use padding of [badgeStyle] or fontSize of [badgeTextStyle] to change size of the badge/dot.
  const NavbarBadge({
    this.key,
    this.badgeText = "",
    this.showBadge = false,
    this.animationDuration = const Duration(milliseconds: 500),
    this.color = Colors.white,
    this.textColor,
    this.badgeStyle = const BadgeStyle(),
    this.badgeAnimation = const BadgeAnimation.slide(),
    this.position,
    this.ignorePointer = false,
    this.stackFit = StackFit.loose,
    this.onTap,
    this.badgeContent,
    this.badgeTextStyle,
  });

  @override
  int get hashCode =>
      badgeText.hashCode ^
      showBadge.hashCode ^
      animationDuration.hashCode ^
      color.hashCode ^
      textColor.hashCode ^
      badgeStyle.hashCode ^
      badgeAnimation.hashCode ^
      position.hashCode ^
      ignorePointer.hashCode ^
      stackFit.hashCode ^
      onTap.hashCode ^
      badgeContent.hashCode ^
      badgeStyle.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NavbarBadge &&
            runtimeType == other.runtimeType &&
            badgeText == other.badgeText &&
            showBadge == other.showBadge &&
            animationDuration == other.animationDuration &&
            color == other.color &&
            textColor == other.textColor &&
            badgeStyle == other.badgeStyle &&
            badgeAnimation == other.badgeAnimation &&
            position == other.position &&
            ignorePointer == other.ignorePointer &&
            stackFit == other.stackFit &&
            onTap == other.onTap &&
            badgeContent == other.badgeContent &&
            badgeStyle == other.badgeStyle;
  }

  NavbarBadge copyWith({
    String? badgeText,
    TextStyle? badgeTextStyle,
    Widget? badgeContent,
    bool? showBadge,
    Duration? animationDuration,
    Color? color,
    Color? textColor,
    BadgeStyle? badgeStyle,
    BadgeAnimation? badgeAnimation,
    BadgePosition? position,
    bool? ignorePointer,
    StackFit? stackFit,
    Function()? onTap,
    Key? key,
  }) {
    return NavbarBadge(
      badgeText: badgeText ?? this.badgeText,
      badgeTextStyle: badgeTextStyle ?? this.badgeTextStyle,
      badgeContent: badgeContent ?? this.badgeContent,
      showBadge: showBadge ?? this.showBadge,
      animationDuration: animationDuration ?? this.animationDuration,
      color: color ?? this.color,
      textColor: textColor ?? this.textColor,
      badgeStyle: badgeStyle ?? this.badgeStyle,
      badgeAnimation: badgeAnimation ?? this.badgeAnimation,
      position: position ?? this.position,
      ignorePointer: ignorePointer ?? this.ignorePointer,
      stackFit: stackFit ?? this.stackFit,
      onTap: onTap ?? this.onTap,
      key: key ?? this.key,
    );
  }
}

class NavbarNotifier2 extends ChangeNotifier {
  static final NavbarNotifier2 _singleton = NavbarNotifier2._internal();

  factory NavbarNotifier2() {
    return _singleton;
  }

  NavbarNotifier2._internal();

  static int? _index;

  static int get currentIndex => _index ?? 0;

  static int? _length;

  static set length(int x) {
    _length = x;
  }

  static Function? setStateCb;

  static int get length => _length!;

  static ValueNotifier<bool> bottomNavbarVisibilityListener =
      ValueNotifier(false);

  static List<int> _navbarStackHistory = [];

  static List<GlobalKey<NavigatorState>> _keys = [];

  /// Set to true will hide the badges when the tap on the navbar icon.
  static bool hideBadgeOnPageChanged = true;

  /// List of badges of the navbar
  static List<NavbarBadge> get badges => _badges;
  static List<NavbarBadge> _badges = [];

  /// Use to update a badge using its [index], e.g: update the number, text...
  ///
  /// If you want to hide badges on a specific index, use [makeBadgeVisible]
  ///
  static void updateBadge(int index, NavbarBadge badge) {
    if (index < 0 || index >= length) return;
    print("update badge $index ${badge.badgeText}");
    _badges[index] = badge;

    // We don't navigate to that item when we update its badge. So cannot use this.
    // NavbarNotifier.index = index;
    _singleton.notify();
  }

  /// Use to set the visibility of a badge using its [index].
  static void makeBadgeVisible(int index, bool visible) {
    if (index < 0 || index >= length) return;
    _badges[index] = _badges[index].copyWith(showBadge: visible);
    _singleton.notify();
  }

  static void setKeys(List<GlobalKey<NavigatorState>> value) {
    _keys = value;
  }

  /// The only place that init the badges.
  static void setBadges(List<NavbarBadge>? badgeList) {
    if (badgeList != null) {
      _badges = badgeList;
    }
  }

  static final List<Function(int)> _indexChangeListeners = [];

  static List<GlobalKey<NavigatorState>> get keys => _keys;

  static set index(int x) {
    _index = x;
    if (_badges.isNotEmpty && _badges[x].showBadge && hideBadgeOnPageChanged) {
      _badges[x] = _badges[x].copyWith(showBadge: false);
    }
    if (_navbarStackHistory.contains(x)) {
      _navbarStackHistory.remove(x);
    }
    _navbarStackHistory.add(x);
    _notifyIndexChangeListeners(x);
    _singleton.notify();
  }

  static List<int> get stackHistory => _navbarStackHistory;

  static bool get isNavbarHidden => bottomNavbarVisibilityListener.value;

  static set hideBottomNavBar(bool x) {
    bottomNavbarVisibilityListener.value = x;
    if (!x) {
      toastification.dismissAll();
    }
    _singleton.notify();
  }

  static set setStackHistory(List<int> x) {
    if (x.isEmpty) return;
    _navbarStackHistory = x;
  }

  static bool isCurrentNavbarHistoryStackSemiEmpty() {
    return _navbarStackHistory.length <= 1;
  }

  // pop routes from the nested navigator stack and not the main stack
  // this is done based on the currentIndex of the bottom navbar
  // if the backButton is pressed on the initial route the app will be terminated
  static FutureOr<bool> onBackButtonPressed(
      {BackButtonBehavior behavior =
          BackButtonBehavior.rememberHistory}) async {
    //print(stackHistory);
    bool exitingApp = true;
    NavigatorState? currentState = _keys[_index!].currentState;
    if (currentState != null && currentState.canPop()) {
      currentState.pop();
      exitingApp = false;
    } else {
      if (behavior == BackButtonBehavior.rememberHistory) {
        if (_navbarStackHistory.length > 1) {
          _navbarStackHistory.removeLast();
          _index = _navbarStackHistory.last;
          //index = _index!;
          //print("pop${_index!}");
          // _notifyIndexChangeListeners(_index!);
          // _singleton.notify();
          exitingApp = false;
        } else {
          return exitingApp;
        }
      } else {
        return exitingApp;
      }
    }
    return exitingApp;
  }

  /// pops the current route from a specific navigator stack
  /// by passing the index of the navigator stack to pop from.
  static void popRoute(int index) {
    NavigatorState? currentState;
    currentState = _keys[index].currentState;
    if (currentState != null && currentState.canPop()) {
      currentState.pop();
    }
  }

  /// Use this method to programmatically push a route to a specific navigator stack
  /// by passing the route name and the index of the navigator stack
  static void pushNamed(String route, int x, Object? arguments) {
    NavigatorState? currentState;
    currentState = _keys[x].currentState;
    if (currentState != null) {
      currentState.pushNamed(route, arguments: arguments);
    }
  }

  static Future push(int x, BuildContext context, Route route) async {
    NavigatorState? currentState;
    currentState = _keys[x].currentState;
    if (currentState != null) {
      return await currentState.push(route);
    }
  }

  /// pops all routes except first, if there are more than 1 route in each navigator stack
  static bool popAllRoutes(int index) {
    NavigatorState? currentState;
    for (int i = 0; i < _keys.length; i++) {
      if (_index == i) {
        currentState = _keys[i].currentState;
      }
    }
    if (currentState != null && currentState.canPop()) {
      currentState.popUntil((route) => route.isFirst);
      return true;
    }
    return false;
  }

  // adds a listener to the list of listeners
  static void addIndexChangeListener(Function(int) listener) {
    _indexChangeListeners.add(listener);
  }

  // removes the last listener that was added
  static void removeLastListener() {
    if (_indexChangeListeners.isEmpty) return;
    _indexChangeListeners.removeLast();
  }

  // removes all listeners
  static void removeAllListeners() {
    if (_indexChangeListeners.isEmpty) return;
    _indexChangeListeners.clear();
  }

  static void _notifyIndexChangeListeners(int index) {
    if (_indexChangeListeners.isEmpty) return;
    for (Function(int) listener in _indexChangeListeners) {
      listener(index);
    }
  }

  static void refresh() {
    _singleton.notify();
    if (setStateCb != null) setStateCb!();
  }

  void notify() {
    notifyListeners();
  }

  static void hideSnackBar(context) {
    try {
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      print("cannot hide nav because snackbar is building");
    }
  }

  static void _showMessage(BuildContext context, String message,
      {
      /// margin from bottom
      double? bottom,

      /// whether the snackbar should persist or not
      /// the persistence duration
      Duration duration = const Duration(seconds: 3),
      bool showCloseIcon = true,

      /// Action label is shown when both [onPressed] and [actionLabel] are not null
      String? actionLabel,
      void Function()? onPressed,
      void Function()? onClosed}) {
    try {
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              dismissDirection: DismissDirection.none,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              behavior: bottom != null
                  ? SnackBarBehavior.floating
                  : SnackBarBehavior.fixed,
              content: Text(
                message,
              ),
              duration: duration,
              margin: bottom != null ? EdgeInsets.only(bottom: bottom) : null,
              showCloseIcon: showCloseIcon,
              action: actionLabel == null || onPressed == null
                  ? null
                  : SnackBarAction(
                      label: actionLabel,
                      onPressed: onPressed,
                    ),
            ),
          )
          .closed
          .whenComplete(() {
        if (onClosed != null) {
          onClosed();
        }
      });
    } catch (e) {
      print("cannot show nav because snackbar is building");
    }
  }

  static void showSnackBar(BuildContext context, String message,
      {
      /// margin from bottom of navbar defaults to [kNavbarHeight]
      double? bottom,
      String? actionLabel,
      bool showCloseIcon = true,
      Duration duration = const Duration(seconds: 1),
      Function? onActionPressed,
      Function? onClosed}) {
    _showMessage(
      context,
      message,
      showCloseIcon: showCloseIcon,
      actionLabel: actionLabel,
      bottom: bottom ?? 58,
      duration: duration,
      onPressed: () {
        if (onActionPressed != null) {
          onActionPressed();
        }
      },
      onClosed: () {
        if (onClosed != null) {
          onClosed();
        }
      },
    );
  }

  static void clear() {
    _indexChangeListeners.clear();
    _navbarStackHistory.clear();
    _keys.clear();
    // _index = null;
    // _length = null;
  }
}
