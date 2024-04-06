import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class GetUserDataUseCase extends UseCase<User, void> {
  final UserRepository _userRepository;

  GetUserDataUseCase(this._userRepository);

  @override
  Future<User> call({required void params}) async {
    return await _userRepository.user;
  }
}
