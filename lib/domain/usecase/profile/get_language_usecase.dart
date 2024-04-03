import 'dart:async';
import 'dart:io';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/language_list.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/update_language.dart';

class GetLanguageUseCase extends UseCase<LanguageList, String> {
  UserRepository _userRepository;
  GetLanguageUseCase(this._userRepository);

  @override
  Future<LanguageList> call({required String params}) async {
    if (params.isEmpty) return LanguageList();
    if (await _userRepository.isLoggedIn) {
      UpdateLanguageParams p =
          UpdateLanguageParams(languages: List.empty(), studentId: params);
      var response = await _userRepository.getLanguage(p);
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.ok) {
        return LanguageList.fromJson(response.data["result"]);
      } else {
        return LanguageList();
      }
    }
    return LanguageList();
  }
}
