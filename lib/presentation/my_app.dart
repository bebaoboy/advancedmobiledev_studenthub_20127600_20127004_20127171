// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/core/widgets/animated_theme_app.dart';
import 'package:boilerplate/core/widgets/animation_type.dart';
import 'package:boilerplate/core/widgets/error_page_widget.dart';
import 'package:boilerplate/presentation/home/splashscreen.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/video_call/utils/platform_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:toastification/toastification.dart';

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
  // final UserStore _userStore = getIt<UserStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();

  late final onGenerateRoute;
  late final builder;

  bool enabled = true;

  @override
  void initState() {
    onGenerateRoute = (settings) {
      // //print((settings.name ?? "") + settings.arguments.toString());
      return MaterialPageRoute2(
          routeName: settings.name ?? Routes.home,
          arguments: settings.arguments);
    };
    builder = (context, child) {
      ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
        return ErrorPage(errorDetails: errorDetails);
      };
      return ResponsiveSizer(
          builder: (context, orientation, screenType) =>
              ToastificationConfigProvider(
                  config: ToastificationConfig(
                    marginBuilder: (e) =>
                        const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    alignment:
                        kIsWeb ? Alignment.topCenter : Alignment.bottomLeft,
                    animationDuration: const Duration(milliseconds: 500),
                  ),
                  child: Container(
                      constraints: kIsWeb
                          ? const BoxConstraints(minHeight: 600, minWidth: 500)
                          : null,
                      color: Theme.of(context).colorScheme.primary,
                      child: SafeArea(child: child ?? const SizedBox()))));
    };

    if (!kIsWeb) requestNotificationsPermission();

    // initPlatformState();
    super.initState();
  }

  // Future<void> initPlatformState() async {
  //   // Configure BackgroundFetch
  //   BackgroundFetch.configure(
  //       BackgroundFetchConfig(
  //           minimumFetchInterval: 45,
  //           stopOnTerminate: false,
  //           enableHeadless: true,
  //           requiredNetworkType: NetworkType.ANY), (String taskId) async {
  //     // <-- Event handler
  //     // This is the fetch-event callback.
  //     print("[BackgroundFetch] Event received $taskId");

  //     await _userStore.fetchUserProfileIfLoggedIn();

  //     // IMPORTANT:  You must signal completion of your task or the OS can punish your app
  //     // for taking too long in the background.
  //     BackgroundFetch.finish(taskId);
  //   }, (String taskId) async {
  //     // <-- Task timeout handler.
  //     // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
  //     print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
  //     BackgroundFetch.finish(taskId);
  //   });
  //   print('[BackgroundFetch] configure success');

  //   if (!mounted) return;
  // }

  @override
  Widget build(BuildContext context) {
    // _themeStore.changeBrightnessToDark(_themeStore.isPlatformDark(context));

    // if (enabled) {
    //   BackgroundFetch.start().then((int status) {
    //     print('[BackgroundFetch] start success: $status');
    //   }).catchError((e) {
    //     print('[BackgroundFetch] start FAILURE: $e');
    //   });
    // } else {
    //   BackgroundFetch.stop().then((int status) {
    //     print('[BackgroundFetch] stop success: $status');
    //   });
    // }

    return Observer(
      builder: (context) {
        return PiPMaterialApp(
          scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad
          }, physics: kIsWeb ? const BouncingScrollPhysics() : null),
          themeAnimationDuration: const Duration(milliseconds: 500),
          animationType: AnimationType.CIRCULAR_ANIMATED_THEME,
          animationDuration: const Duration(milliseconds: 500),
          builder: builder,
          debugShowCheckedModeBanner: false,
          title: Strings.appName,
          theme: AppThemeData.lightThemeData,
          darkTheme: AppThemeData.darkThemeData,
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
