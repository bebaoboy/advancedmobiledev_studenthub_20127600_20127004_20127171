import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class ProjectDetailsStudentScreen extends StatefulWidget {
  const ProjectDetailsStudentScreen({super.key, required this.project});
  final Project project;

  @override
  State<ProjectDetailsStudentScreen> createState() =>
      _ProjectDetailsStudentScreenState();
}

class _ProjectDetailsStudentScreenState
    extends State<ProjectDetailsStudentScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: _buildFourContent(),
      ),
    );
  }

  Widget _buildFourContent() {
    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.75),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.project.title.isEmpty
                              ? "Demo Project"
                              : widget.project.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(color: Colors.black),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: SingleChildScrollView(
                            child: Text(widget.project.description.isEmpty
                                ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
                                    'eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
                                    'eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                                : widget.project.description),
                          ),
                        ),
                      ),
                      const Divider(color: Colors.black),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.alarm,
                            size: 30,
                          ),
                          const SizedBox(
                              width:
                                  10), // You can adjust the space between the icon and the text
                          Text(
                              '${AppLocalizations.of(context).translate('project_scope')}\n  - ${widget.project.scope.title}'),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.people,
                            size: 30,
                          ),
                          const SizedBox(
                              width:
                                  10), // You can adjust the space between the icon and the text
                          Text(
                              '${AppLocalizations.of(context).translate('student_require')}\n  - ${widget.project.numberOfStudents} students'),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                )),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Flexible(
                //   fit: FlexFit.tight,
                //   child: TextButton(
                //     onPressed: () {
                //       widget.onSheetDismissed();
                //     },
                //     child: const Text('Cancel'),
                //   ),
                // ),
                // const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    surfaceTintColor: Colors.transparent,

                    minimumSize: Size(
                        MediaQuery.of(context).size.width / 2 - 48, 40), // NEW
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  onPressed: () {},
                  child: Text('Saved',
                    style: Theme.of(context).textTheme.bodyMedium!.merge(
                        TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    surfaceTintColor: Colors.transparent,
                    minimumSize: Size(
                        MediaQuery.of(context).size.width / 2 - 48, 40), // NEW
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  onPressed: () {},
                  child: Text('Apply Now',
                    style: Theme.of(context).textTheme.bodyMedium!.merge(
                        TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return const MainAppBar();
  }
}
