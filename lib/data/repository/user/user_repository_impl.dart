import 'dart:async';

import 'package:boilerplate/data/network/apis/user/user_api.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:dio/dio.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';

class UserRepositoryImpl extends UserRepository {
  // shared pref object
  final SharedPreferenceHelper _sharedPrefsHelper;

  final UserApi _userApi;

  // constructor
  UserRepositoryImpl(this._sharedPrefsHelper, this._userApi);

  // Login:---------------------------------------------------------------------
  @override
  Future<User?> login(LoginParams params) async {
    //print('usertype ${params.userType.toString()}');
    return await Future.delayed(
        const Duration(seconds: 2),
        () => User(
            type: getUserType(params.userType ?? 'company'),
            email: params.username));
  }

  @override
  Future<void> saveIsLoggedIn(bool value) =>
      _sharedPrefsHelper.saveIsLoggedIn(value);

  @override
  Future<bool> get isLoggedIn => _sharedPrefsHelper.isLoggedIn;

  @override
  Future<void> changeUserData(User? user) => _sharedPrefsHelper.saveUser(user);

  @override
  // ToDO: implement user
  Future<User> get user => _sharedPrefsHelper.user;

  @override
  Future<void> changePassword(String newPass) async {
    var response = await _userApi.resetPassword(newPass);
    return;
  }

  @override
  Future<Response> signUp() async {
    var response = await _userApi.signUp();
    return response;
  }
}
