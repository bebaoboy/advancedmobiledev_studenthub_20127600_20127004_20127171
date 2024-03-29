import 'dart:async';

import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:dio/dio.dart';

import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<User?> login(LoginParams params);

  Future<void> saveIsLoggedIn(bool value);

  Future<bool> get isLoggedIn;

  Future<void> changeUserData(User? user);

  Future<User> get user;

  Future<void> changePassword(String value);

  Future<Response> signUp();
}
