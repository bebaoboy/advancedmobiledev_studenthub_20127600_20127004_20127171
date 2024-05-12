import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:toastification/toastification.dart';

class StudentProjectItem extends StatefulWidget {
  final Proposal project;

  const StudentProjectItem({super.key, required this.project});

  @override
  _StudentProjectItemState createState() => _StudentProjectItemState();
}

class _StudentProjectItemState extends State<StudentProjectItem> {
  final _languageStore = getIt<LanguageStore>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var submittedText = '';
    submittedText = timeago
        .format(
            locale: _languageStore.locale,
            widget.project.updatedAt ??
                widget.project.createdAt ??
                DateTime.now())
        .inCaps;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 230),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.black54, width: 0.4, style: BorderStyle.solid),
        ),
        child: InkWell(
          onTap: () {
            if (widget.project.project != null) {
              Navigator.of(NavigationService.navigatorKey.currentContext!)
                  .pushNamed(Routes.projectDetailsStudent,
                      arguments: {"project": widget.project.project!});
            } else {
              Toastify.show(context, Lang.get("error"), "Project is null",
                  ToastificationType.error, () {},
                  aboveNavbar: true);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.project.project?.title ?? "Untitled") +
                              (" (id = ${widget.project.objectId})"),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        Text(submittedText,
                            style: const TextStyle(color: Colors.black)),
                        Text(widget.project.coverLetter,
                            style: const TextStyle(color: Colors.black)),
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
  // }
}
