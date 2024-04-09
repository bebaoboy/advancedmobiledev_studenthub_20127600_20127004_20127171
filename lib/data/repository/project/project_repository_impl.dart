import 'dart:io';

import 'package:boilerplate/core/widgets/xmpp/logger/Log.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/network/apis/project/project_api.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class ProjectRepositoryImpl extends ProjectRepository {
  final ProjectApi _projectApi;
  final ProjectDataSource _datasource;
  ProjectRepositoryImpl(this._projectApi, this._datasource);

  @override
  Future<ProjectList> fetchPagingProjects() async {
    return await _projectApi.getProjects().then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        var result = ProjectList.fromJson(value.data["result"]);
        result.projects?.forEach((project) {
          _datasource.insert(project);
        });
        return result;
      } else {
        return ProjectList(projects: List.empty(growable: true));
      }
      // ignore: invalid_return_type_for_catch_error
    }).onError((s, error) {
      Log.e("ProjectRepo", error.toString());
      return Future.value(ProjectList(projects: List.empty(growable: true)));
    });
  }
}
