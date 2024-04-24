import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';

abstract class ChatRepository {
  Future<List<WrapMessageList>> getMessageByProjectAndUser(
      GetMessageByProjectAndUserParams params);
  Future<List<WrapMessageList>> getAllChat(GetMessageByProjectAndUserParams params);
}
