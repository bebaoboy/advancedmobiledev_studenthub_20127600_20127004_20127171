// ignore_for_file: camel_case_types

import 'package:dio/dio.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class DeleteProjectParams {
  String Id;

  DeleteProjectParams({required this.Id});
}

class DeleteProjectUseCase implements UseCase<Response, DeleteProjectParams> {
  final ProjectRepository _projectRepository;

  DeleteProjectUseCase(this._projectRepository);

  @override
  Future<Response> call({required DeleteProjectParams params}) async {
    return _projectRepository.deleteProject(params);
  }
}
