// ignore_for_file: overridden_fields, must_be_immutable

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:boilerplate/presentation/dashboard/favorite_project.dart';
import 'package:boilerplate/utils/routes/navbar_item.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/navbar_router.dart';
import 'package:boilerplate/utils/routes/page_transformer.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

import 'package:flutter/foundation.dart';

const double kM3NavbarHeight = kBottomNavigationBarHeight;
const double kStandardNavbarHeight = kBottomNavigationBarHeight;
const double kNotchedNavbarHeight = kBottomNavigationBarHeight * 1.45;
const double kFloatingNavbarHeight = 60.0;

/// The height of the navbar based on the [NavbarType]
double kNavbarHeight = 0.0;

enum NavbarType { standard, notched, material3, floating }

class AnimatedNavBar extends StatefulWidget {
  const AnimatedNavBar(
      {super.key,
      this.decoration,
      required this.model,
      this.isDesktop = false,
      this.navbarType = NavbarType.standard,
      required this.menuItems,
      required this.onItemTapped});
  final List<NavbarItem> menuItems;
  final NavbarNotifier2 model;
  final Function(int) onItemTapped;
  final bool isDesktop;
  final NavbarType navbarType;
  final NavbarDecoration? decoration;

  @override
  _AnimatedNavBarState createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant AnimatedNavBar oldWidget) {
    if (NavbarNotifier2.isNavbarHidden != isHidden) {
      if (!isHidden) {
        _showBottomNavBar();
      } else {
        _hideBottomNavBar();
      }
      isHidden = !isHidden;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _hideBottomNavBar() {
    if (!widget.isDesktop) {
      _controller.reverse();
    }
    return;
  }

  void _showBottomNavBar() {
    if (!widget.isDesktop) {
      _controller.forward();
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
            duration: const Duration(milliseconds: 200), vsync: this)
        // ..addListener(() => setState(() {}))
        ;
    animation = Tween(begin: 0.0, end: 100.0).animate(_controller);
  }

  late AnimationController _controller;
  late Animation<double> animation;
  bool isHidden = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultDecoration = NavbarDecoration(
        borderRadius: BorderRadius.circular(20.0),
        selectedIconColor: theme.bottomNavigationBarTheme.selectedItemColor,
        margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
            theme.colorScheme.surface,
        elevation: 8,
        height: kBottomNavigationBarHeight,
        showUnselectedLabels: true,
        unselectedIconColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        unselectedLabelColor:
            theme.bottomNavigationBarTheme.unselectedItemColor ??
                theme.primaryColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        unselectedLabelTextStyle:
            theme.bottomNavigationBarTheme.unselectedLabelStyle ??
                const TextStyle(color: Colors.black),
        unselectedIconTheme: theme.iconTheme.copyWith(color: Colors.black),
        selectedIconTheme: theme.iconTheme,
        selectedLabelTextStyle:
            theme.bottomNavigationBarTheme.selectedLabelStyle,
        enableFeedback: true,
        isExtended: true,
        indicatorShape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
                color: Colors.transparent, style: BorderStyle.none, width: 1)),
        navbarType: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: theme.colorScheme.onBackground);

    NavbarDecoration navigationRailDefaultDecoration = NavbarDecoration(
      backgroundColor: theme.navigationRailTheme.backgroundColor ??
          theme.colorScheme.surface,
      elevation: theme.navigationRailTheme.elevation,
      showUnselectedLabels: true,
      selectedIconTheme: theme.navigationRailTheme.selectedIconTheme,
      enableFeedback: true,
      isExtended: true,
      unselectedIconTheme: theme.navigationRailTheme.unselectedIconTheme,
      selectedLabelTextStyle: theme.navigationRailTheme.selectedLabelTextStyle,
      unselectedLabelTextStyle:
          theme.navigationRailTheme.unselectedLabelTextStyle,
      indicatorShape: theme.navigationRailTheme.indicatorShape,
      indicatorColor: theme.navigationRailTheme.indicatorColor,
      navbarType: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    );

    // final foregroundColor =
    //     defaultDecoration.backgroundColor!.computeLuminance() > 0.5
    //         ? Colors.black
    //         : Colors.white;

    NavbarBase buildNavBar() {
      switch (widget.navbarType) {
        case NavbarType.standard:
          kNavbarHeight = kBottomNavigationBarHeight;
          return StandardNavbar(
            index: NavbarNotifier2.currentIndex,
            navbarHeight: kBottomNavigationBarHeight,
            navBarDecoration: widget.decoration ?? defaultDecoration,
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            navBarElevation: widget.decoration?.elevation,
          );

        default:
          return StandardNavbar(
            navBarDecoration: widget.decoration!,
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            navBarElevation: widget.decoration!.elevation,
          );
      }
    }

    Widget buildNavigationRail() {
      // TODO: change width cua navbar + baclground + selected color
      if (widget.decoration != null) {
        navigationRailDefaultDecoration =
            navigationRailDefaultDecoration.copyWith(
          isExtended: widget.decoration!.isExtended,
          enableFeedback: widget.decoration!.enableFeedback,
          backgroundColor: widget.decoration!.backgroundColor ??
              theme.colorScheme.primaryContainer.withOpacity(0.5),
          elevation: widget.decoration!.elevation ??
              theme.navigationRailTheme.elevation,
          selectedIconTheme: widget.decoration!.selectedIconTheme ??
              theme.iconTheme.copyWith(color: theme.colorScheme.primary),
          indicatorColor: widget.decoration!.indicatorColor ??
              theme.colorScheme.secondaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorShape: widget.decoration!.indicatorShape,
          selectedLabelTextStyle: widget.decoration!.selectedLabelTextStyle ??
              theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
        );
      }

      return NavigationRail(
          minWidth: 40,
          minExtendedWidth: 140,
          elevation: navigationRailDefaultDecoration.elevation,
          onDestinationSelected: (x) {
            widget.onItemTapped(x);
          },
          useIndicator: true,
          indicatorColor: navigationRailDefaultDecoration.indicatorColor ??
              theme.colorScheme.secondaryContainer,
          indicatorShape: navigationRailDefaultDecoration.indicatorShape,
          selectedLabelTextStyle:
              navigationRailDefaultDecoration.selectedLabelTextStyle,
          unselectedLabelTextStyle:
              navigationRailDefaultDecoration.unselectedLabelTextStyle,
          unselectedIconTheme:
              navigationRailDefaultDecoration.unselectedIconTheme,
          selectedIconTheme:
              navigationRailDefaultDecoration.selectedIconTheme ??
                  theme.iconTheme.copyWith(color: theme.colorScheme.primary),
          extended: navigationRailDefaultDecoration.isExtended,
          backgroundColor: navigationRailDefaultDecoration.backgroundColor ??
              theme.colorScheme.secondary,
          destinations:
              widget.menuItems.mapIndexed((int i, NavbarItem menuItem) {
            return NavigationRailDestination(
              icon: buildBadge(i, Icon(menuItem.iconData)),
              label: Text(menuItem.text),
            );
          }).toList(),
          selectedIndex: NavbarNotifier2.currentIndex);
    }

    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
              offset: widget.isDesktop
                  ? Offset(-animation.value, 0)
                  : Offset(0, animation.value),
              child: widget.isDesktop ? buildNavigationRail() : buildNavBar());
        });
  }
}

