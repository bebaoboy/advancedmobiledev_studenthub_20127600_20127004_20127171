// ignore_for_file: camel_case_types

import 'package:dio/dio.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class UpdateFavoriteProjectParams {
  String projectId;
  bool disableFlag;
  String studentId;

  UpdateFavoriteProjectParams(
      {required this.projectId,
      required this.disableFlag,
      required this.studentId});
}

class UpdateFavoriteProjectUseCase
    implements UseCase<Response, UpdateFavoriteProjectParams> {
  final ProjectRepository _projectRepository;

  UpdateFavoriteProjectUseCase(this._projectRepository);

  @override
  Future<Response> call({required UpdateFavoriteProjectParams params}) async {
    return _projectRepository.updateFavoriteProject(params);
  }
}
