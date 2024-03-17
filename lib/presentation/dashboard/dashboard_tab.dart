import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';
import 'package:boilerplate/domain/entity/project/myMockData.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/components/my_project_item.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';

class DashBoardTab extends StatefulWidget {
  DashBoardTab({super.key, this.isAlive = true, required this.pageController});
  bool? isAlive;
  PageController pageController;

  @override
  State<DashBoardTab> createState() => _DashBoardTabState();
}

class _DashBoardTabState extends State<DashBoardTab>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    // tabController.addListener(() {
    //   if (tabController.index == 2 && tabController.offset > 0) {
    //     print("right");
    //     widget.pageController.animateToPage(NavbarNotifier2.currentIndex + 1,
    //         duration: Duration(seconds: 1), curve: Curves.ease);
    //   } else if (tabController.index == 0 && tabController.offset < -0) {
    //     print("left");
    //     widget.pageController.animateToPage(NavbarNotifier2.currentIndex - 1,
    //         duration: Duration(seconds: 1), curve: Curves.ease);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Text(AppLocalizations.of(context)
                    .translate('Dashboard_your_job')),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 100,
                  height: 30,
                  child: FloatingActionButton(
                    heroTag: "F3",
                    onPressed: () {
                      // NavbarNotifier2.pushNamed(Routes.project_post, NavbarNotifier2.currentIndex, null);
                      Navigator.of(
                              NavigationService.navigatorKey.currentContext!)
                          .push(MaterialPageRoute2(
                              routeName: Routes.project_post));
                    },
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('Dashboard_post_job'),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
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
                child: ProjectTabs(
                  tabController: tabController,
                  pageController: widget.pageController,
                ),
              ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
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
          child: TabBarView(
              controller: widget.tabController,
              physics: const BouncingScrollPhysics(),
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
    title: Text(
      "Menu",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    context: NavigationService.navigatorKey.currentContext!,
    isDismissible: true,
    barrierColor: Colors.black87,
    actions: <BottomSheetAction>[
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: const Text(
              'View proposals',
              style: TextStyle(fontWeight: FontWeight.normal),
            )),
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: const Text('View messages',
                style: TextStyle(fontWeight: FontWeight.w100))),
      ),
      BottomSheetAction(
        title: Container(
          alignment: Alignment.topLeft,
          child: const Text('View hired',
              style: TextStyle(fontWeight: FontWeight.normal)),
        ),
      ),
      BottomSheetAction(
        title: null,
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: const Text('View job posting',
                style: TextStyle(fontWeight: FontWeight.normal))),
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: const Text('Edit posting',
                style: TextStyle(fontWeight: FontWeight.normal))),
      ),
      BottomSheetAction(
        title: Container(
          alignment: Alignment.topLeft,
          child: const Text('Remove posting',
              style: TextStyle(fontWeight: FontWeight.normal)),
        ),
      ),
      BottomSheetAction(
        title: null,
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: const Text('Start working this project',
                style: TextStyle(fontWeight: FontWeight.normal))),
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
    return ListView.builder(
      itemCount: widget.projects?.length ?? 0,
      itemBuilder: (context, index) => MyProjectItem(
        project: myProjects[index],
        onShowBottomSheet: showBottomSheet,
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
    return ListView.builder(
      itemCount: widget.projects?.length ?? 0,
      itemBuilder: (context, index) => MyProjectItem(
        project: myProjects[index],
        onShowBottomSheet: showBottomSheet,
      ),
    );
  }
}
