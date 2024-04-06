// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:isolate';
import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/firebase_options.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/presentation/video_call/utils/pref_util.dart';
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

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setPreferredOrientations();
  await ServiceLocator.configureDependencies();
  ConnectycubeFlutterCallKit.instance.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // request permissions for showing notification in iOS
  FirebaseMessaging.instance
      .requestPermission(alert: true, badge: true, sound: true);

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

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

  if (!connectivityResult.contains(ConnectivityResult.none)) {
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
  }
}
