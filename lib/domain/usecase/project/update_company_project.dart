import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';
import 'package:dio/dio.dart';

class UpdateProjectParams {
  int projectId;
  String title;
  String description;
  int numberOfStudent;
  int projectScope;

  UpdateProjectParams(this.projectId, this.title, this.description,
      this.numberOfStudent, this.projectScope);
}

class UpdateCompanyProject extends UseCase<Response, UpdateProjectParams> {
  final ProjectRepository _projectRepository;

  UpdateCompanyProject(this._projectRepository);
  @override
  Future<Response> call({required UpdateProjectParams params}) async {
    return _projectRepository.updateCompanyProject(params);
  }
}
