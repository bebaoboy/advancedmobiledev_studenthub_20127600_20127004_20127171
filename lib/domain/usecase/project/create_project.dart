// ignore_for_file: camel_case_types

import 'package:dio/dio.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class CreateProjectParams {
  String companyId;
  String title;
  String description;
  int numberOfStudents;
  int projectScopeFlag;
  bool typeFlag;

  CreateProjectParams(
      {required this.companyId,
      required this.title,
      required this.description,
      required this.numberOfStudents,
      required this.projectScopeFlag,
      required this.typeFlag});
}

class CreateProjectUseCase implements UseCase<Response, CreateProjectParams> {
  final ProjectRepository _projectRepository;

  CreateProjectUseCase(this._projectRepository);

  @override
  Future<Response> call({required CreateProjectParams params}) async {
    return _projectRepository.createProject(params);
  }
}
