
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';
import '../../../entity/user/user.dart';
import '../../../repository/user/user_repository.dart';

class SignUpParams {
  final String? fullname;
  final String? email;
  final String? password;
  final UserType? type;

  SignUpParams(
      {required this.fullname,
      required this.email,
      required this.password,
      required this.type});
}

class SignUpUseCase implements UseCase<Response, SignUpParams> {
  final UserRepository _userRepository;

  SignUpUseCase(this._userRepository);

  @override
  Future<Response> call({required SignUpParams params}) async {
    return _userRepository.signUp(params);
  }
}
