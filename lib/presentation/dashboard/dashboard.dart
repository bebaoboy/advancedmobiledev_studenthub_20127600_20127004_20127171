// ignore_for_file: unused_field

import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/mockData.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/alert_tab.dart';
import 'package:boilerplate/presentation/dashboard/dashboard_tab.dart';
import 'package:boilerplate/presentation/dashboard/message_tab.dart';
import 'package:boilerplate/presentation/dashboard/project_tab.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:boilerplate/presentation/dashboard/student_dashboard_tab.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route_navbar.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';

String lastLocale = "";

// ---------------------------------------------------------------------------
class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  final int _selectedIndex = 1;

  final UserStore _userStore = getIt<UserStore>();

  @override
  void initState() {
    // currentPage = 0;
    // tabController = TabController(length: 4, vsync: this);
    // tabController.animation!.addListener(
    //   () {
    //     final value = tabController.animation!.value.round();
    //     if (value != currentPage && mounted) {
    //       changePage(value);
    //     }
    //   },
    // );
    _pageController.addListener(
      () {
        setState(() {
          pageValue = _pageController.page ?? 0;
        });
      },
    );
    childs = [
      KeepAlivePage(ProjectTab(
        scrollController: ScrollController(),
      )),
      _userStore.user!.type == UserType.company
          ? KeepAlivePage(DashBoardTab(
              pageController: _pageController,
            ))
          : KeepAlivePage(StudentDashBoardTab(pageController: _pageController)),
      const KeepAlivePage(MessageTab()),
      const KeepAlivePage(AlertTab())
    ];
    List<ScrollController> sc = [
      for (int i = 0; i < 4; i++) ScrollController()
    ];
    for (var element in sc) {
      element.addListener(
          () {
            if (element.position.userScrollDirection ==
                ScrollDirection.reverse) {
              NavbarNotifier2.hideBottomNavBar = true;
            } else {
              NavbarNotifier2.hideBottomNavBar = false;
            }
          },
        );
    }
    _routes = [
      {
        '/': KeepAlivePage(ProjectTab(
          key: const PageStorageKey(0),
          scrollController: sc[0],
        )),
        Routes.favortieProject: getRoute(Routes.favortieProject, context),
      },
      {
        '/': _userStore.user!.type == UserType.company
            ? KeepAlivePage(DashBoardTab(
                key: const PageStorageKey(1),
                pageController: _pageController,
              ))
            : KeepAlivePage(StudentDashBoardTab(
                key: const PageStorageKey(1), pageController: _pageController)),
        // Routes.projectDetails: ProjectDetailsPage(
        //   project: Project(title: 'som', description: 'smm'),
        // ),
        // Routes.project_post: getRoute(Routes.project_post),
      },
      {
        '/': const KeepAlivePage(MessageTab(
          key: PageStorageKey(2),
        )),

        // ProfileEdit.route: ProfileEdit(),
      },
      {
        '/': const KeepAlivePage(AlertTab(
          key: PageStorageKey(3),
        )),
      },
    ];

    super.initState();
  }

  // void changePage(int newPage) {
  //   setState(() {
  //     currentPage = newPage;
  //   });
  // }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  List<Widget> childs = [];
  List<NavbarItem> items = [];
  List<Map<String, Widget>> _routes = [];
  DateTime oldTime = DateTime.now();
  final _pageController2 = IndexController();
  final _pageController = PageController(initialPage: 1);
  final LanguageStore _languageStore = getIt<LanguageStore>();
  // late int currentPage;
  // late TabController tabController;
  final List<Color> colors = [
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.pink
  ];
  int selectedIndex = 0;
  final bool _colorful = false;
  void onButtonPressed(int index) {
    if (index == selectedIndex) {
      if (index == 1) {
        _pageController.jumpToPage(selectedIndex);
        return;
      }
    }
    if ((index - selectedIndex).abs() > 1) {
      setState(() {
        selectedIndex = index;
      });
      _pageController.jumpToPage(selectedIndex);
      return;
    }
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  double pageValue = 0;
  //scale factor
  final double _scaleFactor = .8;
  //view page height
  final double _height = 230.0;

  // @override
  // void didUpdateWidget(covariant DashBoardScreen oldWidget) {
  //   if (lastLocale != _languageStore.locale) {
  //     //initItems();
  //     print("change locale");
  //     lastLocale = _languageStore.locale;
  //     // _routes = [
  //     //   ..._routes.sublist(0, NavbarNotifier2.currentIndex),
  //     //   ...List.from(_routes.mapIndexed((i, e) {
  //     //     if (i == NavbarNotifier2.currentIndex) return e;
  //     //   })),
  //     //   ..._routes.sublist(
  //     //       (NavbarNotifier2.currentIndex + 1)
  //     //           .clamp(0, NavbarNotifier2.length - 1),
  //     //       NavbarNotifier2.length)
  //     // ];
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  initItems() {
    // _routes = [
    //   {
    //     '/': KeepAlivePage(ProjectTab(
    //       key: const PageStorageKey(0),
    //       scrollController: ScrollController(),
    //     )),
    //     Routes.favortieProject: getRoute(Routes.favortieProject, context),
    //   },
    //   {
    //     '/': _userStore.user!.type == UserType.company
    //         ? KeepAlivePage(DashBoardTab(
    //             key: const PageStorageKey(1),
    //             pageController: _pageController,
    //           ))
    //         : KeepAlivePage(StudentDashBoardTab(
    //             key: const PageStorageKey(1), pageController: _pageController)),
    //     // Routes.projectDetails: ProjectDetailsPage(
    //     //   project: Project(title: 'som', description: 'smm'),
    //     // ),
    //     // Routes.project_post: getRoute(Routes.project_post),
    //   },
    //   {
    //     '/': const KeepAlivePage(MessageTab(
    //       key: PageStorageKey(2),
    //     )),
    //     // ProfileEdit.route: ProfileEdit(),
    //   },
    //   {
    //     '/': const KeepAlivePage(AlertTab(
    //       key: PageStorageKey(3),
    //     )),
    //   },
    // ];
    items = [
      NavbarItem(
        Icons.business,
        'Projects',
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      NavbarItem(
        Icons.dashboard,
        'Dashboard',
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      NavbarItem(
        Icons.message,
        Lang.get('Dashboard_message'),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      NavbarItem(
        Icons.notifications,
        Lang.get('Dashboard_alert'),
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('check ${_userStore.user!.email} ${_userStore.user!.type.name}');
    // if (items.isEmpty || lastLocale != _languageStore.locale) {
    initItems();
    // print("change locale" + lastLocale);
    lastLocale = _languageStore.locale;
    // }
// final Color unselectedColor = colors[currentPage].computeLuminance() < 0.5
    //     ? Colors.black
    //     : Colors.white;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body:
          //   Padding(
          //     padding: const EdgeInsets.all(30.0),
          //     child: _selectedIndex == 0
          //         ? _buildProjectContent()
          //         : _selectedIndex == 1
          //             ? _buildDashBoardContent()
          //             : _selectedIndex == 2
          //                 ? _buildMessageContent()
          //                 : _buildAlertContent(),
          //   ),
          //   bottomNavigationBar: BottomNavigationBar(
          //     showUnselectedLabels: true,
          //     selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
          //     unselectedLabelStyle: TextStyle(
          //         color: Theme.of(context).colorScheme.onSurface,
          //         fontSize: 12,
          //         fontWeight: FontWeight.w200),
          //     unselectedIconTheme:
          //         IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          //     items: <BottomNavigationBarItem>[
          //       BottomNavigationBarItem(
          //         icon: const Icon(Icons.business),
          //         label: 'Projects',
          //         backgroundColor: Theme.of(context).colorScheme.primary,
          //       ),
          //       BottomNavigationBarItem(
          //         icon: const Icon(Icons.dashboard),
          //         label: 'Dashboard',
          //         backgroundColor: Theme.of(context).colorScheme.primary,
          //       ),
          //       BottomNavigationBarItem(
          //         icon: const Icon(Icons.message),
          //         label: 'Message',
          //         backgroundColor: Theme.of(context).colorScheme.primary,
          //       ),
          //       BottomNavigationBarItem(
          //         icon: const Icon(Icons.notifications),
          //         label: 'Alerts',
          //         backgroundColor: Theme.of(context).colorScheme.primary,
          //       ),
          //     ],
          //     currentIndex: _selectedIndex,
          //     unselectedItemColor: Theme.of(context).colorScheme.background,
          //     onTap: _onItemTapped,
          //   ),
          // );

          // body: PageView.builder(
          //   controller: _pageController,
          //   onPageChanged: (value) {
          //     onButtonPressed(value);
          //   },
          //   itemCount: childs.length,
          //   itemBuilder: (context, index) {
          //     final _transformer = ScaleAndFadeTransformer();
          //     return AnimatedBuilder(
          //       animation: _pageController,
          //       builder: (BuildContext c, Widget? w) {
          //         final renderIndex = selectedIndex;

          //         double position;

          //         final page = pageValue;

          //         if (selectedIndex < index) {
          //           position = page - index;
          //         } else {
          //           position = index - page;
          //         }
          //         position *= 0.8;

          //         final info = TransformInfo(
          //           index: renderIndex,
          //           position: position.clamp(-1.0, 1.0),
          //           forward: _pageController.position.pixels >= 0,
          //         );
          //         return _transformer.transform(childs[index], info);
          //       },
          //     );
          // Matrix4 matrix = new Matrix4.identity();

          // if (index == pageValue.floor()) {
          //   var currScale = 1 - (pageValue - index) * (1 - _scaleFactor);
          //   var currTrans = _height * (1 - currScale) / 2;
          //   matrix = Matrix4.diagonal3Values(1.0, currScale, 1.0)
          //     ..setTranslationRaw(0, currTrans, 0);
          // } else if (index == pageValue.floor() + 1) {
          //   var currScale =
          //       _scaleFactor + (pageValue - index + 1) * (1 - _scaleFactor);
          //   var currTrans = _height * (1 - currScale) / 2;
          //   matrix = Matrix4.diagonal3Values(1.0, currScale, 1.0)
          //     ..setTranslationRaw(0, currTrans, 0);
          // } else if (index == pageValue.floor() - 1) {
          //   var currScale = 1 - (pageValue - index) * (1 - _scaleFactor);
          //   var currTrans = _height * (1 - currScale) / 2;
          //   matrix = Matrix4.diagonal3Values(1.0, currScale, 1.0)
          //     ..setTranslationRaw(0, currTrans, 0);
          // } else {
          //   var currScale = 0.8;
          //   matrix = Matrix4.diagonal3Values(1.0, currScale, 1.0)
          //     ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 0);
          // }
          // return Transform(transform: matrix, child: childs[index]);
          //     return childs[index];
          //   },
          // ),
          // bottomNavigationBar: _colorful
          //     ? SlidingClippedNavBar.colorful(
          //         backgroundColor: Theme.of(context).colorScheme.primary,
          //         onButtonPressed: onButtonPressed,
          //         iconSize: 30,
          //         // activeColor: const Color(0xFF01579B),
          //         selectedIndex: selectedIndex,
          //         barItems: <BarItem>[
          //           BarItem(
          //             icon: Icons.event,
          //             title: 'Events',
          //             activeColor: Colors.blue,
          //             inactiveColor: Colors.orange,
          //           ),
          //           BarItem(
          //             icon: Icons.search_rounded,
          //             title: Lang.get("Message_bar"),
          //             activeColor: Colors.yellow,
          //             inactiveColor: Colors.green,
          //           ),
          //           BarItem(
          //             icon: Icons.bolt_rounded,
          //             title: 'Energy',
          //             activeColor: Colors.blue,
          //             inactiveColor: Colors.red,
          //           ),
          //           BarItem(
          //             icon: Icons.tune_rounded,
          //             title: 'Settings',
          //             activeColor: Colors.cyan,
          //             inactiveColor: Colors.purple,
          //           ),
          //         ],
          //       )
          // : SlidingClippedNavBar(
          //     backgroundColor: Colors.white,
          //     onButtonPressed: onButtonPressed,
          //     iconSize: 30,
          //     activeColor: const Color(0xFF01579B),
          //     selectedIndex: selectedIndex,
          //     barItems: <BarItem>[
          //       BarItem(
          //         icon: Icons.event,
          //         title: 'Events',
          //       ),
          //       BarItem(
          //         icon: Icons.search_rounded,
          //         title: Lang.get("Message_bar"),
          //       ),
          //       BarItem(
          //         icon: Icons.bolt_rounded,
          //         title: 'Energy',
          //       ),
          //       BarItem(
          //         icon: Icons.tune_rounded,
          //         title: 'Settings',
          //       ),
          //     ],
          //   ),

          NavbarRouter2(
        pageController: _pageController2,
        initialIndex: 1,
        backButtonBehavior: BackButtonBehavior.rememberHistory,
        errorBuilder: (context) {
          return const Center(child: Text('Dev: Navbar build failed'));
        },
        onCurrentTabClicked: () {
          setState(() {
            for (var element in allProjects) {
              element.isLoading = true;
            }
          });
        },
        onChanged: (p0) {
          // setState(() {});
          NavbarNotifier2.hideBottomNavBar = false;
        },
        onBackButtonPressed: (isExiting) {
          if (isExiting) {
            var newTime = DateTime.now();
            int difference = newTime.difference(oldTime).inMilliseconds;
            oldTime = newTime;
            if (difference < 1000) {
              NavbarNotifier2.hideSnackBar(context);
              return true;
            } else {
              NavbarNotifier2.showSnackBar(
                context,
                Lang.get("exit_confirm"),

                /// offset from bottom of the screen
                ///
              );
              oldTime = DateTime.now();
              return false;
            }
          } else {
            return isExiting;
          }
        },
        destinationAnimationCurve: Curves.fastOutSlowIn,
        destinationAnimationDuration: 200,
        decoration:
            NavbarDecoration(navbarType: BottomNavigationBarType.shifting),
        destinations: [
          for (int i = 0; i < items.length; i++)
            DestinationRouter(
              navbarItem: items[i],
              destinations: [
                for (int j = 0; j < _routes[i].keys.length; j++)
                  Destination(
                    route: _routes[i].keys.elementAt(j),
                    widget: _routes[i].values.elementAt(j),
                  ),
              ],
              initialRoute: _routes[i].keys.first,
            ),
        ],
      ),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return MainAppBar(
      theme: true,
      name: _userStore.user != null ? _userStore.user!.name : "",
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  const KeepAlivePage(this.child, {super.key});
  final Widget child;

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // To keep the state alive
    return widget.child;
  }
}
