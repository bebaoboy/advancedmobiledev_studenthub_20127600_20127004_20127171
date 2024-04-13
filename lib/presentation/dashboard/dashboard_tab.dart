// ignore_for_file: deprecated_member_use

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:boilerplate/constants/dimens.dart';
import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/mockData.dart';
import 'package:boilerplate/domain/entity/project/myMockData.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/presentation/dashboard/components/my_project_item.dart';
import 'package:boilerplate/presentation/dashboard/store/project_form_store.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/dashboard/store/update_project_form_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:toastification/toastification.dart';

// ignore: must_be_immutable
class DashBoardTab extends StatefulWidget {
  const DashBoardTab(
      {super.key, this.isAlive = true, required this.pageController});
  final bool? isAlive;
  final PageController pageController;

  @override
  State<DashBoardTab> createState() => _DashBoardTabState();
}

class _DashBoardTabState extends State<DashBoardTab>
    with SingleTickerProviderStateMixin {
  // late TabController tabController;
  // final ProjectStore _projectStore = getIt<ProjectStore>();

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
    future = projectStore
        .getProjectByCompany(_userStore.user!.companyProfile!.objectId!);

    scrollController.add(ScrollController());
    scrollController.add(ScrollController());
    scrollController.add(ScrollController());
    for (var element in scrollController) {
      element.addListener(() {
        if (element.position.userScrollDirection == ScrollDirection.reverse) {
          NavbarNotifier2.hideBottomNavBar = true;
        } else {
          NavbarNotifier2.hideBottomNavBar = false;
        }
      });
    }
    tabController = TabController(vsync: this, initialIndex: 0, length: 3);
    updateProjectStore.updateResult.addListener(
      () {
        try {
          print("change tabs");
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {});
            }
            // scrollController[tabController.index].animateTo(
            //   scrollController[tabController.index].position.minScrollExtent,
            //   duration: const Duration(seconds: 1000),
            //   curve: Curves.easeIn,
            // );
          });
        } catch (e) {
          // we can never scroll once we hard refresh
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: _buildDashBoardContent(),
    );
  }

  var projectStore = getIt<ProjectStore>();

  final UserStore _userStore = getIt<UserStore>();
  late Future<ProjectList> future;
  var updateProjectStore = getIt<UpdateProjectFormStore>();
  late final TabController tabController;
  List<ScrollController> scrollController = [];

  Widget _buildDashBoardContent() {
    //print("rebuild db tab");

    return FutureBuilder<ProjectList>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<ProjectList> snapshot) {
        Widget children;
        if (snapshot.hasData) {
          children = Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                            await Navigator.of(NavigationService
                                    .navigatorKey.currentContext!)
                                .push(MaterialPageRoute2(
                                    routeName: Routes.projectPost))
                                .then((value) {
                              setState(() {
                                if (value != null) {
                                  allProjects.insert(0, value as Project);
                                  //projectStore.companyProjects.insert(0, value);
                                  //_projectStore.addProject(value);
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
                        tabController: tabController,
                        scrollController: scrollController,
                      ),
                    ),
            ],
          );
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

  bool get wantKeepAlive => widget.isAlive!;
}

// ignore: must_be_immutable
class ProjectTabs extends StatefulWidget {
  ProjectTabs({
    super.key,
    required this.tabController,
    required this.pageController,
    required this.scrollController,
  });
  TabController tabController;
  PageController pageController;
  List<ScrollController> scrollController;

  @override
  State<ProjectTabs> createState() => _ProjectTabsState();
}

class _ProjectTabsState extends State<ProjectTabs> {
  var projectStore = getIt<ProjectStore>();
  var updateProjectStore = getIt<UpdateProjectFormStore>();

  @override
  void initState() {
    super.initState();
  }

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
                Observer(builder: (context) {
                  return AllProjects(
                    projects: [...projectStore.companyProjects, ...myProjects],
                    // projectFuture: ,
                    scrollController: widget.scrollController[0],
                    showBottomSheet: showBottomSheet,
                    onDismissed: (project, endToStart) => false,
                  );
                }),
                Observer(builder: (context) {
                  return WorkingProjects(
                    projects: [
                      ...projectStore.companyProjects.where(
                        (element) => element.isWorking,
                      )
                    ],
                    scrollController: widget.scrollController[1],
                    showBottomSheet: showBottomSheet,
                    onDismissed: onDismissed,
                  );
                }),
                Observer(builder: (context) {
                  return ArchivedProjects(
                    projects: [
                      ...projectStore.companyProjects.where(
                        (element) => element.isArchived,
                      )
                    ],
                    scrollController: widget.scrollController[2],
                    showBottomSheet: showBottomSheet,
                    onDismissed: onDismissed,
                  );
                })
              ]),
        )
      ]),
    );
  }

  void showBottomSheet(Project project) {
    final ProjectFormStore projectFormStore = getIt<ProjectFormStore>();
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
          title: null,
        ),
        BottomSheetAction(
            title: Container(
                alignment: Alignment.topLeft,
                child: Text(
                  Lang.get('project_item_view_proposal'),
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: project.enabled == Status.inactive
                          ? Colors.grey.shade500
                          : null),
                )),
            onPressed: (_) {
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(NavigationService.navigatorKey.currentContext ??
                        context)
                    .push(MaterialPageRoute2(
                        routeName: Routes.projectDetails,
                        arguments: {"project": project}));
              });
            }),
        BottomSheetAction(
            title: Container(
                alignment: Alignment.topLeft,
                child: Text(Lang.get('project_item_view_message'),
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: project.enabled == Status.inactive
                            ? Colors.grey.shade500
                            : null))),
            onPressed: (_) {
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(NavigationService.navigatorKey.currentContext ??
                        context)
                    .push(MaterialPageRoute2(
                        routeName: Routes.projectDetails,
                        arguments: {"project": project, "index": 2}));
              });
            }),
        BottomSheetAction(
            title: Container(
              alignment: Alignment.topLeft,
              child: Text(Lang.get('project_item_view_hired'),
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: project.enabled == Status.inactive
                          ? Colors.grey.shade500
                          : null)),
            ),
            onPressed: (_) {
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(NavigationService.navigatorKey.currentContext ??
                        context)
                    .push(MaterialPageRoute2(
                        routeName: Routes.projectDetails,
                        arguments: {"project": project, "index": 3}));
              });
            }),
        BottomSheetAction(
          title: null,
        ),
        BottomSheetAction(
            title: Container(
                alignment: Alignment.topLeft,
                child: Text(Lang.get('project_item_view_job_posting'),
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: project.enabled == Status.inactive
                            ? Colors.grey.shade500
                            : null))),
            onPressed: (_) {
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(NavigationService.navigatorKey.currentContext ??
                        context)
                    .push(MaterialPageRoute2(
                        routeName: Routes.projectDetails,
                        arguments: {"project": project, "index": 1}));
              });
            }),
        BottomSheetAction(
            title: Container(
                alignment: Alignment.topLeft,
                child: Text(
                  Lang.get('project_item_edit_job_posting'),
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: project.enabled == Status.inactive
                          ? Colors.grey.shade500
                          : null),
                )),
            onPressed: (_) {
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(NavigationService.navigatorKey.currentContext ??
                        context)
                    .push(MaterialPageRoute2(
                        routeName: Routes.updateProject, arguments: project));
              });
            }),
        BottomSheetAction(
            title: Container(
              alignment: Alignment.topLeft,
              child: Text(Lang.get('project_item_remove_job_posting'),
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: project.enabled == Status.inactive
                          ? Colors.grey.shade500
                          : null)),
            ),
            onPressed: (_) {
              // TODO: delete
              var p = (projectStore.companyProjects).firstWhereOrNull(
                (element) => element.objectId == project.objectId,
              );
              projectFormStore.deleteProject(project.objectId ?? "");
              if (p != null) {
                Toastify.show(
                    context,
                    "",
                    "Delete succesfully!",
                    aboveNavbar: !NavbarNotifier2.isNavbarHidden,
                    ToastificationType.success,
                    () {});
                projectStore.deleteCompanyProject(p);
              }
              setState(() {
                p?.enabled = Status.active;
              });
            }),
        BottomSheetAction(
          title: null,
        ),
        BottomSheetAction(
          title: Container(
              alignment: Alignment.topLeft,
              child: Text(Lang.get("project_start_working"),
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: project.enabled == Status.inactive
                          ? Colors.grey.shade500
                          : null))),
          onPressed: (_) {
            //print(project.title);
            var p = (projectStore.companyProjects).firstWhereOrNull(
              (element) => element.objectId == project.objectId,
            );
            // TODO: update project status flag active
            if (p != null) {
              Toastify.show(
                  context,
                  "",
                  p.isWorking
                      ? Lang.get("archive_successfully")
                      : Lang.get("unarchive_successfully"),
                  aboveNavbar: !NavbarNotifier2.isNavbarHidden,
                  ToastificationType.success,
                  () {});
              updateProjectStore.updateProject(int.tryParse(p.objectId!) ?? -1,
                  p.title, p.description, p.numberOfStudents, p.scope,
                  statusFlag: Status.inactive.index);
            }
            setState(() {
              p?.enabled = Status.active;
            });
          },
        ),
        BottomSheetAction(
            title: Container(
                alignment: Alignment.topLeft,
                child: Text(
                    project.enabled == Status.active
                        ? Lang.get("project_close")
                        : Lang.get("project_open"),
                    style: const TextStyle(fontWeight: FontWeight.normal))),
            onPressed: (_) {
              //print(project.title);
              var p = (projectStore.companyProjects).firstWhereOrNull(
                (element) => element.objectId == project.objectId,
              );
              // TODO: updateCompany status flag

              if (p != null) {
                Toastify.show(
                    context,
                    "",
                    p.isWorking
                        ? Lang.get("archive_successfully")
                        : Lang.get("unarchive_successfully"),
                    aboveNavbar: !NavbarNotifier2.isNavbarHidden,
                    ToastificationType.success,
                    () {});
                updateProjectStore.updateProject(
                    int.tryParse(p.objectId!) ?? -1,
                    p.title,
                    p.description,
                    p.numberOfStudents,
                    p.scope,
                    statusFlag: p.enabled == Status.active
                        ? Status.inactive.index
                        : Status.active.index);
              }
              setState(() {
                p?.enabled = p.enabled == Status.active
                    ? Status.inactive
                    : Status.active;
              });
            }),
      ],
    );
  }

  bool onDismissed(Project project, bool endToStart) {
    switch (endToStart) {
      case true:
        {
          var p = projectStore.companyProjects.firstWhereOrNull(
            (element) => element.objectId == project.objectId,
          );
          if (project.isWorking) {
            if (p != null) {
              Toastify.show(
                  context,
                  "",
                  p.isWorking
                      ? Lang.get("archive_successfully")
                      : Lang.get("unarchive_successfully"),
                  aboveNavbar: !NavbarNotifier2.isNavbarHidden,
                  ToastificationType.success,
                  () {});
              updateProjectStore.updateProject(int.tryParse(p.objectId!) ?? -1,
                  p.title, p.description, p.numberOfStudents, p.scope,
                  statusFlag: Status.inactive.index);
            }
            setState(() {
              p?.enabled = Status.inactive;
            });
            // TODO: update project status flag INactive
            return true;
          }
          return false;
        }
      case false:
        {
          var p = projectStore.companyProjects.firstWhereOrNull(
            (element) => element.objectId == project.objectId,
          );
          if (project.isArchived) {
            if (p != null) {
              Toastify.show(
                  context,
                  "",
                  p.isWorking
                      ? Lang.get("archive_successfully")
                      : Lang.get("unarchive_successfully"),
                  aboveNavbar: !NavbarNotifier2.isNavbarHidden,
                  ToastificationType.success,
                  () {});
              updateProjectStore.updateProject(int.tryParse(p.objectId!) ?? -1,
                  p.title, p.description, p.numberOfStudents, p.scope,
                  statusFlag: Status.active.index);
            }
            setState(() {
              p?.enabled = Status.active;
            });
            // TODO: update project status flag active
            return true;
          }
          return false;
        }
      default:
        return false;
    }
  }
}

