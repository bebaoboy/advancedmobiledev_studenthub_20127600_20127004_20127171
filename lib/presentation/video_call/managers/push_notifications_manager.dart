// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';

import 'package:boilerplate/presentation/my_app.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:universal_io/io.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';

import '../utils/consts.dart';
import '../utils/pref_util.dart';
import 'package:boilerplate/presentation/video_call/utils/configs.dart'
    as config;

@pragma('vm:entry-point')
Future<void> onCallRejectedWhenTerminated(CallEvent callEvent) async {
  log('[PushNotificationsManager][onCallRejectedWhenTerminated] callEvent: $callEvent',
      "BEBAOBOY");

  var currentUser = await SharedPrefs.getUser();
  initConnectycubeContextLess();

  var sendOfflineReject = rejectCall(callEvent.sessionId, {
    ...callEvent.opponentsIds.where((userId) => currentUser!.id != userId),
    callEvent.callerId
  });
  var sendPushAboutReject = sendPushAboutRejectFromKilledState({
    PARAM_CALL_TYPE: callEvent.callType,
    PARAM_SESSION_ID: callEvent.sessionId,
    PARAM_CALLER_ID: callEvent.callerId,
    PARAM_CALLER_NAME: callEvent.callerName,
    PARAM_CALL_OPPONENTS: callEvent.opponentsIds.join(','),
  }, callEvent.callerId);

  return Future.wait([sendOfflineReject, sendPushAboutReject]).then((result) {
    return Future.value();
  });
}

@pragma('vm:entry-point')
Future<void> sendPushAboutRejectFromKilledState(
  Map<String, dynamic> parameters,
  int callerId,
) {
  CreateEventParams params = CreateEventParams();
  params.parameters = parameters;
  params.parameters['message'] = "Reject call";
  params.parameters[PARAM_SIGNAL_TYPE] = SIGNAL_TYPE_REJECT_CALL;
  params.parameters[PARAM_IOS_VOIP] = 1;

  params.notificationType = CubeNotificationType.PUSH;
  params.environment = CubeEnvironment.DEVELOPMENT;
  params.usersIds = [callerId];

  return createEvent(params.getEventForRequest());
}

class PushNotificationsManager {
  static const TAG = "BEBAOBOY";

  static PushNotificationsManager? _instance;

  PushNotificationsManager._internal();

  static PushNotificationsManager _getInstance() {
    return _instance ??= PushNotificationsManager._internal();
  }

  factory PushNotificationsManager() => _getInstance();

  BuildContext? applicationContext;

  static PushNotificationsManager get instance => _getInstance();

  init() async {
    ConnectycubeFlutterCallKit.initEventsHandler();
    FirebaseMessaging firebaseMessaging = NavigationService.firebaseInstance!;
    String token;
    if (kIsWeb) {
      token = await firebaseMessaging.getToken(
              vapidKey:
                  "BNE-Aa_yPC_gN8WDHhRMH5L7f1o4SxfMi9OFX6uddzpl3qeeZ7nmGctHhOkrUwJf90fE3V9lQ8D9_fjKoh7UsBo") ??
          "";
    } else if (Platform.isAndroid) {
      token = await firebaseMessaging.getToken() ?? "";
    } else {
      token = await firebaseMessaging.getAPNSToken() ?? "";
    }

    if (!isEmpty(token)) {
      subscribe(token);
    }

    firebaseMessaging.onTokenRefresh.listen((newToken) {
      // this will NEVER happen T-T
      log('[onTokenRefresh] FCM token: $newToken', TAG);

      subscribe(newToken);
    });

    ConnectycubeFlutterCallKit.onTokenRefreshed = (token) {
      log('[onTokenRefresh] VoIP token: $token', TAG);
      subscribe(token);
    };

    ConnectycubeFlutterCallKit.getToken().then((token) {
      log('[getToken] VoIP token: $token', TAG);
      if (token != null) {
        subscribe(token);
      }
    });

    // ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated =
    //     onCallRejectedWhenTerminated;
  }

  subscribe(String token) async {
    try {
      log('[subscribe] token: $token', "BEBAOBOY");

      // var savedToken = await SharedPrefs.getSubscriptionToken();
      // if (token == savedToken) {
      //   log('[subscribe] skip subscription for same token', "BEBAOBOY");
      //   return;
      // }
      if (token == "") {
        log("no saved token", "BEBAOBOY");
        token = await SharedPrefs.getSubscriptionToken();
      }

      CreateSubscriptionParameters parameters = CreateSubscriptionParameters();
      parameters.pushToken = token;
      log("subscribe ${parameters.toString()}");

      parameters.environment = CubeEnvironment.DEVELOPMENT;

      if (Platform.isAndroid || kIsWeb) {
        parameters.channel = NotificationsChannels.GCM;
        parameters.platform = CubePlatform.ANDROID;
      } else if (Platform.isIOS) {
        parameters.channel = NotificationsChannels.APNS_VOIP;
        parameters.platform = CubePlatform.IOS;
      }
      log("subscribe ${parameters.toString()}");

      var deviceInfoPlugin = DeviceInfoPlugin();

      String? deviceId;

      if (kIsWeb) {
        var webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
        deviceId = base64Encode(utf8.encode(webBrowserInfo.userAgent ?? ''));
      } else if (Platform.isAndroid) {
        var androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      } else if (Platform.isMacOS) {
        var macOsInfo = await deviceInfoPlugin.macOsInfo;
        deviceId = macOsInfo.computerName;
      }

      parameters.udid = deviceId;
      log("subscribe ${parameters.toString()}");

      var packageInfo = await PackageInfo.fromPlatform();
      parameters.bundleIdentifier = packageInfo.packageName;
      log("subscribe ${parameters.toString()}");

      createSubscription(parameters.getRequestParameters())
          .then((cubeSubscriptions) {
        log('[subscribe] subscription SUCCESS', "BEBAOBOY");
        SharedPrefs.saveSubscriptionToken(token);
        for (var subscription in cubeSubscriptions) {
          log('[subscribe] subscription: $subscription', "BEBAOBOY");
          if (subscription.device!.clientIdentificationSequence == token) {
            SharedPrefs.saveSubscriptionId(subscription.id!);
          }
        }
      }).catchError((error) {
        log('[subscribe] subscription ERROR: $error', "BEBAOBOY");
      });
    } catch (e) {
      print("[subscribe] subscription ERROR: ${e.toString()}");
    }
  }

  Future<void> unsubscribe() {
    SharedPrefs.saveSubscriptionToken("");

    return SharedPrefs.getSubscriptionId().then((subscriptionId) async {
      if (subscriptionId != 0) {
        log('[unsubscribe] delete: $subscriptionId', "BEBAOBOY");

        return deleteSubscription(subscriptionId).then((voidResult) {
          SharedPrefs.saveSubscriptionId(0);
        });
      } else {
        log('[unsubscribe] delete: $subscriptionId', "BEBAOBOY");
        return Future.value();
      }
    }).catchError((onError) {
      log('[unsubscribe] ERROR: $onError', "BEBAOBOY");
    });
  }
}

initConnectycubeContextLess() {
  CubeSettings.instance.applicationId = config.APP_ID;
  CubeSettings.instance.authorizationKey = config.AUTH_KEY;
  CubeSettings.instance.authorizationSecret = config.AUTH_SECRET;
  CubeSettings.instance.onSessionRestore = () {
    return SharedPrefs.getUser().then((savedUser) {
      return createSession(savedUser);
    });
  };
}
