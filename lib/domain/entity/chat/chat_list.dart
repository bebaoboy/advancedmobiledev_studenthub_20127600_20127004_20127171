import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/type/user.dart';

class WrapMessageList {
  List<MessageObject>? messages;
  Project? project;
  ChatUser chatUser;

  WrapMessageList({required this.messages, this.project, required this.chatUser});

  // factory WrapMessageList.fromJson(List<dynamic> json) {
  //   List<MessageObject>? messages = <MessageObject>[];
  //   messages = json.map((p) => MessageObject.fromJson(p)).toList();

  //   return WrapMessageList(
  //     messages: messages,
  //   );
  // }
}
