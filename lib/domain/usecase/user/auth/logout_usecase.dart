import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class LogoutUseCase extends UseCase<void, bool> {
  final UserRepository _userRepository;

  LogoutUseCase(this._userRepository);
  
  @override
  Future<void> call({required bool params}) async {
    if (params) {
      _userRepository.logout();
    }
  }
}
