import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/usecase/project/update_favorite.dart';
import 'package:boilerplate/domain/usecase/project/create_project.dart';
import 'package:boilerplate/domain/usecase/project/delete_project.dart';
import 'package:dio/dio.dart';

abstract class ProjectRepository {
  Future<ProjectList> fetchPagingProjects();

  Future<Response> createProject(createProjectParams params);

  Future<Response> deleteProject(deleteProjectParams params);

  Future<Response> updateFavoriteProject(updateFavoriteProjectParams params);
}
