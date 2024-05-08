import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/chat_store.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_calls.dart';
import 'package:boilerplate/presentation/video_call/utils/consts.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart';
import 'package:http/http.dart' show post;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  try {
    log('[onMessage] background message: ${message.data}', "bebaoboy");
    log('[onMessage] background message type: ${message.data["type"]}',
        "bebaoboy");
    log('[onMessage] background message meow: ${message.toMap().toString()}',
        "bebaoboy");
    if (message.data.isEmpty) return;

    String type = message.data["type"] ?? "";
    String title = message.data["title"] ?? "";
    // ignore: unused_local_variable
    String body = message.data["message"] ?? "";
    // ignore: unused_local_variable
    String sessionId = message.data["session_id"] ?? "";
    // int session = int.tryParse(sessionId) ?? 101;
    if (type == "interview") {
      log("onMessage interview ${json.decode(json.decode(message.data["extra_body"])["body"])}");
      var intv = InterviewSchedule.fromJsonApi(
          json.decode(json.decode(message.data["extra_body"])["body"]));
      NotificationHelper.createInterviewPreflightNotification(
          id: Random().nextInt(10000),
          title: "$title - Project ${intv.title}",
          body: "Code: ${intv.meetingRoomCode}\nId: ${intv.meetingRoomId}");
      await SharedPreferences.getInstance().then((value) {
        value.setString(
            "interview", json.decode(message.data["extra_body"])["body"]);
      });
      log("onMessage interview created: $intv");
    } else {
      print("meow");
      if (message.data["signal_type"] != null) {
        if (message.data["signal_type"] == SIGNAL_TYPE_START_CALL) {
          NotificationHelper.createBigTextNotification(
              title: "New interview call",
              body: "From ${message.data["caller_name"]}");
        } else {
          NotificationHelper.createBigTextNotification(
              title: "Interview call ended",
              body: "From ${message.data["caller_name"]}");
        }
      }
      NotificationHelper.createBigTextNotification(
          title: "Notification", body: message.data.toString());
    }
    ////print("Handling a background message: ${message.messageId}");
  } catch (e) {
    log('[onMessage] background message error: ${e.toString()}', "bebaoboy");
  }
}

enum NotificationChannelEnum {
  messageChannel("message_channel_key", "Message channel",
      "For receive message notification"),
  interviewChannel("interview_channel_key", "Interview channel",
      "For receive interview notification"),
  basicChannel("basic_channel_key", "Basic channel", "For receive simple text"),
  proposalChannel("proposal_channel_key", "Proposal channel",
      "For receive proposal notification");

  const NotificationChannelEnum(this.key, this.name, this.description);
  final String name;
  final String key;
  final String description;
}

NotificationChannelEnum getChannelByMessageType(NotificationType type) {
  switch (type) {
    case NotificationType.joinInterview:
      {
        return NotificationChannelEnum.interviewChannel;
      }
    case NotificationType.message:
      {
        return NotificationChannelEnum.messageChannel;
      }
    case NotificationType.viewOffer:
      {
        return NotificationChannelEnum.proposalChannel;
      }
    default:
      return NotificationChannelEnum.basicChannel;
  }
}

class NotificationHelper {
  static Future<bool> sendPushMessageFirebase({
    required String recipientToken,
    required String title,
    required String body,
  }) async {
    final jsonCredentials = await rootBundle.loadString('assets/key.json');
    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

    final client = await auth.clientViaServiceAccount(
      creds,
      [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/firebase.database',
        'https://www.googleapis.com/auth/firebase.messaging'
      ],
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            creds,
            [
              'https://www.googleapis.com/auth/userinfo.email',
              'https://www.googleapis.com/auth/firebase.database',
              'https://www.googleapis.com/auth/firebase.messaging'
            ],
            client);

    final notificationData = {
      'message': {
        'token': recipientToken,
        'notification': {'title': title, 'body': body}
      },
    };
    final response = await post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/advmobiledev-studenthub-clc20/messages:send'),
      headers: {
        'content-type': 'application/json',
        "Authorization": "Bearer ${credentials.accessToken.data}"
      },
      body: jsonEncode(notificationData),
    );

