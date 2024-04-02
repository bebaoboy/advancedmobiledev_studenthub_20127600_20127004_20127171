import 'dart:async';

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/user/auth/sign_up_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/change_password_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/get_must_change_pass_usecase.dart';
import 'package:boilerplate/domain/usecase/user/get_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:dio/dio.dart';

import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<Response> login(LoginParams params);

  Future<void> saveIsLoggedIn(bool value);

  Future<bool> get isLoggedIn;

  Future<void> changeUserData(User? user);

  Future<User> get user;

  Future<Response> changePassword(ChangePasswordParams value);

  Future<Response> signUp(SignUpParams params);

  Future<bool> saveToken(String value);

  Future<FetchProfileResult> getProfileAndSave();

  Future<void> deleteProfile();

  Future<List<Profile?>> fetchProfileFromSharedPref();

  Future<void> logout();

  Future<Response> sendResetPasswordMail(String params);

  void saveHasToChangePass(String oldPass, bool bool);

  Future<HasToChangePassParams> getRequired();
}
