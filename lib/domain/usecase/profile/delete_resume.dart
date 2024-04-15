import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/update_resume.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class DeleteResumeUseCase implements UseCase<Response, UpdateResumeParams> {
  final UserRepository _userRepository;

  DeleteResumeUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateResumeParams params}) async {
    return _userRepository.deleteResume(params);
  }
}
