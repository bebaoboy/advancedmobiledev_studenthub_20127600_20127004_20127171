import 'dart:async';
import 'dart:io';

import 'package:boilerplate/data/network/apis/profile/profile_api.dart';
import 'package:boilerplate/data/network/apis/user/user_api.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/update_education.dart';
import 'package:boilerplate/domain/usecase/profile/update_language.dart';
import 'package:boilerplate/domain/usecase/profile/update_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/update_projectexperience.dart';
import 'package:boilerplate/domain/usecase/profile/update_resume.dart';
import 'package:boilerplate/domain/usecase/profile/update_transcript.dart';
import 'package:boilerplate/domain/usecase/user/auth/sign_up_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/change_password_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/get_must_change_pass_usecase.dart';
import 'package:boilerplate/domain/usecase/user/get_profile_usecase.dart';
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
  Future<Response> login(LoginParams params) async {
    //print('usertype ${params.userType.toString()}');
    var response = _userApi.login(params);
    return response;
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

  @override
  Future<Response> signUp(SignUpParams params) async {
    var response = await _userApi.signUp(params);
    return response;
  }

  @override
  Future<bool> saveToken(String value) async {
    return await _sharedPrefsHelper.saveAuthToken(value);
  }

  @override
  Future<FetchProfileResult> getProfileAndSave() async {
    var response = await _userApi.getProfile();

    if (response.statusCode == HttpStatus.accepted ||
        response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      var studentData = response.data["result"]["student"];
      StudentProfile? studentProfile;
      if (studentData != null) {
        studentProfile = StudentProfile.fromMap(studentData);
      } else {
        studentProfile = null;
      }

      var companyData = response.data["result"]["company"];
      CompanyProfile? companyProfile;

      if (companyData != null) {
        companyProfile = CompanyProfile.fromMap(companyData);
      } else {
        companyProfile = null;
      }

      var roleData = response.data["result"]["roles"];
      List<UserType> userRoles;

      var name = response.data['result']['fullname'];
      var id = response.data['result']['id'];

      try {
        if (roleData != null) {
          userRoles = roleData
              .map<UserType>(
                (e) => UserType.values[int.parse(e)],
              )
              .toList();
        } else {
          userRoles = List.empty();
        }
      } catch (e) {
        print(e);
        userRoles = List.empty();
      }

      _sharedPrefsHelper.saveId(id);
      _sharedPrefsHelper.saveName(name);
      _sharedPrefsHelper.saveRolesList(userRoles);
      _sharedPrefsHelper.saveCompanyProfile(companyProfile);
      _sharedPrefsHelper.saveStudentProfile(studentProfile);

      try {
        return FetchProfileResult(
            true, [studentProfile, companyProfile], userRoles, id, name, true);
      } catch (e) {
        return FetchProfileResult(false, [null, null], [], "", "", false);
      }
    } else {
      return FetchProfileResult(false, [null, null], [], "", "", false);
    }
  }

  @override
  Future<void> deleteProfile() {
    return _sharedPrefsHelper.deleteProfile();
  }

  @override
  Future<List<Profile?>> fetchProfileFromSharedPref() {
    return _sharedPrefsHelper.getCurrentProfile();
  }

  @override
  Future<void> logout() async {
    await _userApi.logout();
    await _sharedPrefsHelper.saveIsLoggedIn(false);
    await _sharedPrefsHelper.deleteProfile();
    await _sharedPrefsHelper.removeAuthToken();
    await _sharedPrefsHelper.removeUser();
  }

  @override
  Future<Response> sendResetPasswordMail(String params) async {
    return await _userApi.sendResetPasswordMail(params);
  }

  @override
  Future<Response> changePassword(ChangePasswordParams params) async {
    return await _userApi.changePassword(
        params.newPassword, params.oldPassword);
  }

  @override
  Future saveHasToChangePass(String oldPass, bool value) async {
    await _sharedPrefsHelper.saveOldPassEncrypted(oldPass);
    await _sharedPrefsHelper.saveHasToChangePass(value);
  }

  @override
  Future<HasToChangePassParams> getRequired() async {
    var pass = await _sharedPrefsHelper.oldPass;
    var isRequired = await _sharedPrefsHelper.requiredChangePass;

    return HasToChangePassParams(pass, isRequired);
  }

  Future<Response> addProfileCompany(AddProfileCompanyParams params) async {
    var response = await _profileApi.addProfileCompany(params);
    return response;
  }

    @override
  Future<Response> updateProfileCompany(AddProfileCompanyParams params) async {
    var response = await _profileApi.updateProfileCompany(params);
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

  @override
  Future<Response> updateEducation(UpdateEducationParams params) async {
    var response = await _profileApi.updateEducation(params);
    return response;
  }

  @override
  Future<Response> updateProjectExperience(
      UpdateProjectExperienceParams params) async {
    var response = await _profileApi.updateProjectExperience(params);
    return response;
  }

  @override
  Future<Response> getEducation(UpdateEducationParams params) {
    // TODO: implement getEducation
    throw UnimplementedError();
  }

  @override
  Future<Response> getLanguage(UpdateLanguageParams params) {
    // TODO: implement getLanguage
    throw UnimplementedError();
  }

  @override
  Future<Response> getProjectExperience(UpdateProjectExperienceParams params) {
    // TODO: implement getProjectExperience
    throw UnimplementedError();
  }

  @override
  Future<Response> getResume(UpdateResumeParams params) {
    // TODO: implement getResume
    throw UnimplementedError();
  }

  @override
  Future<Response> getTranscript(UpdateTranscriptParams params) {
    // TODO: implement getTranscript
    throw UnimplementedError();
  }

  @override
  Future<Response> updateProfileStudent(UpdateProfileStudentParams params) {
    // TODO: implement updateProfileStudent
    throw UnimplementedError();
  }

  @override
  Future<Response> updateResume(UpdateResumeParams params) {
    // TODO: implement updateResume
    throw UnimplementedError();
  }

  @override
  Future<Response> updateTranscript(UpdateTranscriptParams params) {
    // TODO: implement updateTranscript
    throw UnimplementedError();
  }
}
