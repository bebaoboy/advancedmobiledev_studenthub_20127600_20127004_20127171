import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class GetStudentFavoriteProjectUseCase extends UseCase<ProjectList, void> {
  final ProjectRepository _projectRepository;
  GetStudentFavoriteProjectUseCase(this._projectRepository);
 
  @override
  Future<ProjectList> call({required void params}) async {
    return await _projectRepository.getStudentFavoriteProjects();
  }
}
