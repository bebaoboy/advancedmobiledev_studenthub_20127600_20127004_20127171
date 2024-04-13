import 'dart:io';

import 'package:boilerplate/core/widgets/xmpp/logger/Log.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/network/apis/project/project_api.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';
import 'package:boilerplate/domain/usecase/project/update_favorite.dart';
import 'package:boilerplate/domain/usecase/project/create_project.dart';
import 'package:boilerplate/domain/usecase/project/delete_project.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
import 'package:boilerplate/domain/usecase/project/get_projects.dart';
import 'package:boilerplate/domain/usecase/project/get_student_proposal_projects.dart';
import 'package:boilerplate/domain/usecase/project/update_company_project.dart';
import 'package:dio/dio.dart';

class ProjectRepositoryImpl extends ProjectRepository {
  final ProjectApi _projectApi;
  final ProjectDataSource _datasource;
  ProjectRepositoryImpl(this._projectApi, this._datasource);

  @override
  Future<ProjectList> fetchPagingProjects(GetProjectParams params) async {
    try {
      final value = await _projectApi.getProjects(params);
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        var result = ProjectList.fromJson(value.data["result"]);
        result.projects?.forEach((project) {
          _datasource.insert(project);
        });
        return result;
      } else {
        // return ProjectList(projects: List.empty(growable: true));
        return _datasource.getProjectsFromDb() as ProjectList;
      }
      // ignore: invalid_return_type_for_catch_error
    } catch (e) {
      Log.e("ProjectRepo", e.toString());
      return await _datasource.getProjectsFromDb();
    }
  }

  @override
  Future<Response> getProjectByCompany(GetProjectByCompanyParams params) async {
    var response = await _projectApi.getProjectByCompany(params);
    return response;
  }

  @override
  Future<Response> getStudentProposalProjects(
      GetStudentProposalProjectsParams params) async {
    var response = await _projectApi.getStudentProposalProjects(params);
    return response;
  }

  @override
  Future<Response> updateCompanyProject(UpdateProjectParams params) async {
    var response = await _projectApi.updateCompanyProject(params);
    return response;
  }

  @override
  Future<Response> createProject(createProjectParams params) async {
    var reponse = await _projectApi.createProjects(params);
    return reponse;
  }

  @override
  Future<Response> deleteProject(deleteProjectParams params) async {
    var reponse = await _projectApi.deleteProjects(params);
    return reponse;
  }

  @override
  Future<Response> updateFavoriteProject(
      updateFavoriteProjectParams params) async {
    var reponse = await _projectApi.updateFavoriteProjects(params);
    return reponse;
  }
}
