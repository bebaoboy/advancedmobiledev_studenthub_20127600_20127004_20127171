import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDetailsStudentScreen extends StatefulWidget {
  const ProjectDetailsStudentScreen({super.key, required this.project});
  final Project project;

  @override
  State<ProjectDetailsStudentScreen> createState() =>
      _ProjectDetailsStudentScreenState();
}

class _ProjectDetailsStudentScreenState
    extends State<ProjectDetailsStudentScreen> {
  var updatedText = "";
  @override
  void initState() {
    super.initState();
    updatedText =
        "Created at ${DateFormat("HH:mm").format(widget.project.timeCreated.toLocal())}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 16.0, bottom: 10.0, left: 16.0, right: 16.0),
        child: _buildFourContent(),
      ),
    );
  }

  Widget _buildFourContent() {
    return Stack(
      // mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Positioned.fill(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: SingleChildScrollView(
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
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade300),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(color: Colors.black),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 350),
                          child: SingleChildScrollView(
                            controller: ScrollController(),
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
                              '${Lang.get('project_scope')}\n  - ${widget.project.scope.title}'),
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
                              '${Lang.get('student_require')}\n  - ${widget.project.numberOfStudents} students'),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 45,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  updatedText.isEmpty
                                      ? "Just now"
                                      : updatedText,
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          bottom: 0,
          right: 0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RoundedButtonWidget(
                onPressed: () {},
                buttonText: Lang.get('save'),
                buttonTextSize: 16,
                buttonColor: Theme.of(context).primaryColor,
              ),
              MaterialButton(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.submitProposal,
                      arguments: widget.project);
                },
                child: Text(
                  Lang.get('apply_now'),
                  style: Theme.of(context).textTheme.bodyMedium!.merge(
                      TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return const MainAppBar();
  }
}
