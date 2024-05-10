import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

class SendResetPasswordMailUseCase extends UseCase<Response, String> {
  final UserRepository _userRepository;

  SendResetPasswordMailUseCase(this._userRepository);

  @override
  Future<Response> call({required String params}) {
    return _userRepository.sendResetPasswordMail(params);
  }
}
