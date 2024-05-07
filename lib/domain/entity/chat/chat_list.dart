import 'dart:convert';

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/type/user.dart';
import 'package:mobx/mobx.dart';

class WrapMessageList {
  @observable
  List<MessageObject>? messages;
  @observable
  Project? project;
  @observable
  ChatUser chatUser;
  @observable
  DateTime? lastSeenTime = DateTime.now();
  @observable
  int get newMessageCount => lastSeenTime == null
      ? 0
      : messages
              ?.where(
                (element) => element.updatedAt?.isAfter(lastSeenTime!) ?? false,
              )
              .length ??
          0;

  WrapMessageList(
      {required this.messages,
      this.project,
      required this.chatUser,
      this.lastSeenTime});

  Map<String, dynamic> toJson() {
    return {
      "user": chatUser.toJson(),
      "project": project?.toJson(),
      "lastSeenTime": lastSeenTime?.millisecondsSinceEpoch,
      "messages": messages!.map((e) => e.toJson()).toList()
    };
  }

  factory WrapMessageList.fromJson(Map<String, dynamic> json1) {
    List<MessageObject> messages = [];
    var messageList = json1["messages"];
    for (var p in messageList) {
      var message = MessageObject.fromJson(json.decode(p));
      messages.add(message);
    }

    ChatUser user = ChatUser.fromJson(json1["user"]);
    Project project = Project.fromMap(json1["project"]);
    var lastSeenTime =
        json1["lastSeenTime"] ?? DateTime.now().millisecondsSinceEpoch;

    return WrapMessageList(
        messages: messages,
        chatUser: user,
        project: project,
        lastSeenTime: DateTime.fromMillisecondsSinceEpoch(lastSeenTime));
  }
}
