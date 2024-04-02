import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class ChangePassParams {
  String oldPass;
  bool res;

  ChangePassParams(this.oldPass, this.res);
}

class HasToChangePassUseCase extends UseCase<void, ChangePassParams> {
  final UserRepository _userRepository;

  HasToChangePassUseCase(this._userRepository);

  @override
  Future call({required ChangePassParams params}) async {
    _userRepository.saveHasToChangePass(params.oldPass, params.res);
  }
}
