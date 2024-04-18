// ignore_for_file: unused_field

import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/alert_tab.dart';
import 'package:boilerplate/presentation/dashboard/dashboard_tab.dart';
import 'package:boilerplate/presentation/dashboard/message_tab.dart';
import 'package:boilerplate/presentation/dashboard/project_tab.dart';
import 'package:boilerplate/presentation/dashboard/student_dashboard_tab.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route_navbar.dart';
import 'package:boilerplate/utils/routes/navbar_item.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/navbar_router.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';

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
  late List<ScrollController> sc;

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
    sc = [for (int i = 0; i < 4; i++) ScrollController()];
    for (var element in sc) {
      element.addListener(
        () {
          if (kIsWeb || MediaQuery.of(context).size.width > 600) return;
          if (element.position.userScrollDirection == ScrollDirection.reverse) {
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
        Routes.favoriteProject: getRoute(Routes.favoriteProject, context),
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
        '/': KeepAlivePage(MessageTab(
          key: const PageStorageKey(2),
          scrollController: sc[2],
        )),

        // ProfileEdit.route: ProfileEdit(),
      },
      {
        '/': KeepAlivePage(AlertTab(
          key: const PageStorageKey(3),
          scrollController: sc[3],
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

  initItems() {
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
    // lastLocale = _languageStore.locale;
    // }
// final Color unselectedColor = colors[currentPage].computeLuminance() < 0.5
    //     ? Colors.black
    //     : Colors.white;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: NavbarRouter2(
        pageController: _pageController2,
        initialIndex: 1,
        backButtonBehavior: BackButtonBehavior.rememberHistory,
        errorBuilder: (context) {
          return Center(
              child: GestureDetector(
                  onTap: () => setState(() {}),
                  child: const Text('Failed to render. Tap to retry.')));
        },
        isDesktop: MediaQuery.of(context).size.width > 600 ? true : false,
        decoration: NavbarDecoration(
            isExtended: MediaQuery.of(context).size.width > 800 ? true : false,
            navbarType: BottomNavigationBarType.shifting),
        onCurrentTabClicked: () {
          setState(() {
            for (var element in sc) {
              try {
                element.animateTo(
                  element.position.minScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                );
                // element.jumpTo(element.position.minScrollExtent);
              } catch (e) {
                ///
              }
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
