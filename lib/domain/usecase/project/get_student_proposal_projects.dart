import 'package:boilerplate/domain/repository/project/project_repository.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/usecase/use_case.dart';

class GetStudentProposalProjectsParams {
  String studentId;
  int? statusFlag;

  GetStudentProposalProjectsParams({
    required this.studentId,
    this.statusFlag,
  });
}

class GetStudentProposalProjectsUseCase
    implements UseCase<Response, GetStudentProposalProjectsParams> {
  final ProjectRepository _projectRepository;

  GetStudentProposalProjectsUseCase(this._projectRepository);

  @override
  Future<Response> call({required GetStudentProposalProjectsParams params}) async {
    return _projectRepository.getStudentProposalProjects(params);
  }
}
