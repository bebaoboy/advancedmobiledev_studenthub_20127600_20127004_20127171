import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class ViewStudentProfile extends StatefulWidget {
  final StudentProfile studentProfile;
  const ViewStudentProfile({super.key, required this.studentProfile});

  @override
  State<ViewStudentProfile> createState() => _ViewStudentProfileState();
}

class _ViewStudentProfileState extends State<ViewStudentProfile> {
  bool checkIfValid() {
    return (widget.studentProfile.projectExperience != null &&
            widget.studentProfile.projectExperience!.isNotEmpty) ||
        (widget.studentProfile.educations != null &&
            widget.studentProfile.educations!.isNotEmpty);
  }

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
      body: SingleChildScrollView(
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
                    "Fullname: ${widget.studentProfile.fullName} (${widget.studentProfile.objectId})",
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
                  Text(
                    "${widget.studentProfile.techStack}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  // Text(
                  //   widget.studentProfile.introduction,
                  //   maxLines: 5,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  //   textAlign: TextAlign.left,
                  // ),
                  // const SizedBox(
                  //   height: 12,
                  // ),
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
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              height: 150,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.builder(
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        skills[index].name,
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w900,
                            fontSize: 14),
                      ),
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 5,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              visible: checkIfValid(),
              child: Container(
                padding: const EdgeInsets.only(top: 10, right: 30, bottom: 20),
                alignment: Alignment.bottomRight,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute2(
                        routeName: Routes.companyViewStudentProfile2,
                        arguments: widget.studentProfile));
                  },
                  child: const Text("View More"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
