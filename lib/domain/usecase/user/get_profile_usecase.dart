import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class FetchProfileResult {
  bool status;
  List<Profile?> result;
  List<UserType>? roles;

  FetchProfileResult(this.status, this.result, this.roles);
}

class GetProfileUseCase extends UseCase<FetchProfileResult, bool> {
  final UserRepository _userRepository;

  GetProfileUseCase(this._userRepository);

  @override
  Future<FetchProfileResult> call({required bool params}) {
    if (params) {
      return _userRepository.getProfileAndSave();
    }
    return Future.value(FetchProfileResult(false, [null, null].toList(), []));
  }
}
