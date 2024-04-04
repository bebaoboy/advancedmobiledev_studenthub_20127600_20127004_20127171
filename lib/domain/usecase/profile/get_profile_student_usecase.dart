import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/update_profile_student_usecase.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class GetProfileStudentUseCase
    implements UseCase<Response, UpdateProfileStudentParams> {
  final UserRepository _userRepository;

  GetProfileStudentUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateProfileStudentParams params}) async {
    return _userRepository.getProfileStudent(params);
  }
}