/// Function to build badges, using index and child from the [NavbarNotifier.badges] list (given by user)
Widget buildBadge(
  /// Current index of the navbar
  int index,

  /// The navbar icon
  Widget child,
) {
  return badges.Badge(
    key: NavbarNotifier2.badges[index].key,
    position: NavbarNotifier2.badges[index].position ??
        (NavbarNotifier2.badges[index].badgeText.isNotEmpty
            ? badges.BadgePosition.topEnd(top: -15, end: -15)
            : badges.BadgePosition.topEnd()),
    badgeAnimation: NavbarNotifier2.badges[index].badgeAnimation ??
        const badges.BadgeAnimation.slide(
            // disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
            // curve: Curves.easeInCubic,
            ),
    ignorePointer: NavbarNotifier2.badges[index].ignorePointer,
    stackFit: NavbarNotifier2.badges[index].stackFit,
    onTap: NavbarNotifier2.badges[index].onTap,
    showBadge: NavbarNotifier2.badges[index].showBadge,
    badgeStyle: badges.BadgeStyle(
      badgeColor: NavbarNotifier2.badges[index].color ?? Colors.white,
    ),
    badgeContent: NavbarNotifier2.badges[index].badgeContent ??
        Text(
          NavbarNotifier2.badges[index].badgeText,
          style: NavbarNotifier2.badges[index].badgeTextStyle ??
              TextStyle(
                  color:
                      NavbarNotifier2.badges[index].textColor ?? Colors.black,
                  fontSize: 9),
        ),
    child: child,
  );
}

