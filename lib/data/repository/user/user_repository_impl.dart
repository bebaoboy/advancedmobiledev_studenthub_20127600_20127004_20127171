import 'dart:async';

import 'package:boilerplate/data/network/apis/profile/profile_api.dart';
import 'package:boilerplate/data/network/apis/user/user_api.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/update_language.dart';
import 'package:boilerplate/domain/usecase/user/auth/sign_up_usecase.dart';
import 'package:dio/dio.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';

class UserRepositoryImpl extends UserRepository {
  // shared pref object
  final SharedPreferenceHelper _sharedPrefsHelper;

  final UserApi _userApi;
  final ProfileApi _profileApi;

  // constructor
  UserRepositoryImpl(this._sharedPrefsHelper, this._userApi, this._profileApi);

  // Login:---------------------------------------------------------------------
  @override
  Future<User?> login(LoginParams params) async {
    //print('usertype ${params.userType.toString()}');
    return await Future.delayed(
        const Duration(seconds: 2),
        () => User(
            type: getUserType(params.userType ?? 'naught'),
            email: params.username,
            roles: [UserType.company]));
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
    // var response = await _userApi.resetPassword(newPass);
    return;
  }

  @override
  Future<Response> signUp(SignUpParams params) async {
    var response = await _userApi.signUp(params);
    return response;
  }

  @override
  Future<Response> addProfileCompany(AddProfileCompanyParams params) async {
    var response = await _profileApi.addProfileCompany(params);
    return response;
  }

  @override
  Future<Response> addProfileStudent(AddProfileStudentParams params) async {
    var response = await _profileApi.addProfileStudent(params);
    return response;
  }

  @override
  Future<Response> addTechStack(AddTechStackParams params) async {
    var response = await _profileApi.addTechStack(params);
    return response;
  }

    @override
  Future<Response> addSkillset(AddSkillsetParams params) async {
    var response = await _profileApi.addSkillset(params);
    return response;
  }

      @override
  Future<Response> updateLanguage(UpdateLanguageParams params) async {
    var response = await _profileApi.updateLanguage(params);
    return response;
  }
}
