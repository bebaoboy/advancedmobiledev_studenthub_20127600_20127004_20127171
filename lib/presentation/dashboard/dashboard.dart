import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route_navbar.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

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
          'Message',
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        NavbarItem(
          Icons.notifications,
          'Alerts',
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      ];
      _routes = {
        0: {
          '/': _buildProjectContent(),
          // FeedDetail.route: FeedDetail(),
        },
        1: {
          '/': _buildDashBoardContent(),
          // ProductDetail.route: ProductDetail(),
        },
        2: {
          '/': _buildMessageContent(),
          // ProfileEdit.route: ProfileEdit(),
        },
        3: {
          '/': _buildAlertContent(),
        },
      };
    }
    return Scaffold(
      appBar: _buildAppBar(),
      //   body: Padding(
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
      //
      body: NavbarRouter2(
        backButtonBehavior: BackButtonBehavior.rememberHistory,
        errorBuilder: (context) {
          return const Center(child: Text('Error 404'));
        },
        onBackButtonPressed: (isExiting) {
          if (isExiting) {
            var newTime = DateTime.now();
            int difference = newTime.difference(oldTime).inMilliseconds;
            oldTime = newTime;
            if (difference < 1000) {
              NavbarNotifier.hideSnackBar(context);
              return true;
            } else {
              NavbarNotifier.showSnackBar(
                context,
                "This is shown on top of the Floating Action Button",

                /// offset from bottom of the screen
                /// 
              );
              oldTime = DateTime.now();
              return false;
            }
          } else
            return isExiting;
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

  Widget _buildDashBoardContent() {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                  AppLocalizations.of(context).translate('Dashboard_your_job')),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 100,
                height: 30,
                child: FloatingActionButton(
                  heroTag: "F3",
                  onPressed: () {},
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
        const SizedBox(
          height: 34,
        ),
        Align(
          alignment: Alignment.center,
          child:
              Text(AppLocalizations.of(context).translate('Dashboard_intro')),
        ),
        Align(
          alignment: Alignment.center,
          child:
              Text(AppLocalizations.of(context).translate('Dashboard_content')),
        ),
      ],
    );
  }

  Widget _buildProjectContent() {
    return const Column(
      children: <Widget>[
        Text("This is project page"),
      ],
    );
  }

  Widget _buildMessageContent() {
    return const Column(
      children: <Widget>[
        Text("This is message page"),
      ],
    );
  }

  Widget _buildAlertContent() {
    return const Column(
      children: <Widget>[
        Text("This is alert page"),
      ],
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return MainAppBar();
  }
}
