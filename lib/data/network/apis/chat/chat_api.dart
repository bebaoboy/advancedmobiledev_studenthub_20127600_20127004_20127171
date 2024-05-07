import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
import 'package:boilerplate/domain/usecase/chat/post_message.dart';
import 'package:dio/dio.dart';
import 'package:interpolator/interpolator.dart';

class ChatApi {
  // dio instance
  final DioClient _dioClient;

  // rest-client instance

  // injecting dio instance
  ChatApi(this._dioClient);

  Future<Response> getMessageByProjectAndUser(
      GetMessageByProjectAndUserParams params) async {
    return await _dioClient.dio
        .get(
      Interpolator(Endpoints.getMessageByProjectAndUser)(
          {"projectId": params.projectId, "userId": params.userId}),
    )
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getAllChat(GetMessageByProjectAndUserParams params) async {
    return await _dioClient.dio
        .get(
      Endpoints.getAllChat,
    )
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> postMessage(PostMessageParams params) async {
    return await _dioClient.dio.post(Endpoints.postMessage, data: {
      "content": params.content,
      "projectId": params.projectId,
      "senderId": params.senderId,
      "receiverId": params.receiverId, // notification
      "messageFlag": 0
    }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }
}
