import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:interpolator/interpolator.dart';

class InterviewApi {
  final DioClient _dioClient;

  InterviewApi(this._dioClient);

  Future<Response> scheduleInterview(params) async {
    return await _dioClient.dio.post(Endpoints.postInterview, data: {
      "title": params.title,
      "startDate": params.startDate,
      "endDate": params.endDate,
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> updateInterview(params) async {
    return await _dioClient.dio.patch(
        Interpolator(Endpoints.updateInterview)({"interviewId": params.id}),
        data: {
          "title": params.title,
          "startDate": params.startDate,
          "endDate": params.endDate,
        }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> deleteInterview(params) async {
    return await _dioClient.dio.delete(
        Interpolator(Endpoints.deleteInterview)({"interviewId": params.id}),
        data: {
          "title": params.title,
          "startDate": params.startDate,
          "endDate": params.endDate,
        }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> disableInterview(params) async {
    return await _dioClient.dio
        .patch(Interpolator(Endpoints.updateInterview)(
            ({"interviewId": params.id})))
        .onError(
            (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> checkAvail(params) async {
    return await _dioClient.dio.get(
      Endpoints.checkAvail, data: {
        "meeting_room_code": params.meetingCode,
        "meeting_room_id": params.meetingId,
      }
    ).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }
}
