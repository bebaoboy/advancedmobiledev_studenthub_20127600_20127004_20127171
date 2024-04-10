import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class GetProjectParams {
  String? title;
  int? projectScopeFlag;
  int? numberOfStudents;
  int? proposalsLessThan;

  GetProjectParams(
      {this.title,
      this.projectScopeFlag,
      this.numberOfStudents,
      this.proposalsLessThan});
}

class GetProjectsUseCase extends UseCase<ProjectList, GetProjectParams> {
  final ProjectRepository _projectRepository;
  GetProjectsUseCase(this._projectRepository);

  @override
  Future<ProjectList> call({required GetProjectParams params}) {
    return _projectRepository.fetchPagingProjects(params);
  }
}
