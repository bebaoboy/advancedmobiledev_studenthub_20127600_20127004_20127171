// ignore_for_file: must_be_immutable

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/presentation/dashboard/components/student_project_item.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';

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
  }

  final _userStore = getIt<UserStore>();
  final _projectStore = getIt<ProjectStore>();

  @override
  Widget build(BuildContext context) {
    return _buildDashBoardContent();
  }

  Widget _buildDashBoardContent() {
    return FutureBuilder<ProposalList>(
      future: _projectStore
          .getStudentProposalProjects(_userStore.user!.studentProfile!.objectId!),
      builder: (BuildContext context, AsyncSnapshot<ProposalList> snapshot) {
        Widget children;
        if (snapshot.hasData) {
          children = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(Lang.get('dashboard_your_job')),
                  ),

                  // Conditional rendering based on whether (widget.projects ?? []) is empty or not
                  (_userStore.user != null &&
                          _userStore.user!.studentProfile != null &&
                          _userStore.user!.studentProfile!.proposalProjects !=
                              null &&
                          _userStore
                              .user!.studentProfile!.proposalProjects!.isEmpty)
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
          children = Center(
            child: Lottie.asset(
              'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
              fit: BoxFit.cover,
              width: 80, // Adjust the width and height as needed
              height: 80,
              repeat: true, // Set to true if you want the animation to loop
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
      initialIndex: 0,
      length: 3,
      child: Stack(children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Dimens.horizontal_padding),
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
          padding:
              const EdgeInsets.only(top: Dimens.tab_height + 8, bottom: 55),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
                controller: widget.tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  // TODO: get student project from id from proposals
                  Observer(
                    builder: (context) => AllProjects(
                      projects: userStore.user?.studentProfile?.proposalProjects
                          ?.where((e) => e.project != null)
                          .map(
                            (e) => e.project!,
                          )
                          .toList(),
                    ),
                  ),
                  WorkingProjects(
                      scrollController: widget.pageController, projects: null),
                  Observer(
                    builder: (context) => AllProjects(
                      projects: userStore.user?.studentProfile?.proposalProjects
                          ?.where((e) => e.project != null)
                          .map(
                            (e) => e.project!,
                          )
                          .toList(),
                    ),
                  ),
                ]),
          ),
        )
      ]),
    );
  }
}

class WorkingProjects extends StatefulWidget {
  final List<StudentProject>? projects;
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
        widget.projects![index].isLoading = false;
        return StudentProjectItem(project: widget.projects![index]);
      },
    );
  }
}

class AllProjects extends StatefulWidget {
  final List<StudentProject>? projects;
  const AllProjects({super.key, required this.projects});

  @override
  State<AllProjects> createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  List<StudentProject>? activeProjects = [];
  List<StudentProject>? submittedProjects = [];

  @override
  void initState() {
    super.initState();

    if (widget.projects != null) {
      activeProjects = widget.projects!
          .where((element) => element.isAccepted && element.isSubmitted)
          .toList();
      submittedProjects = widget.projects!
          .where((element) => !element.isAccepted && element.isSubmitted)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12),
                  child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                          '${Lang.get("active_proposal")}(${activeProjects?.length ?? 0})')),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    controller: ScrollController(),
                    itemCount: activeProjects?.length ?? 0,
                    itemBuilder: (context, index) {
                      activeProjects![index].isLoading = false;
                      return StudentProjectItem(
                          project: activeProjects![index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                  child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                          '${Lang.get("submitted_proposal")}(${submittedProjects?.length ?? 0})')),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    controller: ScrollController(),
                    itemCount: submittedProjects?.length ?? 0,
                    itemBuilder: (context, index) {
                      submittedProjects![index].isLoading = false;
                      return StudentProjectItem(
                          project: submittedProjects![index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }
}
