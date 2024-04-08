// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:isolate';
import 'package:boilerplate/core/widgets/xmpp/logger/Log.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/utils/workmanager/work_manager_helper.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  log('[onMessage] background message: ${message.data}', "bebaoboy");
  ////print("Handling a background message: ${message.messageId}");
}

// @pragma('vm:entry-point')
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;
//   if (isTimeout) {
//     // This task has exceeded its allowed running-time.
//     // You must stop what you're doing and immediately .finish(taskId)
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }
//   print('[BackgroundFetch] Headless event received.');
//   // Do your work here...
//   BackgroundFetch.finish(taskId);
// }

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var currentTask = getWorkerTaskFromString(task);
    var helper = WorkMangerHelper();
    var sharePref = await SharedPreferences.getInstance();
    var isLoggedIn = sharePref.getBool(Preferences.is_logged_in) ?? false;

    try {
      switch (currentTask) {
        case WorkerTask.fetchProfile:
          {
            Log.d("main", "in a fetch profile");
            if (isLoggedIn) {
              return await helper.fetchProfile();
            } else {
              return Future.value(true);
            }
          }
        default:
          Log.d("main",
              "Native called background task: $task"); //simpleTask will be emitted here.
          return Future.value(true);
      }
    } catch (err) {
      Log.e("main", err.toString());
      return Future.value(false);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setPreferredOrientations();

  await ServiceLocator.configureDependencies().then((value) {
    if (!kIsWeb) {
      Workmanager().initialize(
          callbackDispatcher, // The top level function, aka callbackDispatcher
          isInDebugMode:
              true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
          );
    }
  });
  if (!kIsWeb) ConnectycubeFlutterCallKit.instance.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // request permissions for showing notification in iOS
  var messaging = FirebaseMessaging.instance;
  messaging.requestPermission(alert: true, badge: true, sound: true);

  if (kIsWeb) {
    // use the returned token to send messages to users from your custom server
    var token = await messaging.getToken(
      vapidKey:
          "BNE-Aa_yPC_gN8WDHhRMH5L7f1o4SxfMi9OFX6uddzpl3qeeZ7nmGctHhOkrUwJf90fE3V9lQ8D9_fjKoh7UsBo",
    );
  }

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

  if (!kIsWeb) {
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
        fatal: true,
      );
    }).sendPort);
  }

  await initConnectycube();

  runApp(const MyApp());

  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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
  // if (kIsWeb) {
  //   return;
  // }
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
