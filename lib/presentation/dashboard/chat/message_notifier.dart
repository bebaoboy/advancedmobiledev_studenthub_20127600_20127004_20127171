// ignore_for_file: library_prefixes

import 'dart:math';

import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/notification/notification.dart';

import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class MessageNotifierProvider with ChangeNotifier {
  late final IO.Socket textSocketHandler;

  /// Project ID
  final ChatUser user;
  final Project? project;
  // final _sharePrefHelper = getIt<SharedPreferenceHelper>();

  MessageNotifierProvider({required this.user, required this.project})
      : super() {
    initSocket();
  }

  initSocket() async {
    print(user);
    // TODO: chỉnh thành token hiện tại
    var token = await getIt<SharedPreferenceHelper>().authToken;
    textSocketHandler = IO.io(
        "https://api.studenthub.dev",
        (kIsWeb
                ? // Server url
                OptionBuilder().setQuery(
                    {'project_id': project?.objectId ?? -1}).setExtraHeaders({
                    'Authorization':
                        'Bearer $token',
                  })
                : OptionBuilder().setTransports(['websocket']).setQuery(
                    {'project_id': project?.objectId ?? -1}).setExtraHeaders({
                    'Authorization':
                        'Bearer $token',
                  }))
            .build());

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
      if (data["senderId"].toString() == userStore.user!.objectId) return;

      print(data['senderId'].toString());
      if (data['senderId'].toString() != user.id) return;
      print("receive $data");
      addInbox(data);
    });
    textSocketHandler.on('SEND_MESSAGE', (data) => print("send $data"));

    // noti student id/company id
    textSocketHandler.on('NOTI_${userStore.user!.objectId}', (data) {
      print("notification $data");
      // TODO: hiện thông báo inapp
    });
    textSocketHandler.on('ERROR', (data) => print("error $data"));
    textSocketHandler.onDisconnect((_) {
      print('disconnect');
      textSocketHandler.disconnect();
      textSocketHandler.destroy();
    });

    // textSocketHandler.emit("SEND_MESSAGE", {
    //   "content": "Test receiving noti from project $id",
    //   "projectId": id,
    //   "senderId": 34,
    //   "receiverId": userId, // notification
    //   "messageFlag": 0 // default 0 for message, 1 for interview
    // });
  }

  List<AbstractChatMessage> inbox = [];

  var userStore = getIt<UserStore>();
  var rand = Random();

  void addInbox(Map<String, dynamic> message) {
    // TODO: check api and change
    String mess = message["messageId"].toString();

    if (inbox.firstWhereOrNull(
          (element) => element.id == message["messageId"].toString(),
        ) ==
        null) {
      print("project ${project?.objectId},message sentttttttttttt: $message");
      NotificationHelper.createMessageNotification(
          id: rand.nextInt(100000),
          projectId: project?.objectId ?? "-1",
          msg: MessageObject(
              project: project,
              id: mess,
              content: message["content"],
              receiver: Profile(objectId: "-1", name: "Quan"),
              sender:
                  Profile(objectId: user.id, name: user.firstName ?? "null")));
      var e = <String, dynamic>{
        ...message,
        "id": mess,
        'type': message['messageFlag'] == 0 ? 'text' : 'interview',
        'text': message['content'],
        'status': 'seen',
        'interview': message['interview'] ?? {},
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'author': {
          "firstName": message["senderId"].toString() == user.id
              ? user.firstName
              : userStore.user!.name,
          "id": message["senderId"].toString(),
        }
      };

      // TODO: add vô chat store
      inbox.insert(0, AbstractChatMessage.fromJson(e));
      notifyListeners();
    } else {
      print("trùng message id ${message["messageId"]}");
    }
  }
}