abstract class NavbarBase extends StatefulWidget {
  const NavbarBase({super.key});
  NavbarDecoration get decoration;

  double? get elevation;

  Function(int)? get onItemTapped;

  List<NavbarItem> get menuItems;

  double get height;
}

class StandardNavbar extends NavbarBase {
  const StandardNavbar(
      {super.key,
      required this.navBarDecoration,
      required this.navBarElevation,
      required this.onTap,
      this.navbarHeight,
      this.index = 0,
      required this.items});

  final List<NavbarItem> items;
  final Function(int) onTap;
  final NavbarDecoration navBarDecoration;
  final double? navBarElevation;
  final int index;
  final double? navbarHeight;

  @override
  StandardNavbarState createState() => StandardNavbarState();

  @override
  NavbarDecoration get decoration => navBarDecoration;

  @override
  double? get elevation => navBarElevation;

  @override
  List<NavbarItem> get menuItems => items;

  @override
  Function(int p1)? get onItemTapped => onTap;

  @override
  double get height => navbarHeight ?? kStandardNavbarHeight;
}

class StandardNavbarState extends State<StandardNavbar> {
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final items = widget.menuItems;
    return BottomNavigationBar(
        type: widget.decoration.navbarType,
        currentIndex: NavbarNotifier2.currentIndex,
        onTap: (x) {
          _selectedIndex = x;
          widget.onItemTapped!(x);
        },
        backgroundColor: widget.decoration.backgroundColor,
        showSelectedLabels: widget.decoration.showSelectedLabels,
        enableFeedback: widget.decoration.enableFeedback,
        showUnselectedLabels: widget.decoration.showUnselectedLabels,
        elevation: widget.decoration.elevation,
        iconSize: Theme.of(context).iconTheme.size ?? 24.0,
        unselectedItemColor: widget.decoration.unselectedItemColor,
        selectedItemColor: widget.decoration.selectedLabelTextStyle?.color,
        unselectedLabelStyle: widget.decoration.unselectedLabelTextStyle,
        selectedLabelStyle: widget.decoration.selectedLabelTextStyle,
        selectedIconTheme: widget.decoration.selectedIconTheme,
        unselectedIconTheme: widget.decoration.unselectedIconTheme,
        items: [
          for (int index = 0; index < items.length; index++)
            BottomNavigationBarItem(
              backgroundColor: items[index].backgroundColor,
              icon: _selectedIndex == index
                  ? buildBadge(
                      index,
                      items[index].selectedIcon ?? Icon(items[index].iconData),
                    )
                  : buildBadge(
                      index,
                      Icon(items[index].iconData),
                    ),
              label: items[index].text,
            )
        ]);
  }
}

class NavbarRouter2 extends NavbarRouter {
  /// The destination to show when the user taps the [NavbarItem]
  /// destination also defines the list of Nested destination sand the navbarItem associated with it
  @override
  final List<DestinationRouter> destinations;

  /// Route to show the user when the user tried to navigate to a route that
  /// does not exist in the [destinations]
  @override
  final WidgetBuilder errorBuilder;

  /// This callback is invoked, when the user taps the back button
  /// on Android.
  /// Defines whether it is the root Navigator or not
  /// if the method returns true then the Navigator is at the base of the navigator stack
  @override
  final bool Function(bool)? onBackButtonPressed;

  /// whether the navbar should pop to base route of current tab
  /// when the selected navbarItem is tapped all the routes from that navigator are popped.
  /// feature similar to Instagram's navigation bar
  /// defaults to true.
  @override
  final bool shouldPopToBaseRoute;

  /// AnimationDuration in milliseconds for the destination animation
  /// defaults to 300 milliseconds
  @override
  final int destinationAnimationDuration;

  /// defaults to Curves.fastOutSlowIn
  @override
  final Curve destinationAnimationCurve;

  /// The decoraton for Navbar has all the properties you would expect in a [BottomNavigationBar]
  /// to adjust the style of the Navbar.
  @override
  final NavbarDecoration? decoration;

  /// if true, navbar will be shown on the left, this property
  /// can be used along with `NavbarDecoration.isExtended` to make the navbar
  ///  adaptable for large screen sizes.
  /// defaults to false.
  @override
  final bool isDesktop;

