import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class ProposalCardItem extends StatefulWidget {
  final Proposal proposal;
  const ProposalCardItem({super.key, required this.proposal});

  @override
  State<ProposalCardItem> createState() => _ProposalCardItemState();
}

class _ProposalCardItemState extends State<ProposalCardItem> {
  Widget _buildChip(List<Skill>? skills) {
    skills ??= <Skill>[
      Skill('hello1', 'something', '0'),
      Skill('hello2', 'something', '0'),
      Skill('hello2', 'something', '0'),
      Skill('hello2', 'something', '0'),
      Skill('hello2', 'something', '0'),
      Skill('hello2', 'something', '0'),
      Skill('hello2', 'something', '0'),
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
                Chip(
                  side: const BorderSide(color: Colors.transparent),
                  label: Text(
                    skills![index].name,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(
                  width: 4.0,
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

    return SizedBox(
      height: 410,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
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
                profile.fullName,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
                textAlign: TextAlign.left,
              ),
              Text(
                profile.education,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
              ),
              _buildChip(profile.skillSet),
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
    );
  }
}
