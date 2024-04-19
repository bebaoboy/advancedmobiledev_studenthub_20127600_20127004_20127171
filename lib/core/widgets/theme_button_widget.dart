import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ThemeButton extends StatelessWidget {
  final ThemeStore _themeStore = getIt<ThemeStore>();

  ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return ListTile(
          leading: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
          ),
          title: Text('Change Theme'),
          onTap: () {
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
        );
      },
    );
  }
}