  /// callback when the currentIndex changes
  @override
  final Function(int)? onChanged;

  // callback when the same tab is clicked
  @override
  final Function()? onCurrentTabClicked;

  /// The type of the [Navbar] that is to be rendered.
  /// defaults to [NavbarType.standard] which is a standard [BottomNavigationBar]
  ///
  /// Alternatively, you can use [NavbarType.notched] which is a Navbar with a notch
  ///
  /// Use appropriate [NavbarDecoration] for the type of [NavbarType] you are using.
  /// For
  /// NavbarType.standard use [NavbarDecoration]
  /// NavbarType.notched use [NotchedDecoration]
  @override
  final NavbarType type;

  /// Whether the back button pressed should pop the current route and switch to the previous route,
  /// defaults to true.
  /// if false, the back button will trigger app exit.
  /// This is applicable only for Android's back button.
  @override
  final BackButtonBehavior backButtonBehavior;

  /// Navbar item that is initially selected
  /// defaults to the first item in the list of [NavbarItems]
  @override
  final int initialIndex;
  int lastIndex = 0;

  /// Take a look at the [readme](https://github.com/maheshmnj/navbar_router) for more information on how to use this package.
  ///
  /// Please help me improve this package.
  /// Found a bug? Please file an issue [here](https://github.com/maheshmnj/navbar_router/issues/new?assignees=&labels=&template=bug_report.md&title=)
  /// or
  /// File a feature request by clicking [here](https://github.com/maheshmnj/navbar_router/issues/new?assignees=&labels=&template=feature_request.md&title=)
  ///
  ///
  ///
  ///
  /// Set to true will hide the badges when the tap on the navbar icon.
  final bool hideBadgeOnPageChanged;

  final IndexController pageController;
  NavbarRouter2(
      {super.key,
      required this.destinations,
      required this.errorBuilder,
      this.shouldPopToBaseRoute = true,
      this.onChanged,
      this.decoration,
      this.isDesktop = false,
      this.initialIndex = 0,
      this.type = NavbarType.standard,
      this.destinationAnimationCurve = Curves.fastOutSlowIn,
      this.destinationAnimationDuration = 300,
      this.backButtonBehavior = BackButtonBehavior.exit,
      this.onCurrentTabClicked,
      this.onBackButtonPressed,
      this.hideBadgeOnPageChanged = true,
      required this.pageController})
      : assert(destinations.length >= 2,
            "Destinations length must be greater than or equal to 2"),
        super(
            destinations: destinations,
            errorBuilder: errorBuilder,
            shouldPopToBaseRoute: shouldPopToBaseRoute,
            onChanged: onChanged,
            decoration: decoration,
            isDesktop: isDesktop,
            initialIndex: initialIndex,
            type: type,
            destinationAnimationCurve: destinationAnimationCurve,
            destinationAnimationDuration: destinationAnimationDuration,
            backButtonBehavior: backButtonBehavior,
            onCurrentTabClicked: onCurrentTabClicked,
            onBackButtonPressed: onBackButtonPressed);

  @override
  State<NavbarRouter> createState() => _NavbarRouterState();
}

