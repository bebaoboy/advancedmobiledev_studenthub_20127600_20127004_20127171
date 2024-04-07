import 'package:boilerplate/domain/entity/project/project_list.dart';

abstract class ProjectRepository {
  Future<ProjectList> fetchPagingProjects();
}