// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:isolate';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/firebase_options.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/presentation/video_call/utils/pref_util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:boilerplate/presentation/video_call/connectycube_flutter_call_kit/lib/connectycube_flutter_call_kit.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';

import 'package:boilerplate/presentation/video_call/utils/configs.dart'
    as config;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  log('[onMessage] background message: ${message.data}', "bebaoboy");
  ////print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setPreferredOrientations();
  await ServiceLocator.configureDependencies();
  ConnectycubeFlutterCallKit.instance.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // request permissions for showing notification in iOS
  firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

  // add listener for foreground push notifications
  FirebaseMessaging.onMessage.listen((remoteMessage) {
    log('[onMessage] message: ${remoteMessage.data.toString()}', "bebaoboy");
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return kReleaseMode;
  };

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
      fatal: true,
    );
  }).sendPort);

  await initConnectycube();

  runApp(const MyApp());
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
}

initConnectycube() async {
  try {
  await init(
    config.APP_ID,
    config.AUTH_KEY,
    config.AUTH_SECRET,
    onSessionRestore: () {
      return SharedPrefs.getUser().then((savedUser) {
        log(savedUser?.toString(), "BEBAOBOY");
        return createSession(savedUser);
      });
    },
  );
  } catch(e) {}
}
