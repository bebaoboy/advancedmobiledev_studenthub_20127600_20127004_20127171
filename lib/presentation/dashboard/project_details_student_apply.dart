import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDetailsStudentApplyScreen extends StatefulWidget {
  const ProjectDetailsStudentApplyScreen({super.key, required this.project});
  final Project project;

  @override
  State<ProjectDetailsStudentApplyScreen> createState() =>
      _ProjectDetailsStudentApplyScreenState();
}

class _ProjectDetailsStudentApplyScreenState
    extends State<ProjectDetailsStudentApplyScreen> {
  var updatedText = "";
  bool hasAlreadyApplied = false;
  @override
  void initState() {
    super.initState();
    updatedText =
        "Updated at ${DateFormat("HH:mm dd-MM-yyyy").format(widget.project.timeCreated.toLocal())}";
    var userStore = getIt<UserStore>();
    hasAlreadyApplied = userStore.user != null &&
        userStore.user!.studentProfile != null &&
        userStore.user!.studentProfile!.proposalProjects != null &&
        userStore.user!.studentProfile!.proposalProjects!.firstWhereOrNull(
              (element) => element.projectId == widget.project.objectId,
            ) !=
            null;
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.80,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                    Container(
                      // margin: const EdgeInsetsDirectional.only(
                      //     top: Dimens.vertical_padding + 10),
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(maxHeight: 350),
                      decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(width: 1, color: Colors.black),
                              bottom:
                                  BorderSide(width: 1, color: Colors.black))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SingleChildScrollView(
                            controller: ScrollController(),
                            child: Text(widget.project.description.isEmpty
                                ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
                                    'eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
                                    'eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                                : widget.project.description)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.alarm,
                            size: 45,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Lang.get('project_scope'),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                widget.project.scope.title,
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 45,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${Lang.get('project_item_students')} ${widget.project.numberOfStudents}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        )
                      ],
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
                                updatedText,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.business_outlined,
                          size: 45,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: AutoSizeText(
                                maxLines: 5,
                                '${Lang.get('profile_question_title_2')}: ${widget.project.companyId}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ]),
                )),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      surfaceTintColor: Colors.transparent,
                      minimumSize: Size(
                          MediaQuery.of(context).size.width / 2 - 48,
                          40), // NEW
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.submitProposal,
                          arguments: widget.project);
                    },
                    child: Text(
                      Lang.get('save'),
                      style: Theme.of(context).textTheme.bodyMedium!.merge(
                          TextStyle(
                              color: Theme.of(context).colorScheme.secondary)),
                    ),
                  ),
                  if (!hasAlreadyApplied)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        surfaceTintColor: Colors.transparent,
                        minimumSize: Size(
                            MediaQuery.of(context).size.width / 2 - 48,
                            40), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(Routes.submitProposal,
                                arguments: widget.project)
                            .then((value) {
                          if (value != null && value == true) {
                            setState(() {
                              hasAlreadyApplied = true;
                            });
                          }
                        });
                      },
                      child: Text(
                        Lang.get('apply_now'),
                        style: Theme.of(context).textTheme.bodyMedium!.merge(
                            TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Stack(
    //   // mainAxisSize: MainAxisSize.min,
    //   // crossAxisAlignment: CrossAxisAlignment.start,
    //   // mainAxisAlignment: MainAxisAlignment.center,
    //   children: <Widget>[
    //     Positioned.fill(
    //       child: Column(
    //         children: [
    //           SizedBox(
    //             height: MediaQuery.of(context).size.height * 0.8,
    //             child: SingleChildScrollView(
    //               child: Column(
    //                 children: [
    //                   const SizedBox(
    //                     height: 20,
    //                   ),
    //                   Align(
    //                     alignment: Alignment.topLeft,
    //                     child: Text(
    //                       widget.project.title.isEmpty
    //                           ? "Demo Project"
    //                           : widget.project.title,
    //                       style: TextStyle(
    //                           fontWeight: FontWeight.w700,
    //                           color: Colors.green.shade300),
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     height: 20,
    //                   ),
    //                   const Divider(color: Colors.black),
    //                   Align(
    //                     alignment: Alignment.topLeft,
    //                     child: Container(
    //                       constraints: const BoxConstraints(maxHeight: 350),
    //                       child: SingleChildScrollView(
    //                         controller: ScrollController(),
    //                         child: Text(widget.project.description.isEmpty
    //                             ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
    //                                 'eiusmod tempor incididunt ut labore et dolore magna aliqua.'
    //                                 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
    //                                 'eiusmod tempor incididunt ut labore et dolore magna aliqua.'
    //                             : widget.project.description),
    //                       ),
    //                     ),
    //                   ),
    //                   const Divider(color: Colors.black),
    //                   const SizedBox(
    //                     height: 20,
    //                   ),
    //                   Row(
    //                     children: <Widget>[
    //                       const Icon(
    //                         Icons.alarm,
    //                         size: 30,
    //                       ),
    //                       const SizedBox(
    //                           width:
    //                               10), // You can adjust the space between the icon and the text
    //                       Text(
    //                           '${Lang.get('project_scope')}\n  - ${widget.project.scope.title}'),
    //                     ],
    //                   ),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   Row(
    //                     children: <Widget>[
    //                       const Icon(
    //                         Icons.people,
    //                         size: 30,
    //                       ),
    //                       const SizedBox(
    //                           width:
    //                               10), // You can adjust the space between the icon and the text
    //                       Text(
    //                           '${Lang.get('student_require')}\n  - ${widget.project.numberOfStudents} students'),
    //                     ],
    //                   ),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.symmetric(vertical: 10.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.start,
    //                       children: [
    //                         const Icon(
    //                           Icons.calendar_month_outlined,
    //                           size: 45,
    //                         ),
    //                         const SizedBox(
    //                           width: 10,
    //                         ),
    //                         Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Text(
    //                               updatedText.isEmpty
    //                                   ? "Just now"
    //                                   : updatedText,
    //                             )
    //                           ],
    //                         )
    //                       ],
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     Positioned.fill(
    //       bottom: 0,
    //       right: 0,
    //       child: Row(
    //         mainAxisSize: MainAxisSize.max,
    //         crossAxisAlignment: CrossAxisAlignment.end,
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         children: [
    //           RoundedButtonWidget(
    //             onPressed: () {},
    //             buttonText: Lang.get('save'),
    //             buttonTextSize: 16,
    //             buttonColor: Theme.of(context).primaryColor,
    //           ),
    //           MaterialButton(
    //             color: Theme.of(context).primaryColor,
    //             onPressed: () {
    //               Navigator.of(context).pushNamed(Routes.submitProposal,
    //                   arguments: widget.project);
    //             },
    //             child: Text(
    //               Lang.get('apply_now'),
    //               style: Theme.of(context).textTheme.bodyMedium!.merge(
    //                   TextStyle(
    //                       color: Theme.of(context).colorScheme.secondary)),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return MainAppBar(
      name: widget.project.objectId ?? "",
    );
  }
}
