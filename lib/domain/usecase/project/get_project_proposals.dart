import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';

class GetProjectProposals extends UseCase<ProposalList, Project> {
  final ProjectRepository _projectRepository;
  GetProjectProposals(this._projectRepository);

  @override
  Future<ProposalList> call({required Project params}) async {
    return _projectRepository.getProjectProposals(params);
  }
}
