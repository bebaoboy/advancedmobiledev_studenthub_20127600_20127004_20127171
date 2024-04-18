import 'dart:io';

import 'package:boilerplate/core/widgets/xmpp/logger/Log.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/network/apis/project/project_api.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';
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

class ProjectRepositoryImpl extends ProjectRepository {
  final ProjectApi _projectApi;
  final ProjectDataSource _datasource;
  final SharedPreferenceHelper _sharedPrefHelper;
  ProjectRepositoryImpl(
      this._projectApi, this._datasource, this._sharedPrefHelper);

  @override
  Future<ProjectList> fetchPagingProjects(GetProjectParams params) async {
    try {
      final value = await _projectApi.getProjects(params);
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        List json = value.data["result"];

        return ProjectList(projects: null, data: json);
      } else {
        // return ProjectList(projects: List.empty(growable: true));
        return _datasource.getProjectsFromDb() as ProjectList;
      }
      // ignore: invalid_return_type_for_catch_error
    } catch (e) {
      Log.e("ProjectRepo", e.toString());
      return _datasource.getProjectsFromDb();
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
  Future<ProjectList> getStudentFavoriteProjects() async {
    var profiles = await _sharedPrefHelper.getCurrentProfile();
    var studentId = (profiles[0] as StudentProfile?)?.objectId;

    if (studentId != null && studentId.isNotEmpty) {
      try {
        var response = await _projectApi.getStudentFavoriteProjects(studentId);

        if (response.statusCode == HttpStatus.accepted ||
            response.statusCode == HttpStatus.ok ||
            response.statusCode == HttpStatus.created) {
          var projectList =
              ProjectList.fromJsonWithPrefix(response.data["result"]);
          _sharedPrefHelper.saveFavoriteProjects(projectList);
          return projectList;
        } else {
          return _sharedPrefHelper.getFavoriteProjects();
        }
      } catch (e) {
        return _sharedPrefHelper.getFavoriteProjects();
      }
    } else {
      return ProjectList(projects: List.empty(growable: true));
    }
  }

  @override
  Future<Response> updateCompanyProject(UpdateProjectParams params) async {
    var response = await _projectApi.updateCompanyProject(params);
    return response;
  }

  @override
  Future<Response> createProject(CreateProjectParams params) async {
    var response = await _projectApi.createProjects(params);
    return response;
  }

  @override
  Future<Response> deleteProject(DeleteProjectParams params) async {
    var response = await _projectApi.deleteProjects(params);
    return response;
  }

  @override
  Future<Response> updateFavoriteProject(
      UpdateFavoriteProjectParams params) async {
    var response = await _projectApi.updateFavoriteProjects(params);
    return response;
  }

  @override
  Future saveStudentFavProject(ProjectList projectList) async {
    await _sharedPrefHelper.saveFavoriteProjects(projectList);
  }

  @override
  Future<Response> postProposal(PostProposalParams params) async {
    var response = await _projectApi.postProposal(params);
    return response;
  }

  @override
  Future<Response> updateProposal(UpdateProposalParams params) async {
    var response = await _projectApi.updateProposal(params);
    return response;
  }
}
