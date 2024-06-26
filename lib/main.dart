// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:boilerplate/core/widgets/error_page_widget.dart';
import 'package:boilerplate/core/widgets/xmpp/logger/Log.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/notification/notification.dart';
import 'package:boilerplate/utils/workmanager/work_manager_helper.dart';
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
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';

import 'package:boilerplate/presentation/video_call/utils/configs.dart'
    as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var currentTask = getWorkerTaskFromString(task);
    var sharePref = await SharedPreferences.getInstance();
    var isLoggedIn = sharePref.getBool(Preferences.is_logged_in) ?? false;
    var rand = Random();

    try {
      switch (currentTask) {
        case WorkerTask.fetchProfile:
          {
            Log.d("main", "in a fetch profile");
            if (isLoggedIn) {
              var result = await WorkMangerHelper.fetchProfile();
              return result;
            } else {
              return Future.value(true);
            }
          }
        case WorkerTask.fetchNotification:
          {
            Log.d("main", "fetching recent noti");
            if (isLoggedIn) {
              var result = await WorkMangerHelper.fetchRecentNotification();
              if (result.isNotEmpty) {
                NotificationHelper.createBigTextNotification(
                  title: "New notification",
                  body: "You have ${result.length} new notifications!",
                );
              }
              for (var notiOb in result) {
                var channel = getChannelByMessageType(notiOb.type);
                if (channel == NotificationChannelEnum.messageChannel) {
                  if (notiOb is OfferNotification) {
                    NotificationHelper.createMessageNotification(
                        msg: MessageObject(
                          id: notiOb.id,
                          content: notiOb.content,
                          receiver: notiOb.receiver,
                          sender: notiOb.sender,
                        ),
                        projectId: notiOb.projectId,
                        id: rand.nextInt(100000));
                  } else {
                    NotificationHelper.createMessageNotification(
                        msg: MessageObject(
                          id: notiOb.id,
                          content: notiOb.content,
                          receiver: notiOb.receiver,
                          sender: notiOb.sender,
                        ),
                        projectId: "-1",
                        id: rand.nextInt(100000));
                  }
                } else {
                  NotificationHelper.createTextNotification(
                      title: channel.name,
                      body: notiOb.content,
                      id: rand.nextInt(100000));
                }
              }
              return Future.value(true);
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
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationHelper.initializeLocalNotifications();
    await NotificationHelper.initializeIsolateReceivePort();
    NotificationHelper.startListeningNotificationEvents();
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

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // request permissions for showing notification in iOS
    var messaging = FirebaseMessaging.instance;
    NavigationService.firebaseInstance = messaging;
    messaging.requestPermission(alert: true, badge: true, sound: true);

    // use the returned token to send messages to users from your custom server
    NavigationService.firebaseToken = await messaging.getToken(
      vapidKey:
          "BNE-Aa_yPC_gN8WDHhRMH5L7f1o4SxfMi9OFX6uddzpl3qeeZ7nmGctHhOkrUwJf90fE3V9lQ8D9_fjKoh7UsBo",
    );
    log("firebase token: ${NavigationService.firebaseToken}");

    // add listener for foreground push notifications
    FirebaseMessaging.onMessage.listen((remoteMessage) {
      log('[onMessage] message: ${remoteMessage.data.toString()}', "bebaoboy");
      firebaseMessagingBackgroundHandler(remoteMessage);
    });
    if (!kIsWeb) {
      if (kDebugMode) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      } else {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      }
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      FlutterError.onError = (FlutterErrorDetails errorDetails) {
        if (kIsWeb) return;
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        if (kIsWeb) return kReleaseMode;
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return kReleaseMode;
      };
    }

    if (!kIsWeb) {
      Isolate.current.addErrorListener(RawReceivePort((pair) async {
        print(
            "crash isolateEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
        final List<dynamic> errorAndStacktrace = pair;
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last,
          fatal: true,
        );
      }).sendPort);
    }
    if (!kIsWeb) ConnectycubeFlutterCallKit.instance.init();

    await initConnectycube();
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return ErrorPage(errorDetails: errorDetails);
    };
    WorkMangerHelper.registerNotificationFetch();

    runApp(const MyApp());
  }, (error, stackTrace) {
    print(error.toString());
    print(stackTrace.toString());
    print("CRASHHHHHHHHHHHHHHHHHHHHHH app");
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    }
  });
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
  print("check cube connectivity");
  if (await DeviceUtils.hasConnection()) {
    await init(
      config.APP_ID,
      config.AUTH_KEY,
      config.AUTH_SECRET,
      onSessionRestore: () {
        return SharedPrefs.getUser().then((savedUser) {
          log(savedUser?.toString(), "BEBAOBOY");
          log("onSessionRestore", "BEBAOBOY");
          return createSession(savedUser);
        });
      },
    );
  }
}
