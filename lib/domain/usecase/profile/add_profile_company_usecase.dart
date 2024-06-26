import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class AddProfileCompanyParams {
  String companyName;
  String website;
  String description;
  int size = CompanyScope.solo.index;
  int id;

  AddProfileCompanyParams(
      {required this.companyName,
      required this.website,
      required this.description,
      required this.size,
      required this.id});
}

class AddProfileCompanyUseCase
    implements UseCase<Response, AddProfileCompanyParams> {
  final UserRepository _userRepository;

  AddProfileCompanyUseCase(this._userRepository);

  @override
  Future<Response> call({required AddProfileCompanyParams params}) async {
    return _userRepository.addProfileCompany(params);
  }
}
