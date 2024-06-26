import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/usecase/project/update_favorite.dart';
import 'package:boilerplate/domain/usecase/project/create_project.dart';
import 'package:boilerplate/domain/usecase/project/delete_project.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
import 'package:boilerplate/domain/usecase/project/get_projects.dart';
import 'package:boilerplate/domain/usecase/project/get_student_proposal_projects.dart';
import 'package:boilerplate/domain/usecase/project/update_company_project.dart';
import 'package:boilerplate/domain/usecase/proposal/post_proposal.dart';
import 'package:boilerplate/domain/usecase/proposal/update_proposal.dart';
import 'package:dio/dio.dart';
import 'package:interpolator/interpolator.dart';

class ProjectApi {
  // dio instance
  final DioClient _dioClient;

  // rest-client instance

  // injecting dio instance
  ProjectApi(this._dioClient);

  Future<Response> getProjects(GetProjectParams params) async {
    Map<String, dynamic>? q = {};
    if (params.title != null) {
      q.putIfAbsent("title", () => params.title);
      q.putIfAbsent("numberOfStudents", () => params.numberOfStudents);
      q.putIfAbsent("projectScopeFlag", () => params.projectScopeFlag);
      q.putIfAbsent("proposalsLessThan", () => params.proposalsLessThan);
    }
    q.putIfAbsent("page", () => 1);
    q.putIfAbsent("perPage", () => 100000);
    return await _dioClient.dio
        .get(Endpoints.getProjects, data: {}, queryParameters: q)
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getProjectByCompany(GetProjectByCompanyParams params) async {
    return await _dioClient.dio
        .get(
      Interpolator(Endpoints.getCurrentCompanyProjects)(
          {"companyId": params.companyId}),
      queryParameters: params.typeFlag != null
          ? {"typeFlag": params.typeFlag.toString()}
          : null,
    )
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getStudentProposalProjects(
      GetStudentProposalProjectsParams params) async {
    return await _dioClient.dio
        .get(
      Interpolator(Endpoints.getStudentProposalProjects)(
          {"studentId": params.studentId}),
      queryParameters: params.statusFlag != null
          ? {"statusFlag": params.statusFlag.toString()}
          : null,
    )
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> postProposal(PostProposalParams params) async {
    return await _dioClient.dio.post(Endpoints.postProposal, data: {
      "projectId": params.projectId,
      "studentId": params.studentId,
      "coverLetter": params.coverLetter,
      "statusFlag": params.status,
      "disableFlag": params.disableFlag
    }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateProposal(UpdateProposalParams params) async {
    return await _dioClient.dio.patch(
        Interpolator(Endpoints.updateProposal)({"id": params.proposalId}),
        data: {
          "coverLetter": params.coverLetter,
          "statusFlag": params.status,
          "disableFlag": params.disableFlag
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getStudentFavoriteProjects(String studentId) async {
    return await _dioClient.dio
        .get(
      Interpolator(Endpoints.getUserFavoriteProjects)({"studentId": studentId}),
      // queryParameters: params.statusFlag != null
      //     ? {"statusFlag": params.statusFlag.toString()}
      //     : null,
    )
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateCompanyProject(UpdateProjectParams params) async {
    var p = {
      'projectScopeFlag': params.projectScope,
      'title': params.title,
      'description': params.description,
      'numberOfStudents': params.numberOfStudent
    };
    if (params.statusFlag != null) {
      p.putIfAbsent("typeFlag", () => params.statusFlag!);
    }
    if (params.closeStatus != null) {
      p.putIfAbsent("status", () => params.closeStatus!);
    }
    return await _dioClient.dio
        .patch(
            Interpolator(Endpoints.updateProject)(
                {"projectId": params.projectId}),
            data: p)
        .onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> createProjects(CreateProjectParams params) async {
    return await _dioClient.dio.post(Endpoints.addNewProject, data: {
      "companyId": params.companyId,
      "projectScopeFlag": params.projectScopeFlag,
      "title": params.title,
      "description": params.description,
      "typeFlag": params.typeFlag ? 0 : 1,
      "numberOfStudents": params.numberOfStudents,
    }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      if (error.response != null) {
        return Future.value(
            error.response ?? Response(requestOptions: RequestOptions()));
      } else {
        // Handle the case when error.response ?? Response(requestOptions: RequestOptions()) is null
        return Future.error('An error occurred: ${error.message}');
      }
    }).whenComplete(() => null);
  }

  Future<Response> deleteProjects(DeleteProjectParams params) async {
    return await _dioClient.dio.delete(
        Interpolator(Endpoints.deleteProject)({"projectId": params.Id}),
        data: {}).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> updateFavoriteProjects(
      UpdateFavoriteProjectParams params) async {
    return await _dioClient.dio.patch(
        Interpolator(Endpoints.updateUserFavoriteProject)(
            {"studentId": params.studentId}),
        data: {
          "projectId": int.parse(params.projectId),
          "disableFlag": params.disableFlag ? 0 : 1
        }).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  Future<Response> getProjectProposals(Project params) async {
    return await _dioClient.dio.get(
        Interpolator(Endpoints.getCandidatesOfProject)(
            {"projectId": params.objectId}),
        queryParameters: {}).onError((DioException error, stackTrace) {
      var dioClient = getIt<DioClient>();
      dioClient.clearDio();
      return Future.value(
          error.response ?? Response(requestOptions: RequestOptions()));
    });
  }

  // Future<Response> filterProjects() async {
  //   return await _dioClient.dio.post(Endpoints.)
  // }
}
