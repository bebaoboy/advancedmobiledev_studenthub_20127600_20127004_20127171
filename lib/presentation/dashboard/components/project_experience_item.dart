import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:flutter/material.dart';

class ProjectExperienceItem extends StatefulWidget {
  final ProjectExperience projectExperience;
  const ProjectExperienceItem({super.key, required this.projectExperience});

  @override
  State<ProjectExperienceItem> createState() => _ProjectExperienceItemState();
}

class _ProjectExperienceItemState extends State<ProjectExperienceItem> {
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
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.horizontal_padding - 3,
          vertical: Dimens.vertical_padding),
      child: Container(
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 0.4, color: Colors.black87))),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.title,
                    size: 45,
                  ),
                  Text(
                    widget.projectExperience.name,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.description,
                    size: 45,
                  ),
                  Text(
                    widget.projectExperience.description,
                    style: const TextStyle(fontSize: 20),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Skills"),
                  _buildChip(widget.projectExperience.skills),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.link,
                    size: 45,
                  ),
                  Text(
                    widget.projectExperience.link ?? 'No link attached',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
