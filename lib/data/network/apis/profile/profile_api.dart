// ignore_for_file: unused_field

import 'dart:async';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/rest_client.dart';
import 'package:boilerplate/di/service_locator.dart';
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
import 'package:interpolator/interpolator.dart';
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
    }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getCompanyProfile(AddProfileCompanyParams params) async {
    return await _dioClient.dio.get(
        Interpolator(Endpoints.getProfileCompany)({"companyId": params.id}),
        data: {}).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateProfileCompany(AddProfileCompanyParams params) async {
    return await _dioClient.dio.put(
        Interpolator(Endpoints.updateProfileCompany)({"id": params.id}),
        data: {
          "companyName": params.companyName,
          "website": params.website,
          "description": params.description,
          "size": params.size,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> addProfileStudent(AddProfileStudentParams params) async {
    return await _dioClient.dio.post(Endpoints.addProfileStudent, data: {
      "techStackId": params.techStack,
      "skillSets": params.skillSet,
    }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateProfileStudent(
      UpdateProfileStudentParams params) async {
    return await _dioClient.dio.put(
        Interpolator(Endpoints.updateProfileStudent)({"id": params.id}),
        data: {
          "techStackId": params.techStack,
          "skillSets": params.skillSet,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getProfileStudent(UpdateProfileStudentParams params) async {
    return await _dioClient.dio
        .get(
      Interpolator(Endpoints.getProfileStudent)({"studentId": params.id}),
    )
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateLanguage(UpdateLanguageParams params) async {
    return await _dioClient.dio.put(
        Interpolator(Endpoints.updateLanguage)({"studentId": params.studentId}),
        data: {
          "languages": params.languages,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getLanguage(UpdateLanguageParams params) async {
    return await _dioClient.dio.get(
        Interpolator(Endpoints.getLanguage)({"studentId": params.studentId}),
        data: {
          // "languages": params.languages,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateEducation(UpdateEducationParams params) async {
    return await _dioClient.dio.put(
        Interpolator(Endpoints.updateEducation)(
            {"studentId": params.studentId}),
        data: {
          "education": params.educations,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getEducation(UpdateEducationParams params) async {
    return await _dioClient.dio.get(
        Interpolator(Endpoints.getEducation)({"studentId": params.studentId}),
        data: {
          // "education": params.educations,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateProjectExperience(
      UpdateProjectExperienceParams params) async {
    return await _dioClient.dio.put(
        Interpolator(Endpoints.updateProjectExperience)(
            {"studentId": params.studentId}),
        data: {
          "experience": params.projectExperiences,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getProjectExperience(
      UpdateProjectExperienceParams params) async {
    return await _dioClient.dio.get(
        Interpolator(Endpoints.getProjectExperience)(
            {"studentId": params.studentId}),
        data: {
          // "experience": params.projectExperiences,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getResume(UpdateResumeParams params) async {
    return await _dioClient.dio.get(
        Interpolator(Endpoints.getResume)({"studentId": params.studentId}),
        data: {
          // "education": params.educations,
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateResume(UpdateResumeParams params) async {
    // File file;
    // try {
    //   file = File.fromUri(Uri.file(params.path));
    // } catch (e) {
    //   return Future.value(Response(
    //       requestOptions: RequestOptions(),
    //       data: {"errorDetails": "File not found!"}));
    // }
    // var mFile = MultipartFile.fromFile(
    //   params.path,
    //   // contentType:
    //   //     MediaType.parse(lookupMimeType(params.path) ?? "text/plain"),
    //   filename: params.path.split('/').last,
    // );
    // try {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        params.path,
        // contentType:
        //     MediaType.parse(lookupMimeType(params.path) ?? "text/plain"),
        filename: params.path.split('/').last,
      )
    });
    return await _dioClient.dio.put(
      Interpolator(Endpoints.updateResume)({"studentId": params.studentId}),
      data: formData,
      onSendProgress: (count, total) {
        print(
            'upload resume: progress: ${(count / total * 100).toStringAsFixed(0)}% ($count/$total)');
      },
    ).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
    // } catch (e) {
    //   return Future.value(Response(
    //       requestOptions: RequestOptions(),
    //       data: {"errorDetails": "File not found ${e.toString()}"}));
    // }
  }

  Future<Response> deleteResume(UpdateResumeParams params) async {
    return await _dioClient.dio
        .delete(
      Interpolator(Endpoints.deleteResume)({"studentId": params.studentId}),
      // data: formData,
      // onSendProgress: (count, total) {
      //   print(
      //       'upload resume: progress: ${(count / total * 100).toStringAsFixed(0)}% ($count/$total)');
      // },
    )
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getTranscript(UpdateTranscriptParams params) async {
    return await _dioClient.dio.get(
        Interpolator(Endpoints.getTranscript)({"studentId": params.studentId}),
        data: {
          // "education": params.educations,
        }).onError((DioException error, stackTrace) => Future.value(
                error.response ?? Response(requestOptions: RequestOptions()))
            .whenComplete(
          () => null,
        ));
  }

  Future<Response> updateTranscript(UpdateTranscriptParams params) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          params.transcript,
          // contentType:
          //     MediaType.parse(lookupMimeType(params.path) ?? "text/plain"),
          filename: params.transcript.split('/').last,
        )
      });
      return await _dioClient.dio.put(
        Interpolator(Endpoints.updateTranscript)(
            {"studentId": params.studentId}),
        data: formData,
        onSendProgress: (count, total) {
          print(
              'upload resume: progress: ${(count / total * 100).toStringAsFixed(0)}% ($count/$total)');
        },
      ).onError((DioException error, stackTrace) {
        var dioClient = getIt<DioClient>();
        dioClient.clearDio();
        return Future.value(
            error.response ?? Response(requestOptions: RequestOptions()));
      });
    } catch (e) {
      return Future.value(Response(
          requestOptions: RequestOptions(),
          data: {"errorDetails": "File not found ${e.toString()}"}));
    }
  }

  Future<Response> deleteTranscript(UpdateTranscriptParams params) async {
    // try {
    // FormData formData = FormData.fromMap({
    //   "file": await MultipartFile.fromFile(
    //     params.transcript,
    //     // contentType:
    //     //     MediaType.parse(lookupMimeType(params.path) ?? "text/plain"),
    //     filename: params.transcript.split('/').last,
    //   )
    // });
    return await _dioClient.dio
        .delete(
      Interpolator(Endpoints.deleteTranscript)({"studentId": params.studentId}),
      // data: formData,
      // onSendProgress: (count, total) {
      //   print(
      //       'upload resume: progress: ${(count / total * 100).toStringAsFixed(0)}% ($count/$total)');
      // },
    )
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
    // } catch (e) {
    //   return Future.value(Response(
    //       requestOptions: RequestOptions(),
    //       data: {"errorDetails": "File not found ${e.toString()}"}));
    // }
  }

  Future<Response> addTechStack(AddTechStackParams params) async {
    return await _dioClient.dio.post(Endpoints.addTechStack, data: {
      "name": params.name,
    }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getTechStack(AddTechStackParams params) async {
    return await _dioClient.dio.get(Endpoints.getTechStack, data: {}).onError(
        (DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> addSkillset(AddSkillsetParams params) async {
    return await _dioClient.dio.post(Endpoints.addSkillset, data: {
      "name": params.name,
    }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getSkillset(AddSkillsetParams params) async {
    return await _dioClient.dio.get(Endpoints.getSkillset, data: {}).onError(
        (DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }
}