class _NavbarRouterState extends State<NavbarRouter2>
    with TickerProviderStateMixin {
  final List<NavbarItem> items = [];
  late List<AnimationController> fadeAnimation;
  List<GlobalKey<NavigatorState>> keys = [];

  @override
  void initState() {
    super.initState();
    print("init nav");
    initialize();
  }

  void initialize({bool isUpdate = false, int? i}) {
    // widget.pageController.addListener(() {
    //   if (widget.pageController.)
    // })
    if (i != null) {
      final navbaritem = widget.destinations[i].navbarItem;
      keys[i] = GlobalKey<NavigatorState>(debugLabel: navbaritem.text);
      items[i] = navbaritem;
      return;
    }
    NavbarNotifier2.length = widget.destinations.length;

    List<NavbarBadge> badges = [];
    for (int i = 0; i < NavbarNotifier2.length; i++) {
      final navbaritem = widget.destinations[i].navbarItem;
      keys.add(GlobalKey<NavigatorState>());
      items.add(navbaritem);
      badges.add(navbaritem.badge);
    }
    NavbarNotifier2.setKeys(keys);

    // set badge list here
    NavbarNotifier2.setBadges(badges);
    NavbarNotifier2.hideBadgeOnPageChanged = widget.hideBadgeOnPageChanged;
    // widget.pageController.index = NavbarNotifier2.currentIndex;

    if (!isUpdate) {
      initAnimation();
      NavbarNotifier2.index = widget.initialIndex;
    }
    refreshState = List.filled(widget.destinations.length, 0);
  }

  void initAnimation() {
    fadeAnimation = items.map<AnimationController>((NavbarItem item) {
      return AnimationController(
          lowerBound: 0.5,
          vsync: this,
          value: item == items[widget.initialIndex] ? 1.0 : 0.5,
          duration:
              Duration(milliseconds: widget.destinationAnimationDuration));
    }).toList();
    fadeAnimation[widget.initialIndex].value = 1.0;
  }

  void clearInitialization() {
    keys.clear();
    items.clear();
    NavbarNotifier2.clear();
  }

  @override
  void dispose() {
    for (var controller in fadeAnimation) {
      controller.dispose();
    }
    clearInitialization();
    NavbarNotifier2.removeAllListeners();
    print("nav dispose");
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NavbarRouter2 oldWidget) {
    // print("update");
    if (widget.destinationAnimationCurve !=
            oldWidget.destinationAnimationCurve ||
        widget.destinationAnimationDuration !=
            oldWidget.destinationAnimationDuration) {
      initAnimation();
    }
    if (widget.destinations.length != oldWidget.destinations.length ||
        widget.type != oldWidget.type ||
        !listEquals(oldWidget.destinations, widget.destinations)) {
      clearInitialization();
      initialize(isUpdate: true);
      initialize(i: NavbarNotifier2.currentIndex, isUpdate: true);
    }

    super.didUpdateWidget(oldWidget);
  }

  double getPadding() {
    if (widget.isDesktop) {
      if (widget.decoration!.isExtended) {
        return 140;
      } else {
        return 40;
      }
    }
    return 0;
  }

  double bottomPadding() {
    switch (widget.type) {
      case NavbarType.standard:
        return 0;
      case NavbarType.notched:
        return 0;
      case NavbarType.material3:
        return 0;
      case NavbarType.floating:
        return 0;
      default:
        return 0;
    }
  }

  Widget _buildIndexedStackItem(int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedBuilder(
        key: ValueKey(keys[index]),
        animation: fadeAnimation[index],
        builder: (context, child) {
          ////print(index);
          return Opacity(opacity: fadeAnimation[index].value, child: child);
          // return SlideTransition(
          //   position: Tween<Offset>(
          //     begin: const Offset(-1.0, 0.0),
          //     end: Offset.zero,
          //   ).animate(fadeAnimation[index]),
          //   child: child,
          // );
        },
        child: Navigator(
            key: keys[index],
            initialRoute: widget.destinations[index].initialRoute,
            onGenerateRoute: (RouteSettings settings) {
              Widget? builder = const SizedBox();
              final nestedLength =
                  widget.destinations[index].destinations.length;
              var newName = settings.name;
              for (int j = 0; j < nestedLength; j++) {
                if (widget.destinations[index].destinations[j].route ==
                    settings.name) {
                  // if (settings.name == Routes.projectDetails) {
                  //   builder = ProjectDetailsPage(
                  //       project: settings.arguments as Project);
                  // } else
                  if (settings.name == Routes.favoriteProject) {
                    builder = settings.arguments as FavoriteScreen;
                  } else {
                    builder = widget.destinations[index].destinations[j].widget;
                  }
                  newName =
                      "${settings.name}${widget.destinations[index].destinations[j].route}";
                  print("route $newName");
                }
              }
              return MaterialPageRouteNavBar(route: builder!, settings: settings
                  // RouteSettings(
                  //     name: newName, arguments: settings.arguments)
                  );
            }),
      ),
    );
  }

  void _handleFadeAnimation() {
    for (int i = 0; i < fadeAnimation.length; i++) {
      if (i == NavbarNotifier2.currentIndex) {
        fadeAnimation[i].forward();
      } else {
        fadeAnimation[i].reverse();
      }
    }
  }

  late List<int> refreshState;

  @override
  Widget build(BuildContext context) {
    // print("build nav");
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          final bool isExitingApp = await NavbarNotifier2.onBackButtonPressed(
              behavior: widget.backButtonBehavior);
          if (NavbarNotifier2.isCurrentNavbarHistoryStackSemiEmpty()) {
            if (NavbarNotifier2.isNavbarHidden) {
              NavbarNotifier2.hideBottomNavBar = false;
              //return false;
            }
          }
          final bool value = widget.onBackButtonPressed!(isExitingApp);
          setState(() {
            // NavbarNotifier2.index = NavbarNotifier2.currentIndex;
            widget.pageController
                .move(NavbarNotifier2.currentIndex, animation: false);
            //print("change will pop${NavbarNotifier2.currentIndex}");
            if (widget.onChanged != null) {
              widget.onChanged!(NavbarNotifier2.currentIndex);
            }
            _handleFadeAnimation();
          });
          return value;
        },
        child: AnimatedBuilder(
            animation: _navbarNotifier,
            builder: (context, child) {
              return Stack(
                children: [
                  AnimatedPadding(
                    /// same duration as [_AnimatedNavbar]'s animation duration
                    duration: const Duration(milliseconds: 500),
                    padding: EdgeInsets.only(left: getPadding()),
                    child: TransformerPageView(
                      index: widget.initialIndex,
                      duration: const Duration(milliseconds: 500),
                      transformer: DepthPageTransformer(),
                      itemCount: NavbarNotifier2.length,
                      controller: widget.pageController,
                      itemBuilder: (context, i) =>
                          _buildIndexedStackItem(i, context),
                      onPageChanged: (value) {
                        NavbarNotifier2.index = value ?? 0;
                        if (widget.onChanged != null) {
                          widget.onChanged!(value ?? 0);
                        }
                        _handleFadeAnimation();
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: widget.isDesktop ? 0 : null,
                    bottom: bottomPadding(),
                    right: widget.isDesktop ? null : 0,
                    child: AnimatedNavBar(
                        model: _navbarNotifier,
                        isDesktop: widget.isDesktop,
                        decoration: widget.decoration,
                        navbarType: widget.type,
                        onItemTapped: (x) {
                          // User pressed  on the same tab twice
                          if (NavbarNotifier2.currentIndex == x) {
                            if (widget.shouldPopToBaseRoute) {
                              if (NavbarNotifier2.popAllRoutes(x)) {
                                print("pop nun");
                              }
                            }
                            if (widget.hideBadgeOnPageChanged) {
                              NavbarNotifier2.makeBadgeVisible(
                                  NavbarNotifier2.currentIndex, false);
                            }
                            if (refreshState[NavbarNotifier2.currentIndex] >
                                1) {
                              initialize(i: NavbarNotifier2.currentIndex);
                              refreshState[NavbarNotifier2.currentIndex] = 0;
                            } else if (widget.onCurrentTabClicked != null) {
                              widget.onCurrentTabClicked!();
                              print("tap");
                              refreshState[NavbarNotifier2.currentIndex]++;
                            }
                            // can pop
                          } else {
                            print('not tap');
                            // NavbarNotifier2.index = x;
                            // if (widget.onChanged != null) {
                            //   widget.onChanged!(x);
                            // }
                            // _handleFadeAnimation();

                            if ((x - NavbarNotifier2.currentIndex).abs() > 1) {
                              widget.pageController.move(x, animation: false);
                            } else {
                              widget.pageController.move(x);
                              // duration: const Duration(milliseconds: 500),
                              // curve: Curves.ease);
                            }
                          }
                          // print(refreshState);
                        },
                        menuItems: items),
                  ),
                ],
              );
            }));
  }
}

final NavbarNotifier2 _navbarNotifier = NavbarNotifier2();
List<Color> colors = [mediumPurple, Colors.orange, Colors.teal];
const Color mediumPurple = Color.fromRGBO(79, 0, 241, 1.0);

class MaterialPageRouteNavBar extends PageRouteBuilder {
  final Widget route;
  @override
  final RouteSettings settings;

  MaterialPageRouteNavBar({
    required this.route,
    required this.settings,
  }) : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => route,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation.drive(Tween(begin: 0.9, end: 1.0)),
              child: child,
            ))
        // ScaleTransition(scale: animation, child: child,),
        // SharedAxisTransition(
        //   fillColor: Colors.transparent.withOpacity(0),
        //   animation: animation,
        //   secondaryAnimation: secondaryAnimation,
        //   transitionType: SharedAxisTransitionType.scaled,
        //   child: child,
        // ),
        );
  }
}
