import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class StudentProjectItem extends StatefulWidget {
  final StudentProject project;

  const StudentProjectItem({super.key, required this.project});

  @override
  _StudentProjectItemState createState() => _StudentProjectItemState();
}

class _StudentProjectItemState extends State<StudentProjectItem> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
          ],
        ),
      );
    } else {
      var submittedText = '';
      int differenceWithToday = widget.project.getModifiedSubmittedTime();
      if (differenceWithToday == 0) {
        submittedText = Lang.get("created_now");
      } else if (differenceWithToday == 1) {
        submittedText = 'Created 1 day ago';
      } else {
        submittedText = 'Created $differenceWithToday' + Lang.get('day_ago');
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 230),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 1.0),
            bottom: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),
        child: Card(
          child: InkWell(
            onTap: () {
              print('navigate to student project detail');
              Navigator.of(NavigationService.navigatorKey.currentContext!)
                  .pushNamed(Routes.projectDetailsStudent,
                      arguments: widget.project);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(submittedText),
                          Text(widget.project.description),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
