import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static Future<void> _create(
      {required NotificationContent content,
      List<NotificationActionButton>? actionButtons}) async {
    if (kIsWeb) return;
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
        channelKey: 'basic_channel',
        title: title,
        body: body,
        fullScreenIntent: true,
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
        id: 13,
        channelKey: 'basic_channel',
        // title: title,
        body: title,
        notificationLayout: NotificationLayout.BigText,
        fullScreenIntent: true,
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
    print("created: ${msg.toJson()}");
    var tittle = "${msg.sender.getName} (Project $projectId)";
    await _create(
        content: NotificationContent(
          id: id,
          category: NotificationCategory.Message,
          channelKey: 'message_channel',
          groupKey: projectId,
          title: title ?? tittle,
          body: body ?? msg.content,
          notificationLayout: NotificationLayout.Messaging,
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
        fullScreenIntent: true,
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
    AwesomeNotifications().initialize(
      // set the default icon
      'resource://drawable/image',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Basic notifications channel',
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
          channelKey: 'message_channel',
          channelName: 'Message Notifications',
          channelDescription: 'Message notifications channel',
          defaultColor: Colors.red,
          importance: NotificationImportance.High,
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
        NavigationService.navigatorKey.currentState?.push(MaterialPageRoute2(
            routeName: Routes.message,
            arguments: WrapMessageList(
              project: msg.project,
                chatUser: ChatUser(
                    id: msg.sender.objectId ?? "-1",
                    firstName: msg.sender.getName),
                messages: [])));
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
