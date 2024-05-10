import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

class ChangePasswordParams {
  String oldPassword;
  String newPassword;

  ChangePasswordParams(this.oldPassword, this.newPassword);
}

class ChangePasswordUseCase extends UseCase<Response, ChangePasswordParams> {
  final UserRepository _userRepository;

  ChangePasswordUseCase(this._userRepository);

  @override
  Future<Response> call({required ChangePasswordParams params}) async {
    return await _userRepository.changePassword(params);
  }
}
