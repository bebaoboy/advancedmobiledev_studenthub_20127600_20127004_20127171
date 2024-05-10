// ignore_for_file: unused_field

import 'dart:async';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/usecase/noti/get_noti_usecase.dart';
import 'package:interpolator/interpolator.dart';
import 'package:dio/dio.dart';

class NotiApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  NotiApi(this._dioClient);

  Future<Response> getNoti(GetNotiParams params) async {
    return await _dioClient.dio.get(
        Interpolator(Endpoints.getNoti)({"receiverId": params.receiverId}),
        data: {}).onError((DioException error,
            stackTrace) =>
        Future.value(
            error.response ?? Response(requestOptions: RequestOptions())));
  }
}
