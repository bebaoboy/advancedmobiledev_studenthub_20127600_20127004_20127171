import 'package:boilerplate/domain/repository/project/project_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class GetProjectByCompanyParams {
  String companyId;
  int? typeFlag;

  GetProjectByCompanyParams({
    required this.companyId,
    this.typeFlag,
  });
}

class GetProjectByCompanyUseCase
    implements UseCase<Response, GetProjectByCompanyParams> {
  final ProjectRepository _projectRepository;

  GetProjectByCompanyUseCase(this._projectRepository);

  @override
  Future<Response> call({required GetProjectByCompanyParams params}) async {
    return _projectRepository.getProjectByCompany(params);
  }
}
