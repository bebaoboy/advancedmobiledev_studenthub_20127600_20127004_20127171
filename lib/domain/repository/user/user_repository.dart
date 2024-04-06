import 'dart:async';

import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/update_education.dart';
import 'package:boilerplate/domain/usecase/profile/update_language.dart';
import 'package:boilerplate/domain/usecase/profile/update_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/update_project_experience.dart';
import 'package:boilerplate/domain/usecase/profile/update_resume.dart';
import 'package:boilerplate/domain/usecase/profile/update_transcript.dart';
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

  Future<Response> addProfileCompany(AddProfileCompanyParams params);

  Future<Response> updateProfileCompany(AddProfileCompanyParams params);

  Future<Response> addProfileStudent(AddProfileStudentParams params);

  Future<Response> getProfileStudent(UpdateProfileStudentParams params);

  Future<Response> updateProfileStudent(UpdateProfileStudentParams params);

  Future<Response> updateLanguage(UpdateLanguageParams params);

  Future<Response> getLanguage(UpdateLanguageParams params);

  Future<Response> updateEducation(UpdateEducationParams params);

  Future<Response> getEducation(UpdateEducationParams params);

  Future<Response> updateProjectExperience(
      UpdateProjectExperienceParams params);

  Future<Response> getProjectExperience(UpdateProjectExperienceParams params);

  Future<Response> updateResume(UpdateResumeParams params);
  Future<Response> getResume(UpdateResumeParams params);

  Future<Response> updateTranscript(UpdateTranscriptParams params);
  Future<Response> getTranscript(UpdateTranscriptParams params);

  Future<Response> addTechStack(AddTechStackParams params);
  Future<Response> getTechStack(AddTechStackParams params);

  Future<Response> addSkillset(AddSkillsetParams params);
  Future<Response> getSkillset(AddSkillsetParams params);
}
