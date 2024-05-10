import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

class HasToChangePassParams {
  String oldPass;
  bool res;

  HasToChangePassParams(this.oldPass, this.res);
}

class GetMustChangePassUseCase extends UseCase<HasToChangePassParams, void> {
  final UserRepository _userRepository;

  GetMustChangePassUseCase(this._userRepository);

  @override
  Future<HasToChangePassParams> call({required void params}) async {
    return await _userRepository.getRequired();
  }
}
