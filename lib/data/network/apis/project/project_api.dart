import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
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

  Future<Response> getProjectByCompany(GetProjectByCompanyParams params) async {
    return await _dioClient.dio
        .get(
          Interpolator(Endpoints.getCurrentCompanyProjects)(
              {"companyId": params.companyId}),
          queryParameters: params.typeFlag != null
              ? {"typeFlag": params.typeFlag.toString()}
              : null,
        )
        .onError(
            (DioException error, stackTrace) => Future.value(error.response));
  }

  // Future<Response> filterProjects() async {
  //   return await _dioClient.dio.post(Endpoints.)
  // }
}
