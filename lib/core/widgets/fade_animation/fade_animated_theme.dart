import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Animated version of [Theme] which automatically transitions the colors,
/// etc, over a given duration whenever the given theme changes.
///
/// Here's an illustration of what using this widget looks like, using a [curve]
/// of [Curves.elasticInOut].
/// {@animation 250 266 https://flutter.github.io/assets-for-api-docs/assets/widgets/animated_theme.mp4}
///
/// See also:
///
///  * [Theme], which [FadeAnimatedTheme] uses to actually apply the interpolated
///    theme.
///  * [ThemeData], which describes the actual configuration of a theme.
///  * [MaterialApp], which includes an [FadeAnimatedTheme] widget configured via
///    the [MaterialApp.theme] argument.
class FadeAnimatedTheme extends ImplicitlyAnimatedWidget {
  /// Creates an animated theme.
  ///
  /// By default, the theme transition uses a linear curve. The [data] and
  /// [child] arguments must not be null.
  const FadeAnimatedTheme({
    super.key,
    required this.data,
    this.isMaterialAppTheme = false,
    super.curve,
    super.duration = kThemeAnimationDuration,
    super.onEnd,
    required this.child,
  // ignore: unnecessary_null_comparison
  })  : assert(child != null),
        // ignore: unnecessary_null_comparison
        assert(data != null);

  /// Specifies the color and typography values for descendant widgets.
  final ThemeData data;

  /// True if this theme was created by the [MaterialApp]. See [Theme.isMaterialAppTheme].
  final bool isMaterialAppTheme;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  // ignore: library_private_types_in_public_api
  _FadeAnimatedThemeState createState() => _FadeAnimatedThemeState();
}

class _FadeAnimatedThemeState
    extends AnimatedWidgetBaseState<FadeAnimatedTheme> {
  ThemeDataTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(
        _data, widget.data, (dynamic value) => ThemeDataTween(begin: value))! as ThemeDataTween?;
    assert(_data != null);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _data!.evaluate(animation),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ThemeDataTween>('data', _data,
        showName: false, defaultValue: null));
  }
}
