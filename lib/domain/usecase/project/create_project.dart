import 'package:dio/dio.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class createProjectParams {
  String companyId;
  String title;
  String description;
  int numberOfStudents;
  int projectScopeFlag;
  bool typeFlag;

  createProjectParams(
      {required this.companyId,
      required this.title,
      required this.description,
      required this.numberOfStudents,
      required this.projectScopeFlag,
      required this.typeFlag});
}

class createProjectUseCase implements UseCase<Response, createProjectParams> {
  final ProjectRepository _projectRepository;

  createProjectUseCase(this._projectRepository);

  @override
  Future<Response> call({required createProjectParams params}) async {
    return _projectRepository.createProject(params);
  }
}
