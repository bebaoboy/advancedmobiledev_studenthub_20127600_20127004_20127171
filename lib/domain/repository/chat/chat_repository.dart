import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
import 'package:boilerplate/domain/usecase/chat/post_message.dart';
import 'package:boilerplate/presentation/dashboard/chat/type/message.dart';
import 'package:dio/dio.dart';

abstract class ChatRepository {
  Future<List<AbstractChatMessage>> getMessageByProjectAndUser(
      GetMessageByProjectAndUserParams params);
  Future<List<WrapMessageList>> getAllChat(
      GetMessageByProjectAndUserParams params);
  Future<Response> postMessage(PostMessageParams params);
}
