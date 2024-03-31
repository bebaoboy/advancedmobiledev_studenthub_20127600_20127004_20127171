import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class AddProfileStudentParams {
  /// Nullable, if not choosen -> null
  int? techStack;
  List<int> skillSet;

  /// techstack can be null if not choosen -> null
  AddProfileStudentParams({
    required this.techStack,
    required this.skillSet,
  });
}

class AddProfileStudentUseCase
    implements UseCase<Response, AddProfileStudentParams> {
  final UserRepository _userRepository;

  AddProfileStudentUseCase(this._userRepository);

  @override
  Future<Response> call({required AddProfileStudentParams params}) async {
    return _userRepository.addProfileStudent(params);
  }
}
