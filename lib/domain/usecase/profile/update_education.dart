import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class UpdateEducationParams {
  List<Education> educations;
    String studentId;

  UpdateEducationParams({
    required this.educations,
    required this.studentId,
  });
}

class UpdateEducationUseCase implements UseCase<Response, UpdateEducationParams> {
  final UserRepository _userRepository;

  UpdateEducationUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateEducationParams params}) async {
    return _userRepository.updateEducation(params);
  }
}
