import 'package:dio/dio.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class deleteProjectParams {
  String Id;

  deleteProjectParams({required this.Id});
}

class deleteProjectUseCase implements UseCase<Response, deleteProjectParams> {
  final ProjectRepository _projectRepository;

  deleteProjectUseCase(this._projectRepository);

  @override
  Future<Response> call({required deleteProjectParams params}) async {
    return _projectRepository.deleteProject(params);
  }
}
