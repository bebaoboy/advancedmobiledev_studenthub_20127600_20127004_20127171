import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';

class WrapMessageList {
  List<MessageObject>? messages;
  Project? project;

  WrapMessageList({required this.messages, this.project});

  factory WrapMessageList.fromJson(List<dynamic> json) {
    List<MessageObject>? messages = <MessageObject>[];
    messages = json.map((p) => MessageObject.fromJson(p)).toList();

    return WrapMessageList(
      messages: messages,
    );
  }
}
