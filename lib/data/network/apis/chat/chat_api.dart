import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/usecase/chat/get_all_chat.dart';
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
        .onError(
            (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> getAllChat(GetMessageByProjectAndUserParams params) async {
    return await _dioClient.dio
        .get(
          Endpoints.getAllChat,
        )
        .onError(
            (DioException error, stackTrace) => Future.value(error.response));
  }

  // Future<Response> postProposal(PostProposalParams params) async {
  //   return await _dioClient.dio.post(Endpoints.postProposal, data: {
  //     "projectId": params.projectId,
  //     "studentId": params.studentId,
  //     "coverLetter": params.coverLetter,
  //     "statusFlag": params.status,
  //     "disableFlag": params.disableFlag
  //   }).onError(
  //       (DioException error, stackTrace) => Future.value(error.response));
  // }

  // Future<Response> updateProposal(UpdateProposalParams params) async {
  //   return await _dioClient.dio.patch(
  //       Interpolator(Endpoints.updateProposal)({"id": params.proposalId}),
  //       data: {
  //         "coverLetter": params.coverLetter,
  //         "statusFlag": params.status,
  //         "disableFlag": params.disableFlag
  //       }).onError(
  //       (DioException error, stackTrace) => Future.value(error.response));
  // }
}
