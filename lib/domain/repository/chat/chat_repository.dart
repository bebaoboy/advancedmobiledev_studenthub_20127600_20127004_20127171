import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
import 'package:boilerplate/presentation/dashboard/chat/type/message.dart';

abstract class ChatRepository {
  Future<List<AbstractChatMessage>> getMessageByProjectAndUser(
      GetMessageByProjectAndUserParams params);
  Future<List<WrapMessageList>> getAllChat(GetMessageByProjectAndUserParams params);

  Future<List<WrapMessageList>> getMessageOfOneChat();
}
