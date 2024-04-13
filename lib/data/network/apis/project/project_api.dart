import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/usecase/project/update_favorite.dart';
import 'package:boilerplate/domain/usecase/project/create_project.dart';
import 'package:boilerplate/domain/usecase/project/delete_project.dart';
import 'package:dio/dio.dart';
import 'package:interpolator/interpolator.dart';

class ProjectApi {
  // dio instance
  final DioClient _dioClient;

  // rest-client instance

  // injecting dio instance
  ProjectApi(this._dioClient);

  Future<Response> getProjects() async {
    return await _dioClient.dio.get(Endpoints.getProjects, data: {}).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  Future<Response> createProjects(createProjectParams params) async {
    return await _dioClient.dio.post(Endpoints.addNewProject, data: {
      "companyId": params.companyId,
      "projectScopeFlag": params.projectScopeFlag,
      "title": params.title,
      "description": params.description,
      "typeFlag": params.typeFlag,
      "numberOfStudents": params.numberOfStudents,
    }).onError((DioException error, stackTrace) {
      if (error.response != null) {
        return Future.value(error.response);
      } else {
        // Handle the case when error.response is null
        return Future.error('An error occurred: ${error.message}');
      }
    });
  }

  Future<Response> deleteProjects(deleteProjectParams params) async {
    return await _dioClient.dio.delete(
        Interpolator(Endpoints.deleteProject)({"projectId": params.Id}),
        data: {}).onError((DioException error,
            stackTrace) =>
        Future.value(error.response));
  }

  Future<Response> updateFavoriteProjects(
      updateFavoriteProjectParams params) async {
    return await _dioClient.dio.patch(
        Interpolator(Endpoints.updateUserFavoriteProject)(
            {"studentId": params.studentId}),
        data: {
          "projectId": params.projectId,
          "disableFlag": params.disableFlag
        }).onError(
        (DioException error, stackTrace) => Future.value(error.response));
  }

  // Future<Response> filterProjects() async {
  //   return await _dioClient.dio.post(Endpoints.)
  // }
}
