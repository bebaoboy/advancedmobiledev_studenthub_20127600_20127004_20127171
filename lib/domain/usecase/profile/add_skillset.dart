import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class AddSkillsetParams {
  String name;

  AddSkillsetParams({
    required this.name,
  });
}

class AddSkillsetUseCase implements UseCase<Response, AddSkillsetParams> {
  final UserRepository _userRepository;

  AddSkillsetUseCase(this._userRepository);

  @override
  Future<Response> call({required AddSkillsetParams params}) async {
    return _userRepository.addSkillset(params);
  }
}
