// ignore_for_file: library_prefixes

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class MessageNotifierProvider with ChangeNotifier {
  late final IO.Socket textSocketHandler;

  /// Project ID
  final String id;

  MessageNotifierProvider({required this.id}) : super() {
    initSocket();
  }

  initSocket() async {
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
    textSocketHandler.on('RECEIVE_MESSAGE', (data) => print("receive $data"));
    textSocketHandler.on('SEND_MESSAGE', (data) => print("send $data"));

    // noti student id/company id
    textSocketHandler.on('NOTI_94', (data) {
      print("notification $data");
      addInbox(data);
    });
    textSocketHandler.on('ERROR', (data) => print("error $data"));
    textSocketHandler.onDisconnect((_) => print('disconnect'));

    textSocketHandler.emit("SEND_MESSAGE", {
      "content": "Test receiving noti from project $id",
      "projectId": id,
      "senderId": 34,
      "receiverId": 94, // notification
      "messageFlag": 0 // default 0 for message, 1 for interview
    });
  }

  List<String> inbox = [];

  void addInbox(Map<String, dynamic> message) {
    inbox.insert(0, message["content"].toString());
    print(message);
    notifyListeners();
  }
}
