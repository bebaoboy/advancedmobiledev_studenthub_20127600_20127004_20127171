import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class SaveStudentFavoriteProjectUseCase extends UseCase<void, ProjectList> {
  final ProjectRepository _projectRepository;

  SaveStudentFavoriteProjectUseCase(this._projectRepository);
  @override
  Future<void> call({required ProjectList params}) async {
    await _projectRepository.saveStudentFavProject(params);
  }
}
