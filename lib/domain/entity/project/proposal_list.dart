import 'package:boilerplate/domain/entity/project/project_entities.dart';

class ProposalList {
  List<Proposal>? proposals;

  ProposalList({required this.proposals});

  factory ProposalList.fromJson(List<dynamic> json) {
    List<Proposal>? proposals = <Proposal>[];
    proposals = json.map((post) => Proposal.fromJson(post)).toList();

    return ProposalList(
      proposals: proposals,
    );
  }
}
