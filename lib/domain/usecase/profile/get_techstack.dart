import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class GetTechStackUseCase implements UseCase<Response, AddTechStackParams> {
  final UserRepository _userRepository;

  GetTechStackUseCase(this._userRepository);

  @override
  Future<Response> call({required AddTechStackParams params}) async {
    return _userRepository.getTechStack(params);
  }
}
