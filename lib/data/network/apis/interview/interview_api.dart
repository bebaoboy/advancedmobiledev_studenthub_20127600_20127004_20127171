import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/di/service_locator.dart';
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
    }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateInterview(params) async {
    return await _dioClient.dio.patch(
        Interpolator(Endpoints.updateInterview)({"interviewId": params.interviewId}),
        data: {
          "title": params.title,
          "startDate": params.startDate,
          "endDate": params.endDate,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> deleteInterview(params) async {
    return await _dioClient.dio.delete(
        Interpolator(Endpoints.deleteInterview)({"interviewId": params.interviewId}),
        data: {
          "title": params.title,
          "startDate": params.startDate,
          "endDate": params.endDate,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> disableInterview(params) async {
    return await _dioClient.dio
        .patch(Interpolator(Endpoints.disableInterview)(
            ({"interviewId": params.interviewId})))
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }
}
