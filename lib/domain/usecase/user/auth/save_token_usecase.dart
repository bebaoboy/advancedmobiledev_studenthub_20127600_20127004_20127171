import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class SaveTokenUseCase implements UseCase<bool, String> {
  final UserRepository _userRepository;

  SaveTokenUseCase(this._userRepository);

  @override
  FutureOr<bool> call({required String params}) async {
    return await _userRepository.saveToken(params);
  }
}