    client.close();
    if (response.statusCode == 200) {
      return true; // Success!
    }

    log('Notification Sending Error Response status: ${response.statusCode}');
    log('Notification Response body: ${response.body}');
    return false;
  }

  static Future<void> _create(
      {required NotificationContent content,
      List<NotificationActionButton>? actionButtons}) async {
    if (content.body == null) return;
    if (content.body!.isEmpty) return;
    if (kIsWeb) {
      try {
        await sendPushMessageFirebase(
            recipientToken: NavigationService.firebaseToken!,
            body: content.body ?? "Body",
            title: content.title ?? "Msg redirect from web");
      } catch (e) {
        log(e.toString());
      }
      return;
    }
    await AwesomeNotifications()
        .createNotification(content: content, actionButtons: actionButtons);
  }

  static Future<void> createTextNotification(
      {String? title = 'Text Notification',
      int id = 10,
      String? body = 'This is a simple text notification'}) async {
    await _create(
      content: NotificationContent(
        id: id,
        channelKey: NotificationChannelEnum.basicChannel.key,
        title: title,
        body: body,
        fullScreenIntent: false,
        wakeUpScreen: true,
      ),
    );
  }

  static Future<void> createInterviewPreflightNotification(
      {String? title = 'You have an interview',
      required int id,
      String? body = 'This is a simple text notification'}) async {
    await _create(
      content: NotificationContent(
        id: id,
        channelKey: NotificationChannelEnum.interviewChannel.key,
        title: title,
        body: body,
        fullScreenIntent: false,
        notificationLayout: NotificationLayout.BigText,
        wakeUpScreen: true,
      ),
    );
  }

  static Future<void> createBigTextNotification(
      {String? title = 'Big Text Notification',
      String? body =
          'This is a big text notification This is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notificationThis is a big text notification'}) async {
    await _create(
      content: NotificationContent(
        id: Random().nextInt(10000),
        channelKey: NotificationChannelEnum.basicChannel.key,
        title: title,
        body: title,
        notificationLayout: NotificationLayout.BigText,
        fullScreenIntent: false,
        wakeUpScreen: true,
      ),
    );
  }

  static Future<void> createMessageNotification(
      {String? title,
      String? body,
      required MessageObject msg,
      required String projectId,
      required int id}) async {
    print("created: $id");
    var tittle = "${msg.sender.getName} (Project $projectId)";
    await _create(
        content: NotificationContent(
          id: id,
          category: NotificationCategory.Message,
          channelKey: NotificationChannelEnum.messageChannel.key,
          groupKey: "$projectId-${msg.sender.objectId}",
          title: title ?? tittle,
          body: body ?? msg.content,
          notificationLayout: NotificationLayout.MessagingGroup,
          wakeUpScreen: true,
          // largeIcon: 'resource://drawable/image',
          payload: {
            "type": "chat_messages",
            "chatId": msg.id,
            "senderId": msg.sender.objectId ?? '',
            "senderName": tittle,
            "msg": msg.toJson(),
          },
          summary: title ?? msg.sender.getName,
        ),
        actionButtons: [
          NotificationActionButton(
            key: "message_reply_button",
            label: "Reply",
            requireInputText: true,
          ),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

  static Future<void> createImageNotification(
      {String? title = 'Image Notification',
      String? body = 'This is a simple image notification',
      String? image = 'asset://assets/images/image.png'}) async {
    await _create(
      content: NotificationContent(
        id: 11,
        channelKey: 'image_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigPicture,
        bigPicture: image,
        fullScreenIntent: false,
        wakeUpScreen: true,
      ),
    );
  }

  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    // TODO: chia notification groups
    AwesomeNotifications().initialize(
      // set the default icon
      'resource://drawable/image',
      [
        NotificationChannel(
          channelKey: NotificationChannelEnum.basicChannel.key,
          channelName: NotificationChannelEnum.basicChannel.name,
          channelDescription: NotificationChannelEnum.basicChannel.description,
          defaultColor: Colors.teal,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: 'image_channel',
          channelName: 'Image Notifications',
          channelDescription: 'Image notifications channel',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: NotificationChannelEnum.messageChannel.key,
          channelName: NotificationChannelEnum.messageChannel.name,
          channelDescription:
              NotificationChannelEnum.messageChannel.description,
          defaultColor: Colors.red,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: NotificationChannelEnum.interviewChannel.key,
          channelName: NotificationChannelEnum.interviewChannel.name,
          channelDescription:
              NotificationChannelEnum.interviewChannel.description,
          defaultColor: Colors.green,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: NotificationChannelEnum.proposalChannel.key,
          channelName: NotificationChannelEnum.proposalChannel.name,
          channelDescription:
              NotificationChannelEnum.proposalChannel.description,
          defaultColor: Colors.yellow,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
        ),
      ],
    );

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    if (kIsWeb) return;
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    if (kIsWeb) return;

    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        print(
            'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }
      print('Message sent : "${receivedAction.payload}"');

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.payload != null &&
        receivedAction.payload!["msg"] != null) {
      try {
        var msg = MessageObject.fromJson(
            json.decode(receivedAction.payload!["msg"]!));
        getIt<ChatStore>()
            .changeMessageScreen(msg.sender.objectId!, msg.project!.objectId!);
        NavigationService.navigatorKey.currentState
            ?.push(MaterialPageRoute2(routeName: Routes.message, arguments: [
          false,
          WrapMessageList(
              project: msg.project,
              chatUser: ChatUser(
                  id: msg.sender.objectId ?? "-1",
                  firstName: msg.sender.getName),
              messages: [])
        ]));
      } catch (e) {
        print(e.toString());
      }
    }
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************
  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    // final url = Uri.parse("http://google.com");
    // final re = await http.get(url);
    // print(re.body);
    print("long task done");
  }

  static Future<void> scheduleNewNotification(
      int? minute, int? hour, int? day) async {
    if (kIsWeb) return;
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await Permission.notification.isDenied.then((value) async {
        if (value) {
          isAllowed = await Permission.notification.request().isGranted;
        }
      });
    }
    if (!isAllowed) return;

    await myNotifySchedule(
        hoursFromNow: hour ?? 0,
        minutesFromNow: minute ?? 0,
        daysFromNow: day ?? 0,
        title: 'test',
        msg: 'test message',
        heroThumbUrl:
            'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
        username: 'test user',
        repeatNotif: false);
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}

Future<void> myNotifySchedule({
  int hoursFromNow = 0,
  int minutesFromNow = 0,
  int daysFromNow = 0,
  required String heroThumbUrl,
  required String username,
  required String title,
  required String msg,
  bool repeatNotif = false,
}) async {
  var nowDate = DateTime.now().add(Duration(
      hours: hoursFromNow,
      seconds: 10,
      minutes: minutesFromNow,
      days: daysFromNow));
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar(
      //weekday: nowDate.day,
      hour: nowDate.hour,
      minute: 0,
      second: nowDate.second,
      repeats: repeatNotif,
      //allowWhileIdle: true,
    ),
    // schedule: NotificationCalendar.fromDate(
    //    date: DateTime.now().add(const Duration(seconds: 10))),
    content: NotificationContent(
      id: -1,
      channelKey: 'basic_channel',
      title: '${Emojis.food_bowl_with_spoon} $title',
      body: '$username, $msg',
      bigPicture: heroThumbUrl,
      notificationLayout: NotificationLayout.BigPicture,
      //actionType : ActionType.DismissAction,
      color: Colors.black,
      backgroundColor: Colors.black,
      // customSound: 'resource://raw/notif',
      payload: {'actPag': 'myAct', 'actType': 'food', 'username': username},
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'NOW',
        label: 'btnAct1',
      ),
      NotificationActionButton(
        key: 'LATER',
        label: 'btnAct2',
      ),
    ],
  );
}
