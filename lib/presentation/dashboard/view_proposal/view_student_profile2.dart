import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/presentation/dashboard/components/project_experience_item.dart';
import 'package:flutter/material.dart';

class ViewStudentProfile2 extends StatefulWidget {
  final StudentProfile studentProfile;
  const ViewStudentProfile2({super.key, required this.studentProfile});

  @override
  State<ViewStudentProfile2> createState() => _ViewStudentProfile2State();
}

class _ViewStudentProfile2State extends State<ViewStudentProfile2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.topLeft,
                child: const Text("Project", style: TextStyle(fontSize: 26))),
            SizedBox(
              height: 250,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      widget.studentProfile.projectExperience?.length ?? 0,
                  itemBuilder: (context, index) => ProjectExperienceItem(
                      projectExperience:
                          widget.studentProfile.projectExperience![index])),
            ),
            const SizedBox(
              height: 20,
            ),
            Visibility(
                visible: widget.studentProfile.educations != null &&
                    widget.studentProfile.educations!.isNotEmpty,
                child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(20),
                    child: const Text("Education",
                        style: TextStyle(fontSize: 26)))),
            SizedBox(
              height: 250,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.studentProfile.educations?.length ?? 0,
                  itemBuilder: (context, index) {
                    return AspectRatio(
                      aspectRatio: 1,
                      child: Card(
                          child: Column(
                        children: [
                          Text(widget
                              .studentProfile.educations![index].schoolName),
                          Text(
                              "${widget.studentProfile.educations![index].startYear} - ${widget.studentProfile.educations![index].endYear}")
                        ],
                      )),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
