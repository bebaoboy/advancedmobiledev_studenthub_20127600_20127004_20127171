import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/searchbar_widget.dart';
import 'package:boilerplate/utils/classes.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route_navbar.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class DashBoardTab extends StatefulWidget {
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
}

class SearchBottomSheet extends StatelessWidget {
  SearchBottomSheet({this.onSheetDismissed});
  TextEditingController controller = TextEditingController();
  final onSheetDismissed;
  var allProjects = [
    Project(title: "ABC", description: "description"),
    Project(title: "XYZ", description: "description"),
    Project(title: "JKMM", description: "description"),
    Project(title: "man bhsk p", description: "description"),
    Project(title: "jOa josfj á ", description: "description"),
  ];

  @override
  Widget build(BuildContext context) {
    // SheetContentScaffold is a special Scaffold designed for use in a sheet.
    // It has slots for an app bar and a sticky bottom bar, similar to Scaffold.
    // However, it differs in that its height reduces to fit the 'body' widget.
    final content = SheetContentScaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      // The bottom bar sticks to the bottom unless the sheet extent becomes
      // smaller than this threshold extent.
      requiredMinExtentForStickyBottomBar: const Extent.proportional(0.5),
      // With the following configuration, the sheet height will be
      // 500px + (app bar height) + (bottom bar height).
      body: Container(
        height: 550,
        child: Align(
          alignment: Alignment.topCenter,
          // child:
          // AnimationSearchBar(
          //   onSelected: (project) {
          //     print(project.title);
          //   },
          //   onSuggestionCallback: (pattern) {
          //     return Future<List<Project>>.delayed(
          //       Duration(milliseconds: 300),
          //       () => allProjects.where((product) {
          //         final nameLower =
          //             product.title.toLowerCase().split(' ').join('');
          //         print(nameLower);
          //         final patternLower =
          //             pattern.toLowerCase().split(' ').join('');
          //         return nameLower.contains(patternLower);
          //       }).toList(),
          //     );
          //   },
          //   suggestionItemBuilder: (context, project) => ListTile(
          //     title: Text(project.title),
          //     subtitle: Text(project.description),
          //   ),

          //   ///! Required
          //   onChanged: (text) => debugPrint(text),
          //   searchTextEditingController: controller,

          //   ///! Optional. For more customization
          //   //? Back Button
          //   backIcon: Icons.arrow_back_ios_new,
          //   backIconColor: Colors.black,
          //   isBackButtonVisible: false,
          //   previousScreen:
          //       null, // It will push and replace this screen when pressing the back button
          //   //? Close Button
          //   closeIconColor: Colors.black,
          //   //? Center Title
          //   centerTitle: ' ',
          //   hintText: 'Type here...',
          //   centerTitleStyle:
          //       const TextStyle(fontWeight: FontWeight.w500, fontSize: 13,),
          //   //? Search hint text
          //   hintStyle: const TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
          //   //? Search Text
          //   textStyle: const TextStyle(fontWeight: FontWeight.w300),
          //   //? Cursor color
          //   cursorColor: Colors.lightBlue.shade300,
          //   //? Duration
          //   duration: const Duration(milliseconds: 300),
          //   //? Height, Width & Padding
          //   searchFieldHeight: 35, // Total height of the search field
          //   searchBarHeight: 50, // Total height of this Widget
          //   searchBarWidth: MediaQuery.of(context).size.width -
          //       20, // Total width of this Widget
          //   horizontalPadding: 10,
          //   verticalPadding: 0,
          //   //? Search icon color
          //   searchIconColor: Colors.black.withOpacity(.7),
          //   //? Search field background decoration
          //   searchFieldDecoration: BoxDecoration(
          //       border:
          //           Border.all(color: Colors.black.withOpacity(.2), width: .5),
          //       borderRadius: BorderRadius.circular(15)),
          // ),
        ),
      ),
      appBar: buildAppBar(context),
      bottomBar: buildBottomBar(),
    );

    final physics = StretchingSheetPhysics(
      parent: SnappingSheetPhysics(
        snappingBehavior: SnapToNearest(
          snapTo: [
            const Extent.proportional(0.2),
            const Extent.proportional(0.5),
            const Extent.proportional(0.8),
            const Extent.proportional(1),
          ],
        ),
      ),
    );

