import 'package:animations/animations.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:navbar_router/navbar_router.dart';

const double kM3NavbarHeight = kBottomNavigationBarHeight;
const double kStandardNavbarHeight = kBottomNavigationBarHeight;
const double kNotchedNavbarHeight = kBottomNavigationBarHeight * 1.45;
const double kFloatingNavbarHeight = 60.0;

/// The height of the navbar based on the [NavbarType]
double kNavbarHeight = 0.0;

class _AnimatedNavBar extends StatefulWidget {
  const _AnimatedNavBar(
      {Key? key,
      this.decoration,
      required this.model,
      this.isDesktop = false,
      this.navbarType = NavbarType.standard,
      required this.menuItems,
      required this.onItemTapped})
      : super(key: key);
  final List<NavbarItem> menuItems;
  final NavbarNotifier2 model;
  final Function(int) onItemTapped;
  final bool isDesktop;
  final NavbarType navbarType;
  final NavbarDecoration? decoration;

  @override
  _AnimatedNavBarState createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<_AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant _AnimatedNavBar oldWidget) {
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
    _controller.reverse();
    return;
  }

  void _showBottomNavBar() {
    _controller.forward();
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

    final foregroundColor =
        defaultDecoration.backgroundColor!.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white;

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
      if (widget.decoration != null) {
        navigationRailDefaultDecoration =
            navigationRailDefaultDecoration.copyWith(
          isExtended: widget.decoration!.isExtended,
          enableFeedback: widget.decoration!.enableFeedback,
          backgroundColor:
              widget.decoration!.backgroundColor ?? theme.colorScheme.surface,
          elevation: widget.decoration!.elevation ??
              theme.navigationRailTheme.elevation,
          selectedIconTheme: widget.decoration!.selectedIconTheme ??
              theme.iconTheme
                  .copyWith(color: theme.colorScheme.onSecondaryContainer),
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
                  theme.iconTheme
                      .copyWith(color: theme.colorScheme.onSecondaryContainer),
          extended: navigationRailDefaultDecoration.isExtended,
          backgroundColor: navigationRailDefaultDecoration.backgroundColor ??
              theme.colorScheme.surface,
          destinations: widget.menuItems.map((NavbarItem menuItem) {
            return NavigationRailDestination(
              icon: Icon(menuItem.iconData),
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

abstract class NavbarBase extends StatefulWidget {
  const NavbarBase({Key? key}) : super(key: key);
  NavbarDecoration get decoration;

  double? get elevation;

  Function(int)? get onItemTapped;

  List<NavbarItem> get menuItems;

  double get height;
}

class StandardNavbar extends NavbarBase {
  const StandardNavbar(
      {Key? key,
      required this.navBarDecoration,
      required this.navBarElevation,
      required this.onTap,
      this.navbarHeight,
      this.index = 0,
      required this.items})
      : super(key: key);

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
                  ? items[index].selectedIcon ??
                      Icon(
                        items[index].iconData,
                      )
                  : Icon(
                      items[index].iconData,
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

  /// Take a look at the [readme](https://github.com/maheshmnj/navbar_router) for more information on how to use this package.
  ///
  /// Please help me improve this package.
  /// Found a bug? Please file an issue [here](https://github.com/maheshmnj/navbar_router/issues/new?assignees=&labels=&template=bug_report.md&title=)
  /// or
  /// File a feature request by clicking [here](https://github.com/maheshmnj/navbar_router/issues/new?assignees=&labels=&template=feature_request.md&title=)
  ///
  ///
  ///
  const NavbarRouter2({
    super.key,
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
  })  : assert(destinations.length >= 2,
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
    initialize();
  }

  void initialize({bool isUpdate = false, int? i}) {
    if (i != null) {
      final navbaritem = widget.destinations[i].navbarItem;
      keys[i] = GlobalKey<NavigatorState>(debugLabel: navbaritem.text);
      items[i] = navbaritem;
      return;
    }
    NavbarNotifier2.length = widget.destinations.length;
    for (int i = 0; i < NavbarNotifier2.length; i++) {
      final navbaritem = widget.destinations[i].navbarItem;
      keys.add(GlobalKey<NavigatorState>(debugLabel: navbaritem.text));
      items.add(navbaritem);
    }
    NavbarNotifier2.setKeys(keys);
    if (!isUpdate) {
      initAnimation();
      NavbarNotifier2.index = widget.initialIndex;
    }
  }

  void initAnimation() {
    fadeAnimation = items.map<AnimationController>((NavbarItem item) {
      return AnimationController(
          vsync: this,
          value: item == items[widget.initialIndex] ? 1.0 : 0.0,
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
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NavbarRouter2 oldWidget) {
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
    }
    super.didUpdateWidget(oldWidget);
  }

  double getPadding() {
    if (widget.isDesktop) {
      if (widget.decoration!.isExtended) {
        return 256.0;
      } else {
        return 72.0;
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
    return AnimatedBuilder(
      key: ValueKey(keys[index]),
      animation: fadeAnimation[index],
      builder: (context, child) {
        // print(index);
        // return IgnorePointer(
        //   ignoring: index != NavbarNotifier2.currentIndex,
        //   child: Opacity(opacity: fadeAnimation[index].value, child: child),
        // );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(fadeAnimation[index]),
          child: child,
        );
      },
      child: Navigator(
          key: keys[index],
          initialRoute: widget.destinations[index].initialRoute,
          onGenerateRoute: (RouteSettings settings) {
            Widget? builder = const SizedBox();
            final nestedLength = widget.destinations[index].destinations.length;
            for (int j = 0; j < nestedLength; j++) {
              if (widget.destinations[index].destinations[j].route ==
                  settings.name) {
                builder = widget.destinations[index].destinations[j].widget;
              }
            }
            return MaterialPageRouteNavBar(route: builder!, settings: settings);
          }),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final bool isExitingApp = await NavbarNotifier2.onBackButtonPressed(
              behavior: widget.backButtonBehavior);

          final bool value = widget.onBackButtonPressed!(isExitingApp);
          setState(() {
            NavbarNotifier2.index = NavbarNotifier2.currentIndex;
            print("change will pop");
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
                    child: Stack(children: [
                      for (int i = 0; i < NavbarNotifier2.length; i++)
                        _buildIndexedStackItem(i, context)
                    ]),
                  ),
                  Positioned(
                    left: 0,
                    top: widget.isDesktop ? 0 : null,
                    bottom: bottomPadding(),
                    right: widget.isDesktop ? null : 0,
                    child: _AnimatedNavBar(
                        model: _navbarNotifier,
                        isDesktop: widget.isDesktop,
                        decoration: widget.decoration,
                        navbarType: widget.type,
                        onItemTapped: (x) {
                          // User pressed  on the same tab twice
                          if (NavbarNotifier2.currentIndex == x) {
                            if (widget.shouldPopToBaseRoute) {
                              NavbarNotifier2.popAllRoutes(x);
                            }
                            if (widget.onCurrentTabClicked != null) {
                              setState(() {
                                widget.onCurrentTabClicked!();
                                print("tap");
                                initialize(i: NavbarNotifier2.currentIndex);
                              });
                            }
                          } else {
                            NavbarNotifier2.index = x;
                            if (widget.onChanged != null) {
                              widget.onChanged!(x);
                            }
                            _handleFadeAnimation();
                          }
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
  final RouteSettings settings;

  MaterialPageRouteNavBar({
    required this.route,
    required this.settings,
  }) : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 800),
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
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        )
        // ScaleTransition(scale: animation, child: child,),
        // SharedAxisTransition(
        //   fillColor: Theme.of(context).cardColor,
        //   animation: animation,
        //   secondaryAnimation: secondaryAnimation,
        //   transitionType: SharedAxisTransitionType.scaled,
        //   child: child,
        // ),
        );
  }
}