import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class GetCompanyUseCase
    implements UseCase<Response, AddProfileCompanyParams> {
  final UserRepository _userRepository;

  GetCompanyUseCase(this._userRepository);

  @override
  Future<Response> call({required AddProfileCompanyParams params}) async {
    return _userRepository.getCompanyProfile(params);
  }
}
