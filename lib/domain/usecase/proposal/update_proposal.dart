import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';
import 'package:dio/dio.dart';

class UpdateProposalParams {
  int status;
  int disableFlag;
  String coverLetter;
  int proposalId;

  UpdateProposalParams(this.status, this.disableFlag, this.coverLetter,
      this.proposalId);
}

class UpdateProposalUseCase extends UseCase<Response, UpdateProposalParams> {
  final ProjectRepository _projectRepository;
  UpdateProposalUseCase(this._projectRepository);

  @override
  Future<Response> call({required UpdateProposalParams params}) async {
    return await _projectRepository.updateProposal(params);
  }
}
