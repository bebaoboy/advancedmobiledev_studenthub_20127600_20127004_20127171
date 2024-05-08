import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/presentation/dashboard/components/project_experience_item.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class ViewStudentProfile2 extends StatefulWidget {
  final StudentProfile studentProfile;
  const ViewStudentProfile2({super.key, required this.studentProfile});

  @override
  State<ViewStudentProfile2> createState() => _ViewStudentProfile2State();
}

class _ViewStudentProfile2State extends State<ViewStudentProfile2> {
  bool checkIfValid() {
    return (widget.studentProfile.resume != null &&
            widget.studentProfile.resume != '') ||
        (widget.studentProfile.transcript != null &&
            widget.studentProfile.transcript != '');
  }

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
            if (widget.studentProfile.projectExperience == null ||
                widget.studentProfile.projectExperience!.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Student does not add any projects"),
              ))
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          widget.studentProfile.projectExperience?.length ?? 0,
                      itemBuilder: (context, index) => ProjectExperienceItem(
                          projectExperience:
                              widget.studentProfile.projectExperience![index])),
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text("Education", style: TextStyle(fontSize: 26))),
            if (widget.studentProfile.educations == null ||
                widget.studentProfile.educations!.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text("Student does not add any educations"),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.studentProfile.educations?.length ?? 0,
                      itemBuilder: (context, index) {
                        return AspectRatio(
                          aspectRatio: 1,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.studentProfile.educations![index]
                                      .schoolName
                                      .toTitleCase()),
                                  Text(
                                      "${widget.studentProfile.educations![index].startYear.year} - ${widget.studentProfile.educations![index].endYear.year}")
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 10, right: 30, bottom: 20, left: 30),
                  alignment: Alignment.bottomLeft,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Back"),
                  ),
                ),
                Visibility(
                  visible: checkIfValid(),
                  child: Container(
                    padding:
                        const EdgeInsets.only(top: 10, right: 30, bottom: 20),
                    alignment: Alignment.bottomRight,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface)),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute2(
                            routeName: Routes.companyViewStudentProfile3,
                            arguments: widget.studentProfile));
                      },
                      child: const Text("View More"),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
