// ignore_for_file: library_prefixes

import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';

import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/utils/notification/store/notification_store.dart';

import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class MessageNotifierProvider with ChangeNotifier {
  late final IO.Socket textSocketHandler;

  /// Project ID
  // final ChatUser user;
  final Project? project;
  final Function addInboxCb;
  final Function updateInterviewCb;
  // final _sharePrefHelper = getIt<SharedPreferenceHelper>();

  MessageNotifierProvider(
      {required this.project,
      required this.addInboxCb,
      required this.updateInterviewCb})
      : super() {
    initSocket(addInboxCb);
  }

  static bool initNotificationSocket = false;
  var notiStore = getIt<NotificationStore>();

  initSocket(Function addInbox) async {
    // print(user);
    var token = await getIt<SharedPreferenceHelper>().authToken;
    textSocketHandler = IO.io(
        "https://api.studenthub.dev",
        (kIsWeb
                ? // Server url
                OptionBuilder().setQuery(
                    {'project_id': project?.objectId ?? -1}).setExtraHeaders({
                    'Authorization': 'Bearer $token',
                  })
                : OptionBuilder().setTransports(['websocket']).setQuery(
                    {'project_id': project?.objectId ?? -1}).setExtraHeaders({
                    'Authorization': 'Bearer $token',
                  }))
            .enableForceNewConnection()
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
      print('connect socket ${project?.objectId}');
      // socket.emit('msg', 'test');
    });
    textSocketHandler.onConnectError((_) {
      print('err connect socket ${project?.objectId}');
      // socket.emit('msg', 'test');
    });

    // ToDo: add to noti and also handle send on noti
    textSocketHandler.on('RECEIVE_MESSAGE', (data) {
      print("receive socket ${project?.objectId} $data");
      // if (data["notification"]["senderId"].toString() ==
      //     userStore.user!.objectId) return;

      // // print(data["notification"]['senderId'].toString());
      // var i = addInbox(data, inbox, false);
      // if (i != null) {
      //   // inbox.insert(0, i);
      // }
      // notifyListeners();
    });

    textSocketHandler.on('RECEIVE_INTERVIEW', (data) {
      print("receive interview socket ${project?.objectId} $data");

      if (data["notification"]["senderId"].toString() ==
          userStore.user!.objectId) {
        updateInterviewCb(data, inbox, true);
        notiStore.addNofitication(data);
      }

      // print(data["notification"]['senderId'].toString());
      // var i = addInbox(data, inbox, true);
      // if (i != null) {
      //   // inbox.insert(0, i);
      // }
      // notifyListeners();
    });

    textSocketHandler.on('SEND_MESSAGE', (data) => print("send $data"));

    // noti student id/company id
    if (!initNotificationSocket) {
      initNotificationSocket = true;
      textSocketHandler.on('NOTI_${userStore.user!.objectId}', (data) {
        print("notification socket ${userStore.user!.objectId} $data");
        if (data["notification"]["receiverId"].toString() !=
            userStore.user!.objectId) return;
        if (data["notification"]["senderId"].toString() ==
            userStore.user!.objectId) return;

        // print(data["notification"]['senderId'].toString());
        var i = addInbox(data, inbox,
            data["notification"]?["message"]?["interview"] != null);
        if (i != null) {
          // inbox.insert(0, i);
        }
        notifyListeners();
        notiStore.addNofitication(data);
      });
    }

    textSocketHandler.on('ERROR', (data) => print("error $data"));
    textSocketHandler.onDisconnect((_) {
      print('disconnect socket  ${project?.objectId}');
    });

    // textSocketHandler.emit("SEND_MESSAGE", {
    //   "content": "Test receiving noti from project $id",
    //   "projectId": id,
    //   "senderId": 34,
    //   "receiverId": userId, // notification
    //   "messageFlag": 0 // default 0 for message, 1 for interview
    // });
  }

  List<AbstractChatMessage> inbox = List.empty(growable: true);

  var userStore = getIt<UserStore>();

  @override
  dispose() {
    textSocketHandler.disconnect();
    super.dispose();
  }
}

