import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class DeleteProfileUseCase extends UseCase<void, bool> {
  final UserRepository _userRepository;

  DeleteProfileUseCase(this._userRepository);

  @override
  FutureOr<void> call({required bool params}) {
    if (params) {
      _userRepository.deleteProfile();
    }
  }
}
