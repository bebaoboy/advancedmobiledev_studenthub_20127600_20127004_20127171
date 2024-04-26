// ignore_for_file: library_prefixes


import 'dart:math';

import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/utils/notification/notification.dart';

import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';

class MessageNotifierProvider with ChangeNotifier {
  late final IO.Socket textSocketHandler;

  /// Project ID
  final String id;
  final _sharePrefHelper = getIt<SharedPreferenceHelper>();
  final String senderName;

  MessageNotifierProvider({required this.id, required this.senderName})
      : super() {
    initSocket();
  }

  initSocket() async {
    int userId = await _sharePrefHelper.currentUserId;
    if (userId == 0) return;
    print(id);
    textSocketHandler = IO.io(
        "https://api.studenthub.dev", // Server url
        OptionBuilder().setTransports(['websocket']).setQuery(
            {'project_id': id}).setExtraHeaders({
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzQsImZ1bGxuYW1lIjoiYmFvIGJhbyIsImVtYWlsIjoiYmFvbWlua2h1eW5oQGdtYWlsLmNvbSIsInJvbGVzIjpbMCwxXSwiaWF0IjoxNzEyOTkyMjQ2LCJleHAiOjE3MTQyMDE4NDZ9.YyV3O4_7apzlS1ha-c1ujcWn6IyXv6coBvSnvdFOeWs',
        }).build());

    //Add authorization to header
    // textSocketHandler.io.options?['extraHeaders'] = {
    //   'Authorization':
    //       'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzQsImZ1bGxuYW1lIjoiYmFvIGJhbyIsImVtYWlsIjoiYmFvbWlua2h1eW5oQGdtYWlsLmNvbSIsInJvbGVzIjpbMCwxXSwiaWF0IjoxNzEyOTkyMjQ2LCJleHAiOjE3MTQyMDE4NDZ9.YyV3O4_7apzlS1ha-c1ujcWn6IyXv6coBvSnvdFOeWs',
    // };
    // //Add query param to url
    // textSocketHandler.io.options?['query'] = {'project_id': id};

    // textSocketHandler.connect();

    textSocketHandler.onerror((_) => print("error $_"));
    textSocketHandler.onConnect((_) {
      print('connect');
      // socket.emit('msg', 'test');
    });
    textSocketHandler.onConnectError((_) {
      print('err connect');
      // socket.emit('msg', 'test');
    });

    // ToDo: add to noti and also handle send on noti
    textSocketHandler.on('RECEIVE_MESSAGE', (data) {
      if (data['senderId'] == userId) return;
      print("receive $data");
    });
    textSocketHandler.on('SEND_MESSAGE', (data) => print("send $data"));

    // noti student id/company id
    textSocketHandler.on('NOTI_$userId', (data) {
      print("notification $data");
      addInbox(data);
      NotificationHelper.createMessageNotification(
          id: Random().nextInt(50),
          projectId: "150",
          msg: MessageObject(
              id: Random().nextInt(5).toString(),
              content: data["content"],
              receiver: Profile(objectId: data["receiverId"], name: "Quan"),
              sender: Profile(
                  objectId: data["senderId"], name: "Bao Bao Baby Boo")));
    });
    textSocketHandler.on('ERROR', (data) => print("error $data"));
    textSocketHandler.onDisconnect((_) => print('disconnect'));

    // textSocketHandler.emit("SEND_MESSAGE", {
    //   "content": "Test receiving noti from project $id",
    //   "projectId": id,
    //   "senderId": 34,
    //   "receiverId": userId, // notification
    //   "messageFlag": 0 // default 0 for message, 1 for interview
    // });
  }

  List<AbstractChatMessage> inbox = [];

  void addInbox(Map<String, dynamic> message) {
    var e = <String, dynamic>{
      ...message,
      'id': const Uuid().v4(),
      'type': message['messageFlag'] == 0 ? 'text' : 'interview',
      'text': message['content'],
      'status': 'seen',
      'interview': message['interview'] ?? {},
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'author': {
        "firstName": senderName,
        "id": message['senderId'].toString(),
      }
    };
    inbox.insert(0, AbstractChatMessage.fromJson(e));
    print(message);
    notifyListeners();
  }
}
