import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class UpdateProfileCompanyUseCase
    implements UseCase<Response, AddProfileCompanyParams> {
  final UserRepository _userRepository;

  UpdateProfileCompanyUseCase(this._userRepository);

  @override
  Future<Response> call({required AddProfileCompanyParams params}) async {
    return _userRepository.updateProfileCompany(params);
  }
}
