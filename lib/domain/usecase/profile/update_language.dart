import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class UpdateLanguageParams {
  List<Language> languages;
  String studentId;

  UpdateLanguageParams({
    required this.languages,
    required this.studentId,
  });
}

class UpdateLanguageUseCase implements UseCase<Response, UpdateLanguageParams> {
  final UserRepository _userRepository;

  UpdateLanguageUseCase(this._userRepository);

  @override
  Future<Response> call({required UpdateLanguageParams params}) async {
    return _userRepository.updateLanguage(params);
  }
}
