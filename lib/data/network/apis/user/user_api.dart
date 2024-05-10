// ignore_for_file: unused_field

import 'dart:async';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/usecase/user/auth/sign_up_usecase.dart';

import '../../../../domain/usecase/user/login_usecase.dart';
import 'package:dio/dio.dart';

class UserApi {
  // dio instance
  final DioClient dioClient;

  // injecting dio instance
  UserApi(this.dioClient);

  Future<Response> resetPassword(String newPass) async {
    try {
      final res = await dioClient.dio.put(Endpoints.resetPassword,
          data: {"oldPassword": "randomU4String", "newPassword": newPass});
      return res;
    } catch (e) {
      //print(e.toString());
      rethrow;
    }
  }

  Future<Response> signUp(SignUpParams params) async {
    return await dioClient.dio.post(Endpoints.signUp, data: {
      "email": params.email,
      "password": params.password,
      "fullname": params.fullname,
      "role": params.type?.index,
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> login(LoginParams params) async {
    return await dioClient.dio.post(Endpoints.login, data: {
      "email": params.username,
      "password": params.password,
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> getProfile() async {
    return await dioClient.dio.get(Endpoints.getProfile, data: {}).onError(
        (DioException exception, stackTrace) =>
            Future.value(exception.response));
  }

  Future<void> logout() async {
    try {
      await dioClient.dio.post(Endpoints.logout, data: {});
    } catch (e) {
      print(e);
    }
  }

  Future<Response> sendResetPasswordMail(String email) async {
    return await dioClient.dio
        .post(Endpoints.forgetPassword, data: {"email": email}).onError(
            (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> changePassword(
      String newPassword, String oldPassword) async {
    return await dioClient.dio.put(Endpoints.changePassword, data: {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }
}
