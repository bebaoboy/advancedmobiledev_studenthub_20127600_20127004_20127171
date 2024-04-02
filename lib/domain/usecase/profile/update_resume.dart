import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class UpdateResumeParams {
  String path;
  String studentId;

  UpdateResumeParams({
    required this.studentId,
    this.path = "",
  });
}

class UpdateResumeUseCase implements UseCase<Response, UpdateResumeParams> {
  final UserRepository _userRepository;

  UpdateResumeUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateResumeParams params}) async {
    return _userRepository.updateResume(params);
  }
}
