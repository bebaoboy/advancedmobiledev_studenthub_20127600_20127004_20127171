import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class UpdateProjectExperienceParams {
  List<ProjectExperience> projectExperiences;
  String studentId;

  UpdateProjectExperienceParams({
    required this.projectExperiences,
    required this.studentId,
  });
}

class UpdateProjectExperienceUseCase
    implements UseCase<Response, UpdateProjectExperienceParams> {
  final UserRepository _userRepository;

  UpdateProjectExperienceUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateProjectExperienceParams params}) async {
    return _userRepository.updateProjectExperience(params);
  }
}
