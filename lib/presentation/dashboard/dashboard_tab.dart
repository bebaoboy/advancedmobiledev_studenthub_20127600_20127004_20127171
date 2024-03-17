import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/domain/entity/project/myMockData.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/components/my_project_item.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DashBoardTab extends StatefulWidget {
  const DashBoardTab({super.key});

  @override
  State<DashBoardTab> createState() => _DashBoardTabState();
}

class _DashBoardTabState extends State<DashBoardTab> {
  @override
  Widget build(BuildContext context) {
    return _buildDashBoardContent();
  }

  Widget _buildDashBoardContent() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(AppLocalizations.of(context)
                    .translate('Dashboard_your_job')),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.topRight,
                child: RoundedButtonWidget(
                  onPressed: () {},
                  buttonColor: Theme.of(context).colorScheme.primary,
                  buttonText: AppLocalizations.of(context)
                      .translate('Dashboard_post_job'),
                  buttonTextSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Conditional rendering based on whether myProjects is empty or not
        myProjects.isEmpty
            ? Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context)
                        .translate('Dashboard_intro')),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context)
                        .translate('Dashboard_content')),
                  ),
                ],
              )
            // ignore: prefer_const_constructors
            : Expanded(
                // ignore: prefer_const_constructors
                child: ProjectTabs(),
              ),
      ],
    );
  }
}

class ProjectTabs extends StatefulWidget {
  const ProjectTabs({super.key});

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
          child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AllProjects(
                  projects: myProjects,
                ),
                WorkingProjects(
                  projects: workingProjects,
                ),
                AllProjects(
                  projects: myProjects,
                )
              ]),
        )
      ]),
    );
  }
}

void showBottomSheet(Project project) {
  showAdaptiveActionSheet(
    context: NavigationService.navigationKey.currentContext!,
    isDismissible: true,
    barrierColor: Colors.black87,
    actions: <BottomSheetAction>[
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft, child: const Text('View proposals')),
        onPressed: (_) {},
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft, child: const Text('View messages')),
        onPressed: (_) {},
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft, child: const Text('View hired')),
        onPressed: (_) {},
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: const Text('View job posting')),
        onPressed: (_) {},
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft, child: const Text('Edit posting')),
        onPressed: (_) {},
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft, child: const Text('Remove posting')),
        onPressed: (_) {},
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: const Text('Start working this project')),
        onPressed: (_) {
          workingProjects.add(project);
        },
      ),
    ],
  );
}

class WorkingProjects extends StatefulWidget {
  final List<Project>? projects;
  const WorkingProjects({super.key, required this.projects});

  @override
  State<WorkingProjects> createState() => _WorkingProjectsState();
}

class _WorkingProjectsState extends State<WorkingProjects> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: ListView.builder(
        itemCount: widget.projects?.length ?? 0,
        itemBuilder: (context, index) => MyProjectItem(
          project: myProjects[index],
          onShowBottomSheet: showBottomSheet,
        ),
      ),
    );
  }
}

class AllProjects extends StatefulWidget {
  final List<Project>? projects;
  const AllProjects({super.key, required this.projects});

  @override
  State<AllProjects> createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: ListView.builder(
        itemCount: widget.projects?.length ?? 0,
        itemBuilder: (context, index) => MyProjectItem(
          project: myProjects[index],
          onShowBottomSheet: showBottomSheet,
        ),
      ),
    );
  }
}
