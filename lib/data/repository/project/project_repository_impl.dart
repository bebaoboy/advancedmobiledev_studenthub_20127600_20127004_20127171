import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/network/apis/project/project_api.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class ProjectRepositoryImpl extends ProjectRepository {
  ProjectRepositoryImpl(
      ProjectApi projectApi, ProjectDataSource projectDataSource);

  @override
  Future<ProjectList> fetchPagingProject() {
    return Future.value(ProjectList(List.empty(growable: true)));
  }
}