// class MessageNotifierProvider with ChangeNotifier {
//   final Map<String, IO.Socket> textSocketHandler = {};

//   /// Project ID
//   // final ChatUser user;
//   // final Project? project;
//   // final _sharePrefHelper = getIt<SharedPreferenceHelper>();

//   MessageNotifierProvider() : super() {
//     // initSocket();
//   }

//   initSocket(Project project, ChatUser user) async {
//     print(user);
//     var token = await getIt<SharedPreferenceHelper>().authToken;
//     textSocketHandler[project.objectId!] = IO.io(
//         "https://api.studenthub.dev",
//         (kIsWeb
//                 ? // Server url
//                 OptionBuilder().setQuery(
//                     {'project_id': project.objectId ?? -1}).setExtraHeaders({
//                     'Authorization': 'Bearer $token',
//                   })
//                 : OptionBuilder().setTransports(['websocket']).setQuery(
//                     {'project_id': project.objectId ?? -1}).setExtraHeaders({
//                     'Authorization': 'Bearer $token',
//                   }))
//             .build());

//     //Add authorization to header
//     // textSocketHandler.io.options?['extraHeaders'] = {
//     //   'Authorization':
//     //       'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzQsImZ1bGxuYW1lIjoiYmFvIGJhbyIsImVtYWlsIjoiYmFvbWlua2h1eW5oQGdtYWlsLmNvbSIsInJvbGVzIjpbMCwxXSwiaWF0IjoxNzEyOTkyMjQ2LCJleHAiOjE3MTQyMDE4NDZ9.YyV3O4_7apzlS1ha-c1ujcWn6IyXv6coBvSnvdFOeWs',
//     // };
//     // //Add query param to url
//     // textSocketHandler.io.options?['query'] = {'project_id': id};

//     // textSocketHandler.connect();

//     textSocketHandler[project.objectId!]!.onerror((_) => print("error $_"));
//     textSocketHandler[project.objectId!]!.onConnect((_) {
//       print('connect');
//       // socket.emit('msg', 'test');
//     });
//     textSocketHandler[project.objectId!]!.onConnectError((_) {
//       print('err connect');
//       // socket.emit('msg', 'test');
//     });

//     // ToDo: add to noti and also handle send on noti
//     textSocketHandler[project.objectId!]!.on('RECEIVE_MESSAGE', (data) {
//       if (data["notification"]["senderId"].toString() ==
//           userStore.user!.objectId) return;

//       print(data["notification"]['senderId'].toString());
//       if (data["notification"]['senderId'].toString() != user.id) return;
//       print("receive $data");
//       addInbox(data, project, user, false);
//     });

//     textSocketHandler[project.objectId!]!.on('RECEIVE_INTERVIEW', (data) {
//       if (data["notification"]["senderId"].toString() ==
//           userStore.user!.objectId) return;

//       print(data["notification"]['senderId'].toString());
//       if (data["notification"]['senderId'].toString() != user.id) return;
//       print("receive interview $data");
//       addInbox(data, project, user, true);
//     });

//     textSocketHandler[project.objectId!]!
//         .on('SEND_MESSAGE', (data) => print("send $data"));

//     // noti student id/company id
//     textSocketHandler[project.objectId!]!.on('NOTI_${userStore.user!.objectId}',
//         (data) {
//       print("notification $data");
//       // TODO: hiện thông báo inapp
//     });
//     textSocketHandler[project.objectId!]!
//         .on('ERROR', (data) => print("error $data"));
//     textSocketHandler[project.objectId!]!.onDisconnect((_) {
//       print('disconnect');
//     });

//     // textSocketHandler.emit("SEND_MESSAGE", {
//     //   "content": "Test receiving noti from project $id",
//     //   "projectId": id,
//     //   "senderId": 34,
//     //   "receiverId": userId, // notification
//     //   "messageFlag": 0 // default 0 for message, 1 for interview
//     // });
//   }

//   List<AbstractChatMessage> inbox = [];

//   var userStore = getIt<UserStore>();
//   var rand = Random();

//   void addInbox(Map<String, dynamic> msg, Project project, ChatUser user,
//       bool isInterview) async {
//     Map<String, dynamic> message = msg["notification"]["message"];
//     String mess = message["id"].toString();
//     print("receive id: $mess");

