import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_dialog/material_dialog.dart';

class LanguageButton extends StatelessWidget {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();

  @override
  Widget build(BuildContext context) {
    _showDialog<T>({required BuildContext context, required Widget child}) {
      showDialog<T>(
        context: context,
        builder: (BuildContext context) => child,
      ).then<void>((T? value) {
        // The value passed to Navigator.pop() or null.
      });
    }

    _buildLanguageDialog() {
      _showDialog<String>(
        context: context,
        child: MaterialDialog(
          borderRadius: 5.0,
          enableFullWidth: true,
          title: Text(
            AppLocalizations.of(context).translate('home_tv_choose_language'),
            style: TextStyle(
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
                  contentPadding: EdgeInsets.all(0.0),
                  title: Text(
                    object.language!,
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
                    _languageStore.changeLanguage(object.locale!);
                  },
                ),
              )
              .toList(),
        ),
      );
    }

    Widget _buildLanguageButton() {
      return IconButton(
        onPressed: () {
          _buildLanguageDialog();
        },
        icon: Icon(
          Icons.language,
        ),
      );
    }

    return _buildLanguageButton();
  }
}
