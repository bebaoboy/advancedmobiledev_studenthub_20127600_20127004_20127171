// ignore_for_file: must_be_immutable

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/domain/entity/project/myMockData.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/components/student_project_item.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class StudentDashBoardTab extends StatefulWidget {
  bool? isAlive;
  PageController pageController;
  StudentDashBoardTab(
      {super.key, this.isAlive = true, required this.pageController});

  @override
  State<StudentDashBoardTab> createState() => _StudentDashBoardTabState();
}

class _StudentDashBoardTabState extends State<StudentDashBoardTab>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildDashBoardContent();
  }

  Widget _buildDashBoardContent() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(Lang.get('Dashboard_your_job')),
              ),
            ],
          ),
        ),
        Expanded(
          // ignore: prefer_const_constructors
          child: ProjectTabs(
            tabController: tabController,
            pageController: widget.pageController,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => widget.isAlive!;
}

class ProjectTabs extends StatefulWidget {
  ProjectTabs({super.key, this.tabController, required this.pageController});
  TabController? tabController;
  PageController pageController;

  @override
  State<ProjectTabs> createState() => _ProjectTabsState();
}

class _ProjectTabsState extends State<ProjectTabs> {
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
                  AllProjects(
                    projects: studentProjects,
                  ),
                  WorkingProjects(
                    projects: studentWorkingProjects,
                  ),
                  AllProjects(
                    projects: studentProjects,
                  )
                ]),
          ),
        )
      ]),
    );
  }
}

class WorkingProjects extends StatefulWidget {
  final List<StudentProject>? projects;
  const WorkingProjects({super.key, required this.projects});

  @override
  State<WorkingProjects> createState() => _WorkingProjectsState();
}

class _WorkingProjectsState extends State<WorkingProjects> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
  const AllProjects({Key? key, required this.projects});

  @override
  State<AllProjects> createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  late List<StudentProject>? activeProjects;
  late List<StudentProject>? submittedProjects;

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
                      child: Text(Lang.get("active_proposal") +
                          '(${activeProjects?.length ?? 0})')),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
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
                      child: Text(Lang.get("submitted_proposal") +
                          '(${submittedProjects?.length ?? 0})')),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
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
