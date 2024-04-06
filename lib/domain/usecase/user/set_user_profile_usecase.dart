import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/user/get_profile_usecase.dart';

class SetUserProfileUseCase extends UseCase<List<Profile?>, void> {
  final UserRepository _userRepository;
  SetUserProfileUseCase(this._userRepository);

  @override
  Future<List<Profile?>> call({required void params}) async {
    FetchProfileResult res = await _userRepository.getProfileAndSave();
    if (res.status) {
      return [
        res.result[0] != null ? res.result[0] as StudentProfile : null,
        res.result[1] != null ? res.result[1] as CompanyProfile : null,
      ];
    }
    return [];
  }
}
