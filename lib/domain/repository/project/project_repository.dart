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
  Future<Response> createProject(CreateProjectParams params);

  Future<Response> deleteProject(DeleteProjectParams params);

  Future<Response> updateFavoriteProject(UpdateFavoriteProjectParams params);

  Future<ProjectList> fetchPagingProjects(GetProjectParams params);

  Future<Response> getProjectByCompany(GetProjectByCompanyParams params);

  Future<Response> getStudentProposalProjects(
      GetStudentProposalProjectsParams params);

  Future<ProjectList> getStudentFavoriteProjects();

  Future<Response> updateCompanyProject(UpdateProjectParams params);

  Future saveStudentFavProject(ProjectList params);
}
