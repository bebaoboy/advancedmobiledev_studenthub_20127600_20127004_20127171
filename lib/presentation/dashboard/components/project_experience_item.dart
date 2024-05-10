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
  // Widget _buildChip(List<Skill>? skills) {
  //   skills ??= <Skill>[
  //     Skill('hello1', 'something', '0'),
  //     Skill('hello2', 'something', '0'),
  //     Skill('hello2', 'something', '0'),
  //     Skill('hello2', 'something', '0'),
  //     Skill('hello2', 'something', '0'),
  //     Skill('hello2', 'something', '0'),
  //     Skill('hello2', 'something', '0'),
  //   ];

  //   return SizedBox(
  //     height: MediaQuery.of(context).size.height * 0.05,
  //     child: Scrollbar(
  //       child: ListView.builder(
  //         physics: const ClampingScrollPhysics(),
  //         scrollDirection: Axis.horizontal,
  //         itemCount: skills.length,
  //         itemBuilder: (context, index) {
  //           return Row(
  //             children: [
  //               Container(
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
  //                 decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     border: Border.all(color: Colors.transparent),
  //                     borderRadius: BorderRadius.circular(8)),
  //                 child: Text(
  //                   skills![index].name,
  //                   style: const TextStyle(
  //                       color: Colors.red,
  //                       fontWeight: FontWeight.w900,
  //                       fontSize: 14),
  //                 ),
  //               ),
  //               const SizedBox(
  //                 width: 8,
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.horizontal_padding,
          vertical: Dimens.vertical_padding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            border: Border.all(width: 0.4, color: Colors.black87),
            borderRadius: BorderRadius.circular(10)),
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
                    size: 30,
                  ),
                  Text(
                    widget.projectExperience.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.projectExperience.description,
                style: const TextStyle(fontSize: 20),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.link,
                    size: 26,
                  ),
                  Text(
                    widget.projectExperience.link,
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
