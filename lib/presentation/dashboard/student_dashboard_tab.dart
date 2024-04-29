// ignore_for_file: must_be_immutable

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/presentation/dashboard/components/student_project_item.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:flutter/rendering.dart';

class StudentDashBoardTab extends StatefulWidget {
  final bool? isAlive;
  final ScrollController? pageController;
  const StudentDashBoardTab(
      {super.key, this.isAlive = true, this.pageController});

  @override
  State<StudentDashBoardTab> createState() => _StudentDashBoardTabState();
}

class _StudentDashBoardTabState extends State<StudentDashBoardTab> {
  //  TabController tabController;
  @override
  void initState() {
    super.initState();
    // tabController = TabController(length: 3, vsync: this);
    future = _projectStore.getStudentProposalProjects(
        _userStore.user!.studentProfile!.objectId!, setStateCallback: () {
      try {
        setState(() {
          loading = false;
        });
      } catch (e) {
        ///
      }
    });
  }

  final _userStore = getIt<UserStore>();
  final _projectStore = getIt<ProjectStore>();
  late Future<ProposalList> future;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return _buildDashBoardContent();
  }

  Widget _buildDashBoardContent() {
    return FutureBuilder<ProposalList>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<ProposalList> snapshot) {
        Widget children;
        if (snapshot.hasData && !loading) {
          children = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(Lang.get('dashboard_your_job')),
                  ),

                  // Conditional rendering based on whether (widget.projects ?? []) is empty or not
                  (_userStore.user?.studentProfile?.proposalProjects ?? [])
                          .isEmpty
                      ? Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(Lang.get('Dashboard_intro')),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(Lang.get('Dashboard_content')),
                            ),
                          ],
                        )
                      // ignore: prefer_const_constructors
                      : Expanded(
                          // ignore: prefer_const_constructors
                          child: ProjectTabs(
                            // tabController: tabController,
                            pageController: widget.pageController,
                          ),
                        ),
                ],
              ));
        } else if (snapshot.hasError) {
          children = Center(
            child: Text(Lang.get("error")),
          );
        } else {
          print("loading");
          children = const Center(
            child: LoadingScreenWidget(
              size: 80,
            ),
          );
        }
        return children;
      },
    );
  }
}

class ProjectTabs extends StatefulWidget {
  ProjectTabs({super.key, this.tabController, this.pageController});
  TabController? tabController;
  ScrollController? pageController;

  @override
  State<ProjectTabs> createState() => _ProjectTabsState();
}

class _ProjectTabsState extends State<ProjectTabs> {
  var userStore = getIt<UserStore>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: SegmentedTabControl(
            controller: widget.tabController,
            height: Dimens.tab_height,
            radius: const Radius.circular(12),
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            tabTextColor: Colors.black45,
            backgroundColor: Colors.grey.shade300,
            selectedTabTextColor: Colors.white,
            tabs: const [
              SegmentTab(
                label: 'All projects',
              ),
              SegmentTab(
                label: 'Working',
              ),
              SegmentTab(
                label: 'Archived',
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Dimens.tab_height + 8, bottom: 5),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
                controller: widget.tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  AllProjects(
                    projects: userStore.user?.studentProfile?.proposalProjects
                        ?.where((e) =>
                            e.project != null &&
                            (e.hiredStatus == HireStatus.notHired ||
                                e.hiredStatus == HireStatus.pending))
                        .toList(),
                  ),
                  WorkingProjects(
                      scrollController: widget.pageController,
                      projects: userStore.user?.studentProfile?.proposalProjects
                          ?.where((e) =>
                              e.project != null &&
                              e.hiredStatus == HireStatus.hired)
                          .toList()),
                  ArchiveProjects(
                    scrollController: ScrollController(),
                    projects: userStore.user?.studentProfile?.proposalProjects
                        ?.where((e) => e.project != null && !e.enabled)
                        .toList(),
                  ),
                ]),
          ),
        )
      ]),
    );
  }
}

class WorkingProjects extends StatefulWidget {
  final List<Proposal>? projects;
  final ScrollController? scrollController;
  const WorkingProjects(
      {super.key, required this.projects, required this.scrollController});

  @override
  State<WorkingProjects> createState() => _WorkingProjectsState();
}

class _WorkingProjectsState extends State<WorkingProjects> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: widget.projects?.length ?? 0,
      itemBuilder: (context, index) {
        // widget.projects![index].isLoading = false;
        return StudentProjectItem(project: widget.projects![index]);
      },
    );
  }
}

class ArchiveProjects extends StatefulWidget {
  final List<Proposal>? projects;
  final ScrollController? scrollController;
  const ArchiveProjects(
      {super.key, required this.projects, required this.scrollController});

  @override
  State<ArchiveProjects> createState() => _ArchiveProjectsState();
}

class _ArchiveProjectsState extends State<ArchiveProjects> {
  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(
        () {
          if (widget.scrollController!.position.userScrollDirection ==
              ScrollDirection.reverse) {
            NavbarNotifier2.hideBottomNavBar = true;
          } else {
            NavbarNotifier2.hideBottomNavBar = false;
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: widget.projects?.length ?? 0,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // widget.projects![index].isLoading = false;
        return StudentProjectItem(project: widget.projects![index]);
      },
    );
  }
}

class AllProjects extends StatefulWidget {
  final List<Proposal>? projects;
  const AllProjects({super.key, required this.projects});

  @override
  State<AllProjects> createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  List<Proposal>? activeProjects = [];
  List<Proposal>? submittedProjects = [];

  @override
  void initState() {
    super.initState();

    if (widget.projects != null) {
      activeProjects = widget.projects!
          .where((element) => element.hiredStatus == HireStatus.pending)
          .toList();
      submittedProjects = widget.projects!
          .where((element) => element.hiredStatus == HireStatus.notHired)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Accordion(
      paddingListTop: 10,
      paddingListBottom: 0,
      paddingListHorizontal: 10,
      scaleWhenAnimating: true,
      maxOpenSections: 1,
      headerBackgroundColorOpened: Colors.black54,
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      children: [
        AccordionSection(
          isOpen: true,
          leftIcon: const Icon(Icons.insights_rounded, color: Colors.white),
          headerBackgroundColor: Colors.black38,
          headerBackgroundColorOpened: Colors.black54,
          header: Padding(
            padding: const EdgeInsets.only(top: 12, left: 10),
            child: Container(
                alignment: Alignment.topLeft,
                child: Text(
                  '${Lang.get("active_proposal")}(${activeProjects?.length ?? 0})',
                  style: const TextStyle(color: Colors.white),
                )),
          ),
          content: LimitedBox(
            maxHeight: MediaQuery.of(context).size.height / 2,
            child: ListView.builder(
              controller: ScrollController()
                ..addListener(() => NavbarNotifier2.hideBottomNavBar = false),
              itemCount: activeProjects?.length ?? 0,
              itemBuilder: (context, index) {
                // activeProjects![index].isLoading = false;
                return StudentProjectItem(project: activeProjects![index]);
              },
            ),
          ),
          contentHorizontalPadding: 20,
          contentBorderColor: Colors.black54,
        ),
        AccordionSection(
          leftIcon: const Icon(Icons.compare_rounded, color: Colors.white),
          header: Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12.0),
            child: Container(
                alignment: Alignment.topLeft,
                child: Text(
                  '${Lang.get("submitted_proposal")}(${submittedProjects?.length ?? 0})',
                  style: const TextStyle(color: Colors.white),
                )),
          ),
          headerBackgroundColor: Colors.black38,
          headerBackgroundColorOpened: Colors.black54,
          contentBorderColor: Colors.black54,
          content: LimitedBox(
              maxHeight: MediaQuery.of(context).size.height / 2,
              child: ListView.builder(
                controller: ScrollController()
                  ..addListener(() => NavbarNotifier2.hideBottomNavBar = false),
                itemCount: submittedProjects?.length ?? 0,
                itemBuilder: (context, index) {
                  // submittedProjects![index].isLoading = false;
                  return StudentProjectItem(project: submittedProjects![index]);
                },
              )),
        ),
      ],
    );
    // Column(
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     Expanded(
    //       child: Container(
    //         decoration: BoxDecoration(
    //             border: Border.all(width: 1, color: Colors.black)),
    //         child: Column(
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.only(top: 12, left: 12),
    //               child: Container(
    //                   alignment: Alignment.topLeft,
    //                   child: Text(
    //                       '${Lang.get("active_proposal")}(${activeProjects?.length ?? 0})')),
    //             ),
    //             Flexible(
    //               fit: FlexFit.loose,
    //               child: ListView.builder(
    //                 controller: ScrollController(),
    //                 itemCount: activeProjects?.length ?? 0,
    //                 itemBuilder: (context, index) {
    //                   activeProjects![index].isLoading = false;
    //                   return StudentProjectItem(
    //                       project: activeProjects![index]);
    //                 },
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     const SizedBox(
    //       height: 12,
    //     ),
    //     Expanded(
    //       child: Container(
    //         decoration: BoxDecoration(
    //             border: Border.all(width: 1, color: Colors.black)),
    //         child: Column(
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.only(top: 12.0, left: 12.0),
    //               child: Container(
    //                   alignment: Alignment.topLeft,
    //                   child: Text(
    //                       '${Lang.get("submitted_proposal")}(${submittedProjects?.length ?? 0})')),
    //             ),
    //             Flexible(
    //               fit: FlexFit.loose,
    //               child: ListView.builder(
    //                 controller: ScrollController(),
    //                 itemCount: submittedProjects?.length ?? 0,
    //                 itemBuilder: (context, index) {
    //                   submittedProjects![index].isLoading = false;
    //                   return StudentProjectItem(
    //                       project: submittedProjects![index]);
    //                 },
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     const SizedBox(
    //       height: 16,
    //     )
    //   ],
    // );
  }
}
