import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class GetSkillsetUseCase implements UseCase<Response, AddSkillsetParams> {
  final UserRepository _userRepository;

  GetSkillsetUseCase(this._userRepository);

  @override
  Future<Response> call({required AddSkillsetParams params}) async {
    return _userRepository.getSkillset(params);
  }
}
