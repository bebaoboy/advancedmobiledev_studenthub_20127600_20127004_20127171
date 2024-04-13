// ignore_for_file: camel_case_types

import 'package:dio/dio.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class updateFavoriteProjectParams {
  String projectId;
  bool disableFlag;
  String studentId;

  updateFavoriteProjectParams(
      {required this.projectId,
      required this.disableFlag,
      required this.studentId});
}

class updateFavoriteProjectUseCase
    implements UseCase<Response, updateFavoriteProjectParams> {
  final ProjectRepository _projectRepository;

  updateFavoriteProjectUseCase(this._projectRepository);

  @override
  Future<Response> call({required updateFavoriteProjectParams params}) async {
    return _projectRepository.updateFavoriteProject(params);
  }
}