//     if (inbox.firstWhereOrNull(
//           (element) => element.id == message["id"].toString(),
//         ) ==
//         null) {
//       print("project ${project.objectId},message sentttttttttttt: $message");

//       if (!isInterview) {
//         NotificationHelper.createMessageNotification(
//             id: mess.isNotEmpty
//                 ? int.tryParse(mess) ?? rand.nextInt(100000)
//                 : rand.nextInt(100000),
//             projectId: project.objectId ?? "-1",
//             msg: MessageObject(
//                 project: project,
//                 id: mess,
//                 content: message["content"] ?? message["title"],
//                 receiver: Profile(objectId: "-1", name: "Quan"),
//                 sender: Profile(
//                     objectId: user.id, name: user.firstName ?? "null")));

//         // text msg
//         var e = <String, dynamic>{
//           ...message,
//           "createdAt":
//               (DateTime.tryParse(message['createdAt'] ?? "") ?? DateTime.now())
//                   .millisecondsSinceEpoch,
//           "updatedAt":
//               (DateTime.tryParse(message['updatedAt'] ?? "") ?? DateTime.now())
//                   .millisecondsSinceEpoch,
//           "id": mess,
//           'type': message['messageFlag'] == 0 ? 'text' : 'interview',
//           'text': message['content'],
//           'status': 'seen',
//           'interview': message['interview'] ?? {},
//           'author': {
//             "firstName": message["senderId"].toString() == user.id
//                 ? user.firstName
//                 : userStore.user!.name,
//             "id": message["senderId"].toString(),
//           }
//         };

//         // TODO: add vô chat store
//         inbox.insert(0, AbstractChatMessage.fromJson(e));
//       } else {
//         // TODO: làm bấm vô nó vào msg
//         NotificationHelper.createTextNotification(
//           id: mess.isNotEmpty
//               ? int.tryParse(mess) ?? rand.nextInt(100000)
//               : rand.nextInt(100000),
//           body: "New interview: ${msg["notification"]["interview"]['title']}",
//         );

//         // interview msg
//         // var id = message["interviewId"].toString();
//         // var projectStore = getIt<ChatStore>();
//         // var interview = await projectStore.getInterview(interviewId: id);
//         var interview = msg["notification"]["interview"];

//         var e = <String, dynamic>{
//           ...message,
//           "id": mess,
//           'type': 'schedule',
//           'text': message['title'],
//           'status': 'seen',
//           'interview': interview,
//           "createdAt":
//               (DateTime.tryParse(message['createdAt'] ?? "") ?? DateTime.now())
//                   .millisecondsSinceEpoch,
//           "updatedAt":
//               (DateTime.tryParse(message['updatedAt'] ?? "") ?? DateTime.now())
//                   .millisecondsSinceEpoch,
//           'author': {
//             "firstName": message["senderId"].toString() == user.id
//                 ? user.firstName
//                 : userStore.user!.name,
//             "id": message["senderId"].toString(),
//           },
//           "metadata": {
//             "title": message['title'],
//             "projectId": project.objectId ?? "-1",
//             "senderId": user.id,
//             "receiverId": userStore.user!.objectId!, // notification
//             "createdAt": (DateTime.tryParse(interview?.createdAt ?? "") ??
//                     DateTime.now())
//                 .millisecondsSinceEpoch,
//             "updatedAt": (DateTime.tryParse(interview?.updatedAt ?? "") ??
//                     DateTime.now())
//                 .millisecondsSinceEpoch,
//             "meeting_room_code": interview?.meetingRoomCode,
//             "meeting_room_id": interview?.meetingRoomId,
//           }
//         };

//         inbox.insert(0, AbstractChatMessage.fromJson(e));
//       }
//       notifyListeners();
//     } else {
//       print("trùng message id ${message["id"]}");
//     }
//   }

//   @override
//   dispose() {
//     super.dispose();
//     // TODO: find a way to close a socket and can reconnect again
//     textSocketHandler.forEach(
//       (key, value) {
//         value.disconnect();
//       },
//     );
//   }
// }
