// ignore_for_file: unused_field

import 'dart:async';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/rest_client.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/update_language.dart';

import 'package:dio/dio.dart';

class ProfileApi {
  // dio instance
  final DioClient _dioClient;

  // rest-client instance
  final RestClient _restClient;

  // injecting dio instance
  ProfileApi(this._dioClient, this._restClient);

  // Future<Response> resetPassword(String newPass) async {
  //   // try {
  //   //   final res = await _dioClient.dio.put(Endpoints.resetPassword,
  //   //       data: {"oldPassword": "randomU4String", "newPassword": newPass});
  //   //   return res;
  //   // } catch (e) {
  //   //   //print(e.toString());
  //   //   rethrow;
  //   // }
  // }

  Future<Response> addProfileCompany(AddProfileCompanyParams params) async {
    return await _dioClient.dio.post(Endpoints.addProfileCompany, data: {
      "companyName": params.companyName,
      "website": params.website,
      "description": params.description,
      "size": params.size,
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> addProfileStudent(AddProfileStudentParams params) async {
    return await _dioClient.dio.post(Endpoints.addProfileStudent, data: {
      "techStackId": params.techStack,
      "skillSets": params.skillSet,
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> addTechStack(AddTechStackParams params) async {
    return await _dioClient.dio.post(Endpoints.addTechStack, data: {
      "name": params.name,
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> addSkillset(AddSkillsetParams params) async {
    return await _dioClient.dio.post(Endpoints.addSkillset, data: {
      "name": params.name,
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

    Future<Response> updateLanguage(UpdateLanguageParams params) async {
    return await _dioClient.dio.put(Endpoints.updateLanguage, data: {
      "languages": params.languages
    }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }
}
