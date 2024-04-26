import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProposalCardItem extends StatefulWidget {
  final Proposal proposal;
  const ProposalCardItem({super.key, required this.proposal});

  @override
  State<ProposalCardItem> createState() => _ProposalCardItemState();
}

class _ProposalCardItemState extends State<ProposalCardItem> {
  Widget _buildChip(List<Skill>? skills) {
    skills ??= <Skill>[
      Skill('Demo skill 1', 'something', '0'),
      Skill('Demo skill 2', 'something', '0'),
      Skill('Demo skill 3', 'something', '0'),
      Skill('Demo skill 4', 'something', '0'),
      Skill('Demo skill 5', 'something', '0'),
      Skill('Demo skill 6', 'something', '0'),
      Skill('Demo skill 7', 'something', '0'),
    ];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      child: Scrollbar(
        child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: skills.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    skills![index].name,
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w900,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.proposal.student;

    return Stack(children: [
      SizedBox(
        height: 470,
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          color: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Text(
                  ("${profile.fullName} - ${widget.proposal.objectId}")
                      .toTitleCase(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                Text(
                  widget.proposal.coverLetter,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 10),
                  textAlign: TextAlign.left,
                ),
                Text(
                  profile.education,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                ),
                _buildChip(profile.skillSet != null && profile.skillSet!.isEmpty
                    ? null
                    : profile.skillSet),
                const SizedBox(
                  height: 24,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute2(
                        routeName: Routes.companyViewStudentProfile,
                        arguments: widget.proposal.student));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Student profile",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 110, top: 10),
        child: Hero(
          tag: "studentImage${widget.proposal.student.objectId}",
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 220,
            ),
          ),
        ),
      ),
    ]);
  }
}
