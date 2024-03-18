import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/project/mockData.dart';
import 'package:boilerplate/presentation/dashboard/alert_tab.dart';
import 'package:boilerplate/presentation/dashboard/dashboard_tab.dart';
import 'package:boilerplate/presentation/dashboard/message_tab.dart';
import 'package:boilerplate/presentation/dashboard/project_tab.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route_navbar.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

// ---------------------------------------------------------------------------
class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<NavbarItem> items = [];
  Map<int, Map<String, Widget>> _routes = {};
  DateTime oldTime = DateTime.now();
  final  _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
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
          AppLocalizations.of(context).translate('Dashboard_message'),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        NavbarItem(
          Icons.notifications,
          AppLocalizations.of(context).translate('Dashboard_alert'),
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
      ];
      _routes = {
        0: {
          '/': ProjectTab(),
          Routes.favortie_project: getRoute(Routes.favortie_project, context),
        },
        1: {
          '/': DashBoardTab(pageController: _pageController,),
          // Routes.projectDetails: ProjectDetailsPage(
          //   project: Project(title: 'som', description: 'smm'),
          // ),
          // Routes.project_post: getRoute(Routes.project_post),
        },
        2: {
          '/': MessageTab(),
          // ProfileEdit.route: ProfileEdit(),
        },
        3: {
          '/': AlertTab(),
        },
      };
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      // body: Padding(
      //   padding: const EdgeInsets.all(30.0),
      //   child: _selectedIndex == 0
      //       ? _buildProjectContent()
      //       : _selectedIndex == 1
      //           ? _buildDashBoardContent()
      //           : _selectedIndex == 2
      //               ? _buildMessageContent()
      //               : _buildAlertContent(),
      // ),
      // bottomNavigationBar: BottomNavigationBar(
      //   showUnselectedLabels: true,
      //   selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
      //   unselectedLabelStyle: TextStyle(
      //       color: Theme.of(context).colorScheme.onSurface,
      //       fontSize: 12,
      //       fontWeight: FontWeight.w200),
      //   unselectedIconTheme:
      //       IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      //   items: <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: const Icon(Icons.business),
      //       label: 'Projects',
      //       backgroundColor: Theme.of(context).colorScheme.primary,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: const Icon(Icons.dashboard),
      //       label: 'Dashboard',
      //       backgroundColor: Theme.of(context).colorScheme.primary,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: const Icon(Icons.message),
      //       label: 'Message',
      //       backgroundColor: Theme.of(context).colorScheme.primary,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: const Icon(Icons.notifications),
      //       label: 'Alerts',
      //       backgroundColor: Theme.of(context).colorScheme.primary,
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   unselectedItemColor: Theme.of(context).colorScheme.background,
      //   onTap: _onItemTapped,
      // ),

      body: NavbarRouter2(
        pageController: _pageController,
        initialIndex: 1,
        backButtonBehavior: BackButtonBehavior.rememberHistory,
        errorBuilder: (context) {
          return const Center(child: Text('Error 404'));
        },
        onCurrentTabClicked: () {
          setState(() {
            allProjects.forEach((element) {
              element.isLoading = true;
            });
          });
        },
        onChanged: (p0) {
          setState(() {});
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
                "Press Back again to exit",

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
                for (int j = 0; j < _routes[i]!.keys.length; j++)
                  Destination(
                    route: _routes[i]!.keys.elementAt(j),
                    widget: _routes[i]!.values.elementAt(j),
                  ),
              ],
              initialRoute: _routes[i]!.keys.first,
            ),
        ],
      ),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return const MainAppBar();
  }
}
