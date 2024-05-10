import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class UpdateProfileStudentParams {
  /// Nullable, if not choosen -> null
  int? techStack;
  List<int> skillSet;
  String id;

  /// techstack can be null if not choosen -> null
  UpdateProfileStudentParams({
    required this.techStack,
    required this.skillSet,
    required this.id,
  });
}

class UpdateProfileStudentUseCase
    implements UseCase<Response, UpdateProfileStudentParams> {
  final UserRepository _userRepository;

  UpdateProfileStudentUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateProfileStudentParams params}) async {
    return _userRepository.updateProfileStudent(params);
  }
}
