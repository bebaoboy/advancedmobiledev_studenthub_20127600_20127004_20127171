import 'dart:math';

import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_dialog/material_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkTransition extends StatefulWidget {
  const DarkTransition(
      {required this.childBuilder,
      Key? key,
      this.offset = Offset.zero,
      this.themeController,
      this.radius,
      this.duration = const Duration(milliseconds: 400),
      this.isDark = false})
      : super(key: key);

  /// Deinfe the widget that will be transitioned
  /// int index is either 1 or 2 to identify widgets, 2 is the top widget
  final Widget Function(BuildContext, int) childBuilder;

  /// the current state of the theme
  final bool isDark;

  /// optional animation controller to controll the animation
  final AnimationController? themeController;

  /// centeral point of the circular transition
  final Offset offset;

  /// optional radius of the circle defaults to [max(height,width)*1.5])
  final double? radius;

  /// duration of animation defaults to 400ms
  final Duration? duration;

  @override
  _DarkTransitionState createState() => _DarkTransitionState();
}

class _DarkTransitionState extends State<DarkTransition>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    _darkNotifier.dispose();
    super.dispose();
  }

  final _darkNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (widget.themeController == null) {
      _animationController =
          AnimationController(vsync: this, duration: widget.duration);
    } else {
      _animationController = widget.themeController!;
    }
  }

  double _radius(Size size) {
    final maxVal = max(size.width, size.height);
    return maxVal * 1.5;
  }

  late AnimationController _animationController;
  double x = 0;
  double y = 0;
  bool isDark = false;
  // bool isBottomThemeDark = true;
  bool isDarkVisible = false;
  late double radius;
  Offset position = Offset.zero;

  ThemeData getTheme(bool dark) {
    if (dark)
      return AppThemeData.darkThemeData;
    else
      return AppThemeData.lightThemeData;
  }

  @override
  void didUpdateWidget(DarkTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    _darkNotifier.value = widget.isDark;
    if (widget.isDark != oldWidget.isDark) {
      if (isDark) {
        _animationController.reverse();
        _darkNotifier.value = false;
      } else {
        _animationController.reset();
        _animationController.forward();
        _darkNotifier.value = true;
      }
      position = widget.offset;
    }
    if (widget.radius != oldWidget.radius) {
      _updateRadius();
    }
    if (widget.duration != oldWidget.duration) {
      _animationController.duration = widget.duration;
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _updateRadius();
  }

  void _updateRadius() {
    final size = MediaQuery.of(context).size;
    if (widget.radius == null)
      radius = _radius(size);
    else
      radius = widget.radius!;
  }

  @override
  Widget build(BuildContext context) {
    isDark = _darkNotifier.value;
    Widget _body(int index) {
      return ValueListenableBuilder<bool>(
          valueListenable: _darkNotifier,
          builder: (BuildContext context, bool isDark, Widget? child) {
            return Theme(
                data: index == 2
                    ? getTheme(!isDarkVisible)
                    : getTheme(isDarkVisible),
                child: widget.childBuilder(context, index));
          });
    }

    return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            children: [
              _body(1),
              ClipPath(
                  clipper: CircularClipper(
                      _animationController.value *
                          radius *
                          (isDark ? 0.8 : 0.9),
                      position),
                  child: _body(2)),
            ],
          );
        });
  }
}

class CircularClipper extends CustomClipper<Path> {
  const CircularClipper(this.radius, this.center);
  final double radius;
  final Offset center;

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MainAppBar({super.key, this.isHomePage = true});
  final bool isHomePage;
  @override
  State<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size(0.0, 60.0);
}

class _MainAppBarState extends State<MainAppBar> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  bool isDark = false;

  Widget _buildProfileButton() {
    return Observer(
      builder: (context) {
        return IconButton(
          onPressed: () {
            Navigator.of(context)
              ..push(MaterialPageRoute2(routeName: Routes.setting));
          },
          icon: const Icon(Icons.account_circle, size: 25),
        );
      },
    );
  }

  // darkCB() {
  //   print("dark");
  //   setState(() {
  //     isDark = !isDark;
  //   });
  // }

  Widget _buildThemeButton() {
    return Observer(
      builder: (context) {
        return IconButton(
          onPressed: () async {
            // if (!isDark) {
            //   darkCB();
            //   await Future.delayed(Duration(milliseconds: 200)).then((value) {
            //     _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
            //   });
            // } else {
            //   await _themeStore
            //       .changeBrightnessToDark(!_themeStore.darkMode)
            //       .then((value) {
            //     darkCB();
            //   });
            // }
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
          icon: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return widget.isHomePage
        ? IconButton(
            onPressed: () {
              SharedPreferences.getInstance().then((preference) {
                preference.setBool(Preferences.is_logged_in, false);
                Navigator.of(context)
                  ..pushAndRemoveUntil(
                      MaterialPageRoute2(routeName: Routes.login),
                      (Route<dynamic> route) => false);
              });
            },
            icon: const Icon(
              Icons.power_settings_new,
            ),
          )
        : const SizedBox();
  }

  Widget _buildLanguageButton() {
    return IconButton(
      onPressed: () {
        _buildLanguageDialog();
      },
      icon: const Icon(
        Icons.language,
      ),
    );
  }

  _buildLanguageDialog() {
    _showDialog<String>(
      context: context,
      child: MaterialDialog(
        borderRadius: 5.0,
        enableFullWidth: true,
        title: Text(
          AppLocalizations.of(context).translate('home_tv_choose_language'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        headerColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        closeButtonColor: Colors.white,
        enableCloseButton: true,
        enableBackButton: false,
        onCloseButtonClicked: () {
          Navigator.of(context).pop();
        },
        children: _languageStore.supportedLanguages
            .map(
              (object) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.all(0.0),
                title: Text(
                  object.language,
                  style: TextStyle(
                    color: _languageStore.locale == object.locale
                        ? Theme.of(context).primaryColor
                        : _themeStore.darkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // change user language based on selected locale
                  _languageStore.changeLanguage(object.locale);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  _showDialog<T>({required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
    });
  }

  @override
  Widget build(BuildContext context) {
    // return DarkTransition(
    //     isDark: isDark,
    //     offset: Offset(MediaQuery.of(context).size.width * 0.7, 20),
    //     childBuilder: (context, x) =>
    return AppBar(
      leadingWidth: 30,
      titleSpacing: 0,
      toolbarHeight: 250,
      // flexibleSpace: Container(child: Column(
      // children: [
      //   Container(height: 900, child: Center(child: Text("ooooooooooooooooooooo"),),)
      // ],)),
      title: Container(
          margin: const EdgeInsets.only(left: 20),
          child: Text(AppLocalizations.of(context).translate('appbar_title'))),
      actions: [
        _buildLanguageButton(),
        _buildThemeButton(),
        _buildProfileButton(),
        _buildLogoutButton(),
      ],
      // )
    );
  }
}