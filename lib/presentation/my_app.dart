// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/core/widgets/animated_theme_app.dart';
import 'package:boilerplate/core/widgets/animation_type.dart';
import 'package:boilerplate/presentation/home/splashscreen.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../di/service_locator.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final ThemeStore _themeStore = getIt<ThemeStore>();

  final LanguageStore _languageStore = getIt<LanguageStore>();
  late final onGenerateRoute;
  late final builder;

  @override
  void initState() {
    onGenerateRoute = (settings) {
      // //print((settings.name ?? "") + settings.arguments.toString());
      return MaterialPageRoute2(
          routeName: settings.name ?? Routes.home,
          arguments: settings.arguments);
    };
    builder = (context, child) => Container(
        color: Theme.of(context).colorScheme.primary,
        child: SafeArea(child: child ?? const SizedBox()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return PiPMaterialApp(
          themeAnimationDuration: const Duration(milliseconds: 500),
          animationType: AnimationType.CIRCULAR_ANIMATED_THEME,
          animationDuration: const Duration(milliseconds: 500),
          builder: builder,
          debugShowCheckedModeBanner: false,
          title: Strings.appName,
          theme: _themeStore.darkMode
              ? AppThemeData.darkThemeData
              : AppThemeData.lightThemeData,
          themeMode: _themeStore.darkMode ? ThemeMode.dark : ThemeMode.light,
          // routes: Routes.routes,
          locale: Locale(_languageStore.locale),
          supportedLocales: _languageStore.supportedLanguages
              .map((language) => Locale(language.locale, language.code))
              .toList(),
          localizationsDelegates: const [
            // A class which loads the translations from JSON files
            Lang.delegate,
            // Built-in localization of basic text for Material widgets
            GlobalMaterialLocalizations.delegate,
            // Built-in localization for text direction LTR/RTL
            GlobalWidgetsLocalizations.delegate,
            // Built-in localization of basic text for Cupertino widgets
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
          navigatorKey: NavigationService.navigatorKey,
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}
