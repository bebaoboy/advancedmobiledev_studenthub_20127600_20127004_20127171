import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';
import 'package:dio/dio.dart';

class PostProposalParams {
  int status;
  int disableFlag;
  String coverLetter;
  int projectId;
  int studentId;

  PostProposalParams(this.status, this.disableFlag, this.coverLetter,
      this.projectId, this.studentId);
}

class PostProposalUseCase extends UseCase<Response, PostProposalParams> {
  final ProjectRepository _projectRepository;
  PostProposalUseCase(this._projectRepository);

  @override
  Future<Response> call({required PostProposalParams params}) async {
    return await _projectRepository.postProposal(params);
  }
}
