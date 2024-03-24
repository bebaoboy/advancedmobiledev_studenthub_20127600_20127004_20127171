import 'dart:async';
import 'dart:convert';

import 'package:boilerplate/presentation/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Lang {
  // localization variables
  final Locale locale;
  late Map<String, String> localizedStrings;
  static Map<String, String> backupStrings = {};

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<Lang> delegate =
      _AppLocalizationsDelegate();

  // constructor
  Lang(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static Lang of(BuildContext context) {
    return Localizations.of<Lang>(context, Lang)!;
  }

  static String get(String? key) {
    var context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      var baseLcl = Localizations.of<Lang>(context, Lang);
      if (baseLcl != null) {
        return baseLcl.translate(key);
      } else {
        return backupStrings[key] ?? "<null>";
      }
    }
    return backupStrings[key] ?? "<null>";
  }

  // This is a helper method that will load local specific strings from file
  // present in lang folder
  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString;
    try {
      jsonString = await rootBundle
          .loadString('assets/lang/${locale.languageCode}.json');
    } catch (e) {
      jsonString = await rootBundle.loadString('assets/lang/en.json');
    }
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(
          key, value.toString().replaceAll(r"\'", "'").replaceAll(r"\t", " "));
    });
    backupStrings = jsonMap.map((key, value) {
      return MapEntry(
          key, value.toString().replaceAll(r"\'", "'").replaceAll(r"\t", " "));
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String? key) {
    return localizedStrings[key] ?? "<Missing translation>";
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _AppLocalizationsDelegate extends LocalizationsDelegate<Lang> {
  // ignore: non_constant_identifier_names
  final String TAG = "AppLocalizations";

  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'es', 'da', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<Lang> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    Lang localizations = Lang(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