class WorkingProjects extends StatefulWidget {
  final List<Project>? projects;
  const WorkingProjects(
      {super.key,
      required this.projects,
      required this.scrollController,
      required this.showBottomSheet,
      required this.onDismissed});
  final ScrollController scrollController;
  final Function(Project) showBottomSheet;
  final bool Function(Project project, bool endToStart) onDismissed;
  @override
  State<WorkingProjects> createState() => _WorkingProjectsState();
}

class _WorkingProjectsState extends State<WorkingProjects> {
  @override
  Widget build(BuildContext context) {
    return widget.projects != null && widget.projects!.isNotEmpty
        ? ListView.builder(
            controller: widget.scrollController,
            itemCount: widget.projects?.length ?? 0,
            itemBuilder: (context, index) => MyProjectItem(
              project: widget.projects![index],
              onShowBottomSheet: widget.showBottomSheet,
              onDismissed: widget.onDismissed,
            ),
          )
        : Container(
            alignment: Alignment.center,
            child: const Text("You have no working projects"));
  }
}

class ArchivedProjects extends StatefulWidget {
  final List<Project>? projects;
  const ArchivedProjects(
      {super.key,
      required this.projects,
      required this.scrollController,
      required this.showBottomSheet,
      required this.onDismissed});
  final ScrollController scrollController;
  final Function(Project) showBottomSheet;
  final bool Function(Project project, bool endToStart) onDismissed;

