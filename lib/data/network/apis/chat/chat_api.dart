import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/usecase/chat/get_message_by_project_and_user.dart';
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
        .onError((DioException error, stackTrace) => Future.value(
                    error.response ??
                        Response(requestOptions: RequestOptions()))
                .whenComplete(
              () => _dioClient.clearDio(),
            ));
  }

  Future<Response> getAllChat(GetMessageByProjectAndUserParams params) async {
    return await _dioClient.dio
        .get(
          Endpoints.getAllChat,
        )
        .onError((DioException error, stackTrace) => Future.value(
                    error.response ??
                        Response(requestOptions: RequestOptions()))
                .whenComplete(
              () => _dioClient.clearDio(),
            ));
  }
}
