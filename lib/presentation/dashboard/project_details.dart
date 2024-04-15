// ignore_for_file: deprecated_member_use

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/components/hired_item.dart';
import 'package:boilerplate/presentation/dashboard/components/proposal_item.dart';
import 'package:boilerplate/presentation/dashboard/store/update_project_form_store.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProjectDetailsPage extends StatefulWidget {
  final Project project;
  final int? initialIndex;
  const ProjectDetailsPage(
      {super.key, required this.project, this.initialIndex = 1});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  @override
  void initState() {
    super.initState();
    _updateStore.updateResult.addListener(
      () {
        print("change tabs");
        try {
          if (mounted) {
            setState(() {});
          }
        } catch (e) {
          ///
        }
      },
    );
  }

  final _updateStore = getIt<UpdateProjectFormStore>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        name: widget.project.objectId ?? "error id",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.horizontal_padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Text(
              widget.project.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DefaultTabController(
            initialIndex: widget.initialIndex ?? 0,
            length: 4,
            child: Stack(children: [
              SegmentedTabControl(
                height: Dimens.tab_height + 8,
                radius: const Radius.circular(12),
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                tabTextColor: Colors.black45,
                selectedTabTextColor: Colors.white,
                backgroundColor: Colors.grey.shade300,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 11.7),
                tabs: const [
                  SegmentTab(label: 'Proposals'),
                  SegmentTab(label: 'Detail'),
                  SegmentTab(label: 'Message'),
                  SegmentTab(label: 'Hired'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ProposalTabLayout(
                          proposals: widget.project.proposal,
                          onHired: (index) {
                            print("hired");
                            setState(() {
                              try {
                                // TODO: use a callback, cannot access projectStore.companyProject here
                                // widget.project.hired != null
                                //     ? widget.project.hired!.add(widget
                                //         .project.proposal!
                                //         .elementAt(index))
                                //     : widget.project.hired = [
                                //         widget.project.proposal!.elementAt(index)
                                //       ];
                              } catch (e) {
                                print("error hire student");
                              }
                            });
                          }),
                      DetailTabLayout(
                        project: widget.project,
                      ),
                      MessageTabLayout(
                          messages: widget.project.messages == null
                              ? []
                              : widget.project.messages!
                                  .map(
                                    (e) => e.student,
                                  )
                                  .toList()),
                      HiredTabLayout(
                          hired: widget.project.hired == null
                              ? []
                              : widget.project.hired!
                                  .map(
                                    (e) => e.student,
                                  )
                                  .toList()),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class ProposalTabLayout extends StatelessWidget {
  final List<Proposal>? proposals;

  const ProposalTabLayout(
      {super.key, required this.proposals, required this.onHired});
  final Function? onHired;

  @override
  Widget build(BuildContext context) {
    return (proposals?.length ?? 0) == 0
        ? Center(child: Text(Lang.get("nothing_here")))
        : ListView.builder(
            controller: ScrollController(),
            itemCount: proposals?.length ?? 0,
            itemBuilder: (context, index) {
              return ProposalItem(
                  proposal: proposals![index],
                  // pending: false,
                  onHired: () => onHired!(index));
            },
          );
  }
}

// ignore: must_be_immutable
class DetailTabLayout extends StatefulWidget {
  final Project project;
  const DetailTabLayout({super.key, required this.project});

  @override
  State<DetailTabLayout> createState() => _DetailTabLayoutState();
}

class _DetailTabLayoutState extends State<DetailTabLayout> {
  var userStore = getIt<UserStore>();

  final _languageStore = getIt<LanguageStore>();
  var createdText = '';
  var createdText2 = '';
  var updatedText = "";

  @override
  void initState() {
    super.initState();
    // int differenceWithToday = widget.project.getModifiedTimeCreated();
    // if (differenceWithToday == 0) {
    //   createdText = Lang.get("created_now");
    // } else if (differenceWithToday == 1) {
    //   createdText = 'Created 1 day ago';
    // } else {
    //   createdText = 'Created $differenceWithToday${Lang.get('day_ago')}';
    // }
    createdText =
        "Created: ${DateFormat("HH:mm").format(widget.project.timeCreated.toLocal())}";
    createdText2 = timeago.format(
        locale: _languageStore.locale, widget.project.timeCreated);

    if (widget.project.updatedAt != null &&
        widget.project.updatedAt! != widget.project.timeCreated) {
      updatedText =
          "Edit at ${DateFormat("HH:mm").format(widget.project.updatedAt!.toLocal())}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
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
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                            child: Text(widget.project.description)),
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
                                createdText2,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                createdText,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                updatedText.isEmpty
                                    ? Lang.get('project_update_same')
                                    : updatedText,
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ]),
                )),
            if (userStore.user != null &&
                userStore.user!.companyProfile != null &&
                userStore.user!.type == UserType.company &&
                widget.project.companyId ==
                    userStore.user!.companyProfile!.objectId!)
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Flexible(
                    //   fit: FlexFit.tight,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       widget.onSheetDismissed();
                    //     },
                    //     child: const Text(Lang.get('Cancel'),
                    //   ),
                    // ),
                    // const SizedBox(width: 16),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor:
                    //         Theme.of(context).colorScheme.primaryContainer,
                    //     surfaceTintColor: Colors.transparent,

                    //     minimumSize: Size(
                    //         MediaQuery.of(context).size.width / 2 - 48, 40), // NEW
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(3),
                    //     ),
                    //   ),
                    //   onPressed: () {},
                    //   child: Text(Lang.get('Saved',
                    //     style: Theme.of(context).textTheme.bodyMedium!.merge(
                    //         TextStyle(
                    //             color: Theme.of(context).colorScheme.secondary)),
                    //   ),
                    // ),
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
                        Navigator.push(
                                context,
                                MaterialPageRoute2(
                                    routeName: Routes.updateProject,
                                    arguments: widget.project))
                            .then((value) {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                      child: Text(
                        Lang.get('project_edit'),
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
  }
}

class HiredTabLayout extends StatelessWidget {
  final List<StudentProfile>? hired;

  const HiredTabLayout({super.key, required this.hired});

  @override
  Widget build(BuildContext context) {
    return (hired?.length ?? 0) == 0
        ? Center(child: Text(Lang.get("nothing_here")))
        : ListView.builder(
            controller: ScrollController(),
            itemCount: hired?.length ?? 0,
            itemBuilder: (context, index) {
              // return ListTile(
              //   title: Text(hired![index].name),
              // );

              return HiredItem(
                hired: hired![index],
                pending: false,
              );
            },
          );
  }
}

class MessageTabLayout extends StatelessWidget {
  final List<StudentProfile>? messages;

  const MessageTabLayout({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return (messages?.length ?? 0) == 0
        ? Center(child: Text(Lang.get("nothing_here")))
        : ListView.builder(
            controller: ScrollController(),
            itemCount: messages?.length ?? 0,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(messages![index].fullName),
              );
            },
          );
  }
}
