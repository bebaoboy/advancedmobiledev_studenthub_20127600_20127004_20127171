import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ThemeButton extends StatefulWidget {

  const ThemeButton({super.key});

  @override
  State<ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<ThemeButton> {
  final ThemeStore _themeStore = getIt<ThemeStore>();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return ListTile(
          leading: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
          ),
          title: Text(Lang.get("home_tv_choose_theme")),
          onTap: () {
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
        );
      },
    );
  }
}