    return DraggableSheet(
      physics: physics,
      keyboardDismissBehavior:
          SheetKeyboardDismissBehavior.onDrag(isContentScrollAware: true),
      minExtent: const Extent.pixels(0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      // title: const Text('Search projects'),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      actions: [
        AnimSearchBar2(
          textFieldColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.surface,
          onSubmitted: (p0) {},
          width: MediaQuery.of(context).size.width,
          textController: controller,
          onSuffixTap: () {},
          onSelected: (project) {
            print(project.title);
          },
          searchTextEditingController: controller,
          onSuggestionCallback: (pattern) {
            if (pattern.isEmpty) return [];
            return Future<List<Project>>.delayed(
              Duration(milliseconds: 300),
              () => allProjects.where((product) {
                final nameLower =
                    product.title.toLowerCase().split(' ').join('');
                print(nameLower);
                final patternLower = pattern.toLowerCase().split(' ').join('');
                return nameLower.contains(patternLower);
              }).toList(),
            );
          },
          suggestionItemBuilder: (context, project) => ListTile(
            title: Text(project.title),
            subtitle: Text(project.description),
          ),
        ),

        // IconButton(
        //     onPressed: () {
        //       onSheetDismissed();
        //     },
        //     icon: Icon(Icons.expand_more))
      ],
    );
  }

  Widget buildBottomBar() {
    return BottomAppBar(
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: TextButton(
              onPressed: () {
                onSheetDismissed();
              },
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            fit: FlexFit.tight,
            child: FilledButton(
              onPressed: () {
                onSheetDismissed();
              },
              child: const Text('OK'),
            ),
          )
        ],
      ),
    );
  }
}

class ProjectTab extends StatefulWidget {
  @override
  State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
  @override
  Widget build(BuildContext context) {
    return _buildProjectContent();
  }

  Future<SearchBottomSheet?> showTodoEditor(BuildContext context) {
    return Navigator.push(
      context,
      ModalSheetRoute(
        builder: (context) => SearchBottomSheet(),
      ),
    );
  }

  double yOffset = 0;

  Widget _buildProjectContent() {
    if (yOffset == 0) {
      yOffset = MediaQuery.of(context).size.height;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Text("This is project page"),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.search,
                size: 35, color: Colors.black ?? Colors.black.withOpacity(.7)),
            onPressed: () {
              // showTodoEditor(context);
              setState(() {
                if (yOffset == MediaQuery.of(context).size.height) {
                  NavbarNotifier2.hideBottomNavBar = true;
                  yOffset = -(MediaQuery.of(context).size.height) * 0.05 + 45;
                } else {
                  NavbarNotifier2.hideBottomNavBar = false;
                  yOffset = MediaQuery.of(context).size.height;
                }
              });
            },
          ),
        ),
        SizedBox(
          height: 100,
        ),
        Flexible(
            fit: FlexFit.loose,
            child: AnimatedContainer(
                curve: Easing.legacyAccelerate,
                // color: Colors.amber,
                alignment: Alignment.bottomCenter,
                duration: Duration(milliseconds: 300),
                transform: Matrix4.translationValues(0, yOffset, -1.0),
                child: SearchBottomSheet(onSheetDismissed: () {
                  setState(() {
                    NavbarNotifier2.hideBottomNavBar = false;
                    yOffset = MediaQuery.of(context).size.height;
                  });
                  final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
                  return true;
                }))),
      ],
    );
  }
}

class MessageTab extends StatefulWidget {
  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  @override
  Widget build(BuildContext context) {
    return _buildMessageContent();
  }

  Widget _buildMessageContent() {
    return const Column(
      children: <Widget>[
        Text("This is message page"),
      ],
    );
  }
}

class AlertTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildAlertContent();
  }

  Widget _buildAlertContent() {
    return const Column(
      children: <Widget>[
        Text("This is alert page"),
      ],
    );
  }
}

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
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      ];
      _routes = {
        0: {
          '/': ProjectTab(),
          // FeedDetail.route: FeedDetail(),
        },
        1: {
          '/': DashBoardTab(),
          // ProductDetail.route: ProductDetail(),
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
        backButtonBehavior: BackButtonBehavior.rememberHistory,
        errorBuilder: (context) {
          return const Center(child: Text('Error 404'));
        },
        onCurrentTabClicked: () {
          setState(() {});
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

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return MainAppBar();
  }
}
