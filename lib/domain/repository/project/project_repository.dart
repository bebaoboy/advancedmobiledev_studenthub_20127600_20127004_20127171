import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/usecase/project/update_favorite.dart';
import 'package:boilerplate/domain/usecase/project/create_project.dart';
import 'package:boilerplate/domain/usecase/project/delete_project.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
import 'package:boilerplate/domain/usecase/project/get_projects.dart';
import 'package:boilerplate/domain/usecase/project/get_student_proposal_projects.dart';
import 'package:boilerplate/domain/usecase/project/update_company_project.dart';
import 'package:dio/dio.dart';

abstract class ProjectRepository {
  Future<Response> createProject(createProjectParams params);

  Future<Response> deleteProject(deleteProjectParams params);

  Future<Response> updateFavoriteProject(updateFavoriteProjectParams params);

  Future<ProjectList> fetchPagingProjects(GetProjectParams params);

  Future<Response> getProjectByCompany(GetProjectByCompanyParams params);

  Future<Response> getStudentProposalProjects(
      GetStudentProposalProjectsParams params);

  Future<Response> getStudentFavoriteProjects(
      GetStudentProposalProjectsParams params);

  Future<Response> updateCompanyProject(UpdateProjectParams params);
}
