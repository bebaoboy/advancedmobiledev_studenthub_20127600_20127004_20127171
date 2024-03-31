import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class SetUserProfileUseCase extends UseCase<List<Profile?>, void> {
  final UserRepository _userRepository;
  SetUserProfileUseCase(this._userRepository);

  @override
  Future<List<Profile?>> call({required void params}) {
    return _userRepository.fetchProfileFromSharedPref();
  }
}
