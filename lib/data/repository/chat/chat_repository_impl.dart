
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/network/apis/chat/chat_api.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';
import 'package:boilerplate/domain/usecase/chat/get_all_chat.dart';
import 'package:dio/dio.dart';

class ChatRepositoryImpl extends ChatRepository {
  final ChatApi _chatApi;
  final ProjectDataSource _datasource;
  final SharedPreferenceHelper _sharedPrefHelper;
  ChatRepositoryImpl(
      this._chatApi, this._datasource, this._sharedPrefHelper);

  @override
  Future<Response> getAllChat(GetMessageByProjectAndUserParams params) async {
    var response = await _chatApi.getAllChat(params);
    return response;
  }

  @override
  Future<Response> getMessageByProjectAndUser(
      GetMessageByProjectAndUserParams params) async {
    var response = await _chatApi.getMessageByProjectAndUser(params);
    return response;
  }
}
