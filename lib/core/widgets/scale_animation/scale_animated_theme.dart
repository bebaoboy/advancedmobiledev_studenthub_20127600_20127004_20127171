import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Animated version of [Theme] which automatically transitions the colors,
/// etc, over a given duration whenever the given theme changes.
///
/// Here's an illustration of what using this widget looks like, using a [curve]
/// of [Curves.elasticInOut].
/// {@animation 250 266 https://flutter.github.io/assets-for-api-docs/assets/widgets/animated_theme.mp4}
///
/// See also:
///
///  * [Theme], which [ScaleAnimatedTheme] uses to actually apply the interpolated
///    theme.
///  * [ThemeData], which describes the actual configuration of a theme.
///  * [MaterialApp], which includes an [ScaleAnimatedTheme] widget configured via
///    the [MaterialApp.theme] argument.
class ScaleAnimatedTheme extends ImplicitlyAnimatedWidget {
  /// Creates an animated theme.
  ///
  /// By default, the theme transition uses a linear curve. The [data] and
  /// [child] arguments must not be null.
  const ScaleAnimatedTheme({
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
  _AnimatedThemeState createState() => _AnimatedThemeState();
}

class _AnimatedThemeState extends AnimatedWidgetBaseState<ScaleAnimatedTheme> {
  ThemeDataTween? _data;

  static const foregroundKey = Key('Key2');

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    // TODO(ianh): Use constructor tear-offs when it becomes possible
    _data = visitor(
        _data, widget.data, (dynamic value) => ThemeDataTween(begin: value)) as ThemeDataTween?;
    assert(_data != null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        animation.value != 0
            ? ScaleTransition(
                scale: animation,
                child: Theme(
                  key: foregroundKey,
                  data: widget.data,
                  child: widget.child,
                ),
              )
            : Theme(
                key: foregroundKey,
                data: _data!.evaluate(animation),
                child: widget.child,
              ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ThemeDataTween>('data', _data,
        showName: false, defaultValue: null));
  }
}
