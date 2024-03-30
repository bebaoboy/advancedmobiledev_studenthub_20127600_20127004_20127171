// ignore_for_file: unused_field

import 'dart:async';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/rest_client.dart';
import 'package:dio/dio.dart';

class UserApi {
  // dio instance
  final DioClient _dioClient;

  // rest-client instance
  final RestClient _restClient;

  // injecting dio instance
  UserApi(this._dioClient, this._restClient);

  Future<Response> resetPassword(String newPass) async {
    try {
      final res = await _dioClient.dio.put(Endpoints.resetPassword, data: {
        "oldPassword": "randomU4String",
        "newPassword": newPass
      });
      return res;
    } catch (e) {
      //print(e.toString());
      rethrow;
    }
  }

  Future<Response> signUp() async {
    return await _dioClient.dio.post(Endpoints.signUp, data: {
      "email": "testUser@gmail.com",
      "password": "12345678Quan++!@",
      "fullname": "User test",
      "role": 0,
    });
  }
}
