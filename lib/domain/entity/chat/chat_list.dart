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

  // factory WrapMessageList.fromJson(List<dynamic> json) {
  //   List<MessageObject>? messages = <MessageObject>[];
  //   messages = json.map((p) => MessageObject.fromJson(p)).toList();

  //   return WrapMessageList(
  //     messages: messages,
  //   );
  // }
}
