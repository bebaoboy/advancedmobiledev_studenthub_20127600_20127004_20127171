import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class AddProfileStudentParams {
  String companyName;
  String website;
  String description;
  int size = CompanyScope.solo.index;

  AddProfileStudentParams(
      {required this.companyName,
      required this.website,
      required this.description,
      required this.size});
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
