import 'dart:async';
import 'dart:io';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/education_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/update_education.dart';

class GetEducationUseCase extends UseCase<EducationList, String> {
  UserRepository _userRepository;
  GetEducationUseCase(this._userRepository);
  @override
  Future<EducationList> call({required String params}) async {
    if (params.isEmpty) return EducationList();
    if (await _userRepository.isLoggedIn) {
      UpdateEducationParams p =
          UpdateEducationParams(educations: List.empty(), studentId: params);
      var response = await _userRepository.getEducation(p);
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.ok) {
        return EducationList.fromJson(response.data["result"]);
      } else {
        return EducationList();
      }
    }
    return EducationList();
  }
}
