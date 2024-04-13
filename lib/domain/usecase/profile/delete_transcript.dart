import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/update_transcript.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class DeleteTranscriptUseCase
    implements UseCase<Response, UpdateTranscriptParams> {
  final UserRepository _userRepository;

  DeleteTranscriptUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateTranscriptParams params}) async {
    return _userRepository.deleteTranscript(params);
  }
}
