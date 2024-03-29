import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';
import '../../../entity/user/user.dart';
import '../../../repository/user/user_repository.dart';

class SignUpUseCase implements UseCase<Response, LoginParams> {
  final UserRepository _userRepository;

  SignUpUseCase(this._userRepository);

  @override
  Future<Response> call({required LoginParams params}) async {
    return _userRepository.signUp();
  }
}