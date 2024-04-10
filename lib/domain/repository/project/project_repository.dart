import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
import 'package:dio/dio.dart';

abstract class ProjectRepository {
  Future<ProjectList> fetchPagingProjects();

  Future<Response> getProjectByCompany(GetProjectByCompanyParams params);
}
