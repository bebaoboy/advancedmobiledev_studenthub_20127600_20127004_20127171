import 'dart:async';
import 'dart:io';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/experience_list.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/update_project_experience.dart';

class GetExperienceUseCase extends UseCase<ProjectExperienceList, String> {
  final UserRepository _userRepository;
  GetExperienceUseCase(this._userRepository);

  @override
  Future<ProjectExperienceList> call({required String params}) async {
    if (params.isEmpty) return ProjectExperienceList();
    if (await _userRepository.isLoggedIn) {
      UpdateProjectExperienceParams p = UpdateProjectExperienceParams(
          studentId: params, projectExperiences: []);
      var response = await _userRepository.getProjectExperience(p);
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.ok) {
        return ProjectExperienceList.fromJson(response.data["result"]);
      } else {
        return ProjectExperienceList();
      }
    }
    return ProjectExperienceList();
  }
}
