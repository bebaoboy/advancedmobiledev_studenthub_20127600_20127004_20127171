// ignore_for_file: deprecated_member_use

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/mockData.dart';
import 'package:boilerplate/domain/entity/project/myMockData.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/components/my_project_item.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';

// ignore: must_be_immutable
class DashBoardTab extends StatefulWidget {
  const DashBoardTab(
      {super.key, this.isAlive = true, required this.pageController});
  final bool? isAlive;
  final PageController pageController;

  @override
  State<DashBoardTab> createState() => _DashBoardTabState();
}

class _DashBoardTabState extends State<DashBoardTab> {
  // late TabController tabController;
  final ProjectStore _projectStore = getIt<ProjectStore>();

  @override
  void initState() {
    super.initState();
    //tabController = TabController(length: 3, vsync: this);
    // tabController.addListener(() {
    //   if (tabController.index == 2 && tabController.offset > 0) {
    //     //print("right");
    //     widget.pageController.animateToPage(NavbarNotifier2.currentIndex + 1,
    //         duration: Duration(seconds: 1), curve: Curves.ease);
    //   } else if (tabController.index == 0 && tabController.offset < -0) {
    //     //print("left");
    //     widget.pageController.animateToPage(NavbarNotifier2.currentIndex - 1,
    //         duration: Duration(seconds: 1), curve: Curves.ease);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: _buildDashBoardContent(),
    );
  }

  var projectStore = getIt<ProjectStore>();

  Widget _buildDashBoardContent() {
    //print("rebuild db tab");
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(Lang.get('dashboard_your_job')),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: 150,
                  height: 30,
                  child: RoundedButtonWidget(
                    onPressed: () async {
                      // NavbarNotifier2.pushNamed(Routes.project_post, NavbarNotifier2.currentIndex, null);
                      await Navigator.of(
                              NavigationService.navigatorKey.currentContext!)
                          .push(
                              MaterialPageRoute2(routeName: Routes.projectPost))
                          .then((value) {
                        setState(() {
                          if (value != null) {
                            allProjects.insert(0, value as Project);
                            projectStore.companyProjects.insert(0, value);
                            _projectStore.addProject(value);
                          }
                        });
                      });
                    },
                    buttonText: Lang.get('Dashboard_post_job'),
                    buttonColor: Theme.of(context).colorScheme.primary,
                    textColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Conditional rendering based on whether (widget.projects ?? []) is empty or not
        projectStore.companyProjects.isEmpty
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
    );
  }

  bool get wantKeepAlive => widget.isAlive!;
}

// ignore: must_be_immutable
class ProjectTabs extends StatefulWidget {
  ProjectTabs({super.key, this.tabController, required this.pageController});
  TabController? tabController;
  PageController pageController;

  @override
  State<ProjectTabs> createState() => _ProjectTabsState();
}

class _ProjectTabsState extends State<ProjectTabs> {
  var projectStore = getIt<ProjectStore>();

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
            textStyle:
                Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 14),
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
          padding: const EdgeInsets.only(
            top: Dimens.tab_height + 8,
          ),
          child: TabBarView(
              controller: widget.tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                AllProjects(
                  projects: [...projectStore.companyProjects, ...myProjects],
                ),
                const WorkingProjects(
                  projects: [],
                ),
                AllProjects(
                  projects: [...projectStore.companyProjects, ...myProjects],
                )
              ]),
        )
      ]),
    );
  }
}

void showBottomSheet(Project project, Function workingCallback) {
  showAdaptiveActionSheet(
    title: const Text(
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
            child: Text(
              Lang.get('project_item_view_proposal'),
              style: const TextStyle(fontWeight: FontWeight.normal),
            )),
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: Text(Lang.get('project_item_view_message'),
                style: const TextStyle(fontWeight: FontWeight.w100))),
      ),
      BottomSheetAction(
        title: Container(
          alignment: Alignment.topLeft,
          child: Text(Lang.get('project_item_view_hired'),
              style: const TextStyle(fontWeight: FontWeight.normal)),
        ),
      ),
      BottomSheetAction(
        title: null,
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: Text(Lang.get('project_item_view_job_posting'),
                style: const TextStyle(fontWeight: FontWeight.normal))),
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: Text(Lang.get('project_item_edit_job_posting'),
                style: const TextStyle(fontWeight: FontWeight.normal))),
      ),
      BottomSheetAction(
        title: Container(
          alignment: Alignment.topLeft,
          child: Text(Lang.get('project_item_remove_job_posting'),
              style: const TextStyle(fontWeight: FontWeight.normal)),
        ),
      ),
      BottomSheetAction(
        title: null,
      ),
      BottomSheetAction(
        title: Container(
            alignment: Alignment.topLeft,
            child: Text(Lang.get("project_start_working"),
                style: const TextStyle(fontWeight: FontWeight.normal))),
        onPressed: (_) {
          //print(project.title);
          workingCallback();
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
  late List<Project>? workingProjects;

  @override
  void initState() {
    super.initState();
    if (widget.projects != null) {
      workingProjects =
          widget.projects!.where((element) => element.isWorking).toList();
    } else {
      workingProjects = List.empty(growable: true);
    }
  }

  var projectStore = getIt<ProjectStore>();

  @override
  Widget build(BuildContext context) {
    return workingProjects != null && workingProjects!.isNotEmpty
        ? ListView.builder(
            controller: ScrollController(),
            itemCount: workingProjects?.length ?? 0,
            itemBuilder: (context, index) => MyProjectItem(
              project: workingProjects![index],
              onShowBottomSheet: (p) => showBottomSheet(p, () {
                (widget.projects ?? [])
                    .firstWhere(
                      (element) => element.objectId == p.objectId,
                      orElse: () => (widget.projects ?? [])[0],
                    )
                    .isWorking = true;
              }),
            ),
          )
        : Container(
            alignment: Alignment.center,
            child: const Text("You have no working projects"));
  }
}

class AllProjects extends StatefulWidget {
  final List<Project>? projects;
  const AllProjects({super.key, required this.projects});

  @override
  State<AllProjects> createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  var projectStore = getIt<ProjectStore>();

  @override
  Widget build(BuildContext context) {
    return ImplicitlyAnimatedList<Project>(
      items: (widget.projects ?? []),
      areItemsTheSame: (oldItem, newItem) {
        return oldItem.title == newItem.title &&
            oldItem.objectId == newItem.objectId;
      },
      itemBuilder: (context, animation, item, i) {
        return SizeFadeTransition(
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: animation,
            child: MyProjectItem(
              project: (widget.projects ?? [])[i],
              onShowBottomSheet: (p) => showBottomSheet(p, () {
                (widget.projects ?? [])
                    .firstWhere(
                      (element) => element.objectId == p.objectId,
                      orElse: () => (widget.projects ?? [])[0],
                    )
                    .isWorking = true;
              }),
            ));
      },
      removeItemBuilder: (context, animation, oldItem) {
        return SizeTransition(
          sizeFactor: animation,
          child: MyProjectItem(
            project: oldItem,
            onShowBottomSheet: (p) => showBottomSheet(p, () {
              (widget.projects ?? [])
                  .firstWhere(
                    (element) => element.objectId == p.objectId,
                    orElse: () => (widget.projects ?? [])[0],
                  )
                  .isWorking = true;
            }),
          ),
        );
      },
    );
  }
}
