import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class AddTechStackParams {
  String name;

  AddTechStackParams({
    required this.name,
  });
}

class AddTechStackUseCase implements UseCase<Response, AddTechStackParams> {
  final UserRepository _userRepository;

  AddTechStackUseCase(this._userRepository);

  @override
  Future<Response> call({required AddTechStackParams params}) async {
    return _userRepository.addTechStack(params);
  }
}
