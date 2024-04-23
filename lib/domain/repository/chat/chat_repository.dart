import 'package:boilerplate/domain/usecase/chat/get_all_chat.dart';
import 'package:dio/dio.dart';

abstract class ChatRepository {
  Future<Response> getMessageByProjectAndUser(GetMessageByProjectAndUserParams params);
  Future<Response> getAllChat(GetMessageByProjectAndUserParams params);
}
