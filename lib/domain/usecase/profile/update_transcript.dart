import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class UpdateTranscriptParams {
  String transcript;
  String studentId;

  UpdateTranscriptParams({
    required this.transcript,
    required this.studentId,
  });
}

class UpdateTranscriptUseCase
    implements UseCase<Response, UpdateTranscriptParams> {
  final UserRepository _userRepository;

  UpdateTranscriptUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateTranscriptParams params}) async {
    return _userRepository.updateTranscript(params);
  }
}