  @override
  State<ArchivedProjects> createState() => _ArchivedProjectsState();
}

class _ArchivedProjectsState extends State<ArchivedProjects> {
  var projectStore = getIt<ProjectStore>();

  @override
  Widget build(BuildContext context) {
    return widget.projects != null && widget.projects!.isNotEmpty
        ? ListView.builder(
            controller: widget.scrollController,
            itemCount: widget.projects?.length ?? 0,
            itemBuilder: (context, index) => MyProjectItem(
              project: widget.projects![index],
              onShowBottomSheet: widget.showBottomSheet,
              onDismissed: widget.onDismissed,
            ),
          )
        : Container(
            alignment: Alignment.center,
            child: const Text("You have no working projects"));
  }
}

class AllProjects extends StatefulWidget {
  final List<Project>? projects;
  // final Future<ProjectList> projectFuture;
  const AllProjects(
      {super.key,
      required this.projects,
      // required this.projectFuture,
      required this.scrollController,
      required this.showBottomSheet,
      required this.onDismissed});
  final ScrollController scrollController;
  final Function(Project) showBottomSheet;
  final bool Function(Project project, bool endToStart) onDismissed;

  @override
  State<AllProjects> createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("build tabs");

    return ImplicitlyAnimatedList<Project>(
      controller: widget.scrollController,
      items: widget.projects ?? [],
      areItemsTheSame: (oldItem, newItem) {
        return oldItem.title == newItem.title &&
            oldItem.objectId == newItem.objectId &&
            oldItem.enabled == newItem.enabled &&
            oldItem.updatedAt == newItem.updatedAt;
      },
      itemBuilder: (context, animation, item, i) {
        return SizeFadeTransition(
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: animation,
            child: MyProjectItem(
              dismissable: false,
              project: item,
              onShowBottomSheet: widget.showBottomSheet,
            ));
      },
      removeItemBuilder: (context, animation, oldItem) {
        return SizeFadeTransition(
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: animation,
            child: MyProjectItem(
              dismissable: false,
              project: oldItem,
              onShowBottomSheet: widget.showBottomSheet,
            ));
      },
    );
  }
}
