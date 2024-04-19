import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:flutter/material.dart';

class ViewStudentProfile extends StatefulWidget {
  final StudentProfile studentProfile;
  const ViewStudentProfile({super.key, required this.studentProfile});

  @override
  State<ViewStudentProfile> createState() => _ViewStudentProfileState();
}

class _ViewStudentProfileState extends State<ViewStudentProfile> {
  @override
  Widget build(BuildContext context) {
    var skills = widget.studentProfile.skillSet ??
        <Skill>[
          Skill('superlongtbjbjbjbhjbhbhjbhjbjbjbj', 'something', '0'),
          Skill('hello2fffffff', 'something', '0'),
          Skill('hello2', 'something', '0'),
          Skill('hello2', 'something', '0'),
          Skill('hello2', 'something', '0'),
          Skill('hello2', 'something', '0'),
          Skill('hello2', 'something', '0'),
        ];
    return Scaffold(
      appBar: const EmptyAppBar(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 10),
                    child: Hero(
                      tag: "studentImage${widget.studentProfile.objectId}",
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: const FlutterLogo(
                          size: 200,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.studentProfile.title,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          "Fullname: ${widget.studentProfile.fullName}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "Year of experience: ${widget.studentProfile.yearOfExperience}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const Divider(
                          color: Colors.black38,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          widget.studentProfile.introduction,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Divider(
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 24.0, bottom: 10),
                    child: Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GridView.builder(
                        itemCount: skills.length,
                        itemBuilder: (context, index) {
                          return Chip(
                            clipBehavior: Clip.hardEdge,
                            side: const BorderSide(color: Colors.black),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(
                              textAlign: TextAlign.justify,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              skills[index].name,
                            ),
                          );
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          mainAxisSpacing: 3,
                          crossAxisSpacing: 5,
                        ),
                      ),
                    ),
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
