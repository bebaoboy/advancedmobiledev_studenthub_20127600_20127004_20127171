import 'dart:math';

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:badges/badges.dart' as badges;
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/custom_page_route_navbar.dart'
    hide mediumPurple;
import 'package:boilerplate/utils/routes/navbar_item.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/navbar_router.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget_test.dart';

const String placeHolderText =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

final List<Color> themeColorSeed = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.brown,
  Colors.cyan,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.lime,
  Colors.amber,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.yellow,
  Colors.grey,
];

extension FindText on String {
  Finder textX() => find.text(this);
}

extension FindKey on Key {
  Finder keyX() => find.byKey(this);
}

extension FindType on Type {
  Finder typeX() => find.byType(this);
}

extension FindWidget on Widget {
  Finder widgetX() => find.byWidget(this);
}

extension FindIcon on IconData {
  Finder iconX() => find.byIcon(this);
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({"first_time": true});
  await initDb();

  // updated test items with badges
  const List<NavbarItem> items = [
    NavbarItem(Icons.home_outlined, 'Home',
        backgroundColor: mediumPurple,
        selectedIcon: Icon(
          key: Key("HomeIconSelected"),
          Icons.home,
          size: 26,
        ),
        badge: NavbarBadge(
          key: Key("TwoDigitBadge"),
          badgeText: "10",
          showBadge: true,
        )),
    NavbarItem(Icons.shopping_bag_outlined, 'Products',
        backgroundColor: Colors.orange,
        selectedIcon: Icon(
          Icons.shopping_bag,
          key: Key("ProductsIconSelected"),
          size: 26,
        ),
        badge: NavbarBadge(
          key: Key("OneDigitBadge"),
          badgeText: "8",
          showBadge: true,
        )),
    NavbarItem(Icons.person_outline, 'Me',
        backgroundColor: Colors.teal,
        selectedIcon: Icon(
          key: Key("MeIconSelected"),
          Icons.person,
          size: 26,
        ),
        badge: NavbarBadge(
          key: Key("DotBadge1"),
          showBadge: true,
          color: Colors.amber,
        )),
    NavbarItem(Icons.settings_outlined, 'Settings',
        backgroundColor: Colors.red,
        selectedIcon: Icon(
          Icons.settings,
          size: 26,
        ),
        badge: NavbarBadge(
          key: Key("DotBadge2"),
          showBadge: true,
          color: Colors.red,
        )),
  ];
  final pageController2 = IndexController();
  List<Map<String, Widget>> routes = [
    {
      '/': const Placeholder(),
      Routes.favoriteProject: getRoute(Routes.favoriteProject,
          NavigationService.navigatorKey.currentContext),
    },
    {
      '/': const Placeholder(),
      // Routes.projectDetails: ProjectDetailsPage(
      //   project: Project(title: 'som', description: 'smm'),
      // ),
      // Routes.project_post: getRoute(Routes.project_post),
    },
    {
      '/': const Placeholder(),

      // ProfileEdit.route: ProfileEdit(),
    },
    {
      '/': const Placeholder(),
    },
  ];

  Widget boilerplate(
      {bool isDesktop = false,
      Size? size,
      BackButtonBehavior behavior = BackButtonBehavior.exit,
      required List<Map<String, Widget>> routes,
      NavbarType type = NavbarType.standard,
      NavbarDecoration? decoration,
      int index = 0,
      Function()? onCurrentTabClicked,
      Function(int)? onChanged,
      List<NavbarItem> navBarItems = items}) {
    size ??= const Size(800.0, 600.0);
    return MaterialApp(
      home: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
              data: MediaQueryData(size: size),
              child: NavbarRouter2(
                errorBuilder: (context) {
                  return const Center(child: Text('Error 404'));
                },
                onChanged: onChanged,
                onCurrentTabClicked: onCurrentTabClicked,
                onBackButtonPressed: (isExiting) {
                  return isExiting;
                },
                initialIndex: index,
                type: type,
                backButtonBehavior: behavior,
                isDesktop: isDesktop,
                destinationAnimationCurve: Curves.fastOutSlowIn,
                destinationAnimationDuration: 200,
                decoration: decoration ??
                    NavbarDecoration(
                        navbarType: BottomNavigationBarType.shifting),
                destinations: [
                  for (int i = 0; i < navBarItems.length; i++)
                    DestinationRouter(
                      navbarItem: navBarItems[i],
                      destinations: [
                        for (int j = 0; j < routes[i].keys.length; j++)
                          Destination(
                            route: routes[i].keys.elementAt(j),
                            widget: routes[i].values.elementAt(j),
                          ),
                      ],
                      initialRoute: routes[i].keys.first,
                    ),
                ],
                pageController: pageController2,
              ))),
    );
  }

  // function containing all badge tests and subtests
  badgeGroupTest({NavbarType type = NavbarType.standard}) {
    badges.Badge findBadge(tester, index) {
      return tester.widget(find.byKey(NavbarNotifier2.badges[index].key!))
          as badges.Badge;
    }

    // test color and visibility
    testDot(tester, index) {
      expect(find.byKey(NavbarNotifier2.badges[index].key!), findsOneWidget);

      // test visibility
      expect(findBadge(tester, index).showBadge,
          NavbarNotifier2.badges[index].showBadge);

      // test color
      expect(findBadge(tester, index).badgeStyle.badgeColor,
          NavbarNotifier2.badges[index].color);
    }

    /// Test badge
    testBadgeWithText(tester, index) {
      var textFind = find.text(NavbarNotifier2.badges[index].badgeText);
      expect(textFind, findsOneWidget);

      // test dot
      testDot(tester, index);

      // compare the content of badge
      Text text = tester.firstWidget(textFind);
      expect(text.data, NavbarNotifier2.badges[index].badgeText);
    }

    desktopMode(tester) async {
      await tester
          .pumpWidget(boilerplate(routes: routes, isDesktop: true, type: type));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    }

    testBadge(tester, index) async {
      NavbarNotifier2.badges[index].badgeText.isNotEmpty
          ? testBadgeWithText(tester, index)
          : testDot(tester, index);
      NavbarNotifier2.badges[index].badgeText.isNotEmpty
          ? testBadgeWithText(tester, index)
          : testDot(tester, index);
    }

    testWidgets('Should build initial badges', (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate(
        routes: routes,
      ));
      // test visibility
      testBadge(tester, 0);
      testBadge(tester, 1);
      testBadge(tester, 2);
      testBadge(tester, 3);
    });

    testWidgets('Should allow to update badges dynamically',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate(
        routes: routes,
      ));

      // test badge
      testBadge(tester, 0);
      // update the whole badge
      NavbarNotifier2.updateBadge(
          0,
          const NavbarBadge(
            key: Key("TwoDigitBadgeNew"),
            badgeText: "11",
            showBadge: true,
          ));
      await tester.pumpAndSettle();

      testBadge(tester, 0);

      // hide the badge
      NavbarNotifier2.makeBadgeVisible(0, false);
      await tester.pumpAndSettle();
      expect(NavbarNotifier2.badges[0].showBadge, false);
      testBadge(tester, 0);
    });

    testWidgets('Should allow to hide/show badges on demand',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate(
        routes: routes,
      ));

      // test badge
      testBadge(tester, 0);

      // hide all the badge
      for (int i = 0; i < NavbarNotifier2.length; i++) {
        NavbarNotifier2.makeBadgeVisible(i, false);
        await tester.pumpAndSettle();
        expect(NavbarNotifier2.badges[i].showBadge, false);
        testBadge(tester, i);
      }

      // show all the badge
      for (int i = 0; i < NavbarNotifier2.length; i++) {
        NavbarNotifier2.makeBadgeVisible(i, true);
        await tester.pumpAndSettle();
        expect(NavbarNotifier2.badges[i].showBadge, true);
        testBadge(tester, i);
      }
    });

    testWidgets('Desktop: should build initial badges',
        (WidgetTester tester) async {
      await desktopMode(tester);
      // test visibility
      testBadge(tester, 0);
      testBadge(tester, 1);
      testBadge(tester, 2);
      testBadge(tester, 3);
    });

    testWidgets('Desktop: should allow to update badges dynamically',
        (WidgetTester tester) async {
      await desktopMode(tester);

      // test badge
      testBadge(tester, 0);
      // update the whole badge
      NavbarNotifier2.updateBadge(
          0,
          const NavbarBadge(
            key: Key("TwoDigitBadgeNew"),
            badgeText: "11",
            showBadge: true,
          ));
      await tester.pumpAndSettle();

      testBadge(tester, 0);

      // hide the badge
      NavbarNotifier2.makeBadgeVisible(0, false);
      await tester.pumpAndSettle();
      expect(NavbarNotifier2.badges[0].showBadge, false);
      testBadge(tester, 0);
    });

    testWidgets('Desktop: should allow to hide/show badges on demand',
        (WidgetTester tester) async {
      await desktopMode(tester);

      // test badge
      testBadge(tester, 0);

      // hide all the badge
      for (int i = 0; i < NavbarNotifier2.length; i++) {
        NavbarNotifier2.makeBadgeVisible(i, false);
        await tester.pumpAndSettle();
        expect(NavbarNotifier2.badges[i].showBadge, false);
        testBadge(tester, i);
      }

      // show all the badge
      for (int i = 0; i < NavbarNotifier2.length; i++) {
        NavbarNotifier2.makeBadgeVisible(i, true);
        await tester.pumpAndSettle();
        expect(NavbarNotifier2.badges[i].showBadge, true);
        testBadge(tester, i);
      }
    });
  }

  group('Test NavbarType: NavbarType.standard ', () {
    // test badges
    group('Should build destination, navbar items, and badges', () {
      testWidgets('NavbarType.standard: should build destinations',
          (WidgetTester tester) async {
        final bottomNavigation = (BottomNavigationBar).typeX();
        final navigationRail = (NavigationRail).typeX();
        int initialIndex = 0;

        await tester
            .pumpWidget(boilerplate(routes: routes, index: initialIndex));
        await tester.pumpAndSettle();
        expect(navigationRail, findsNothing);
        expect(bottomNavigation, findsOneWidget);
        for (int i = 0; i < items.length; i++) {
          final icon = find.byIcon(items[i].iconData);
          final selectedIcon = find.byKey(const Key('HomeIconSelected'));
          final destination = (routes[i]['/']).runtimeType.typeX();
          if (i == initialIndex) {
            expect(selectedIcon, findsOneWidget);
            await tester.tap(selectedIcon);
          } else {
            expect(icon, findsOneWidget);
            await tester.tap(icon);
          }
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
      });

      testWidgets('NavbarType.standard: should build navbarItem labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          routes: routes,
        ));
        expect(find.text(items[0].text), findsOneWidget);
        expect(find.text(items[1].text), findsWidgets);
        expect(find.text(items[2].text), findsOneWidget);
      });

      group('NavbarType.standard: badges test', () {
        badgeGroupTest();
      });

      testWidgets(
          "NavbarType.standard: should allow updating navbar routes dynamically ",
          (WidgetTester tester) async {
        List<NavbarItem>? menuitems = [
          const NavbarItem(Icons.home_outlined, 'Home',
              backgroundColor: mediumPurple),
          const NavbarItem(Icons.shopping_bag_outlined, 'Products',
              backgroundColor: Colors.orange),
          const NavbarItem(Icons.person_outline, 'Me',
              backgroundColor: Colors.teal),
        ];

        await tester.pumpWidget(boilerplate(
          routes: routes,
          navBarItems: menuitems,
        ));
        await tester.pumpAndSettle();
        final bottomNavigation = (BottomNavigationBar).typeX();
        expect(bottomNavigation, findsOneWidget);

        for (int i = 0; i < menuitems.length; i++) {
          final icon = find.byIcon(menuitems[i].iconData);
          final destination = (routes[i]['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
        int randomIndex = Random().nextInt(menuitems.length);
        menuitems.add(items[randomIndex]);
        routes[routes.length - 1] = routes[randomIndex];
        await tester.pumpAndSettle();
        for (int i = 0; i < menuitems.length; i++) {
          final icon = find.byIcon(menuitems[i].iconData);
          final destination = (routes[i]['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
      });
    });

    testWidgets('NavbarType.standard: default index must be zero',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate(
        routes: routes,
      ));
      expect(NavbarNotifier2.currentIndex, 0);
      final destination = (routes[0]['/']).runtimeType.typeX();
      expect(destination, findsOneWidget);
      final icon = find.byKey(const Key('HomeIconSelected'));
      expect(icon, findsOneWidget);
    });

    testWidgets('NavbarType.standard: Set initial index to non-zero',
        (WidgetTester tester) async {
      int initialIndex = 2;
      await tester.pumpWidget(boilerplate(
          routes: routes, type: NavbarType.standard, index: initialIndex));
      expect(NavbarNotifier2.currentIndex, initialIndex);
      final destination = (routes[initialIndex]['/']).runtimeType.typeX();
      expect(destination, findsOneWidget);
      final icon = find.byWidget(items[initialIndex].selectedIcon!);
      expect(icon, findsOneWidget);
    });

    testWidgets(
        'NavbarType.standard: should switch to Navigation Rail in Desktop mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate(
        routes: routes,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      await tester.pumpWidget(boilerplate(routes: routes, isDesktop: true));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    group('NavbarType.standard: should respect BackButtonBehavior', () {});

    testWidgets('NavbarDecoration can be set to NavigationRail in Desktop mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate(
          routes: routes,
          isDesktop: true,
          decoration: NavbarDecoration(
            isExtended: true,
            navbarType: BottomNavigationBarType.shifting,
            backgroundColor: Colors.blue,
            elevation: 8.0,
            indicatorColor: Colors.grey,
            indicatorShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          )));

      await tester.pumpAndSettle();
      final navigationRail = (NavigationRail).typeX();
      expect(navigationRail, findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      final finder = find.byType(StandardNavbar);
      expect(finder, findsNothing);
      final NavigationRail navigationRailWidget =
          tester.widget(navigationRail) as NavigationRail;
      expect(navigationRailWidget.extended, true);
      // expect(navigationRailWidget.minExtendedWidth, 200);
      // expect(navigationRailWidget.backgroundColor, Colors.blue);
      // expect(navigationRailWidget.elevation, 8.0);
      // expect(navigationRailWidget.indicatorColor, Colors.grey);
      // expect(
      //     navigationRailWidget.indicatorShape,
      //     const RoundedRectangleBorder(
      //       borderRadius: BorderRadius.only(
      //         topLeft: Radius.circular(10),
      //         topRight: Radius.circular(10),
      //       ),
      //     ));
      // expect(navigationRailWidget.minWidth, 74);
    });
  });

  /// Test navbar type notched
  testWidgets('Navbar can be hidden during runtime',
      (WidgetTester tester) async {
    await tester.pumpWidget(boilerplate(
      routes: routes,
    ));
    final finder = find.byType(BottomNavigationBar);
    expect(finder, findsOneWidget);
    NavbarNotifier2.hideBottomNavBar = true;
    await tester.pumpAndSettle();
    // test if widget is hidden (not visible in view port)
    expect(finder.hitTestable(), findsNothing);
    NavbarNotifier2.hideBottomNavBar = false;
    await tester.pumpAndSettle();
    expect(finder, findsOneWidget);
  });

  testWidgets('Notify index Change', (WidgetTester tester) async {
    int index = 0;
    await tester.pumpWidget(boilerplate(
      routes: routes,
    ));
    NavbarNotifier2.addIndexChangeListener((x) {
      index = x;
    });
    NavbarNotifier2.index = 1;
    expect(index, 1);
    NavbarNotifier2.index = 2;
    expect(index, 2);
    NavbarNotifier2.removeLastListener();
    NavbarNotifier2.index = 3;
    expect(index, 2);
  });

  testWidgets("onCurrentTabClicked should be invoked", (tester) async {
    int index = 0;
    await tester.pumpWidget(boilerplate(
      routes: routes,
      onCurrentTabClicked: () {
        index = 1;
      },
    ));
    await tester.pumpAndSettle();
    final productIcon = find.byIcon(items[1].iconData);
    expect(productIcon, findsOneWidget);
    await tester.tap(productIcon);
    expect(index, 0);
    await tester.pumpAndSettle();
    final productSelectedIcon = find.byKey(const Key("ProductsIconSelected"));
    expect(productSelectedIcon, findsOneWidget);
    await tester.tap(productSelectedIcon);
    expect(index, 1);
  });

  // WARNING: Snackbar Test are written considering snackbars are shown across all the tabs
  // e.g if a snackbar is shown it will be displayed items.length times
  // This is because we have migrated to Stack inplace of IndexedStack
    testWidgets('Navbar should persist index on widget update',
      (WidgetTester tester) async {
    // pass outlined icons
    Color backgroundColor = Colors.red;
    List<NavbarItem> navItems = [
      NavbarItem(Icons.home_outlined, 'Home',
          backgroundColor: backgroundColor,
          selectedIcon: const Icon(
            key: Key("HomeIconSelected"),
            Icons.home_outlined,
            size: 26,
          )),
      const NavbarItem(Icons.shopping_bag_outlined, 'Products',
          backgroundColor: Colors.orange,
          selectedIcon: Icon(
            Icons.shopping_bag_outlined,
            key: Key("ProductsIconSelected"),
            size: 26,
          )),
      const NavbarItem(Icons.person_outline, 'Me',
          backgroundColor: Colors.teal,
          selectedIcon: Icon(
            key: Key("MeIconSelected"),
            Icons.person,
            size: 26,
          )),
      const NavbarItem(Icons.settings_outlined, 'Settings',
          backgroundColor: Colors.red,
          selectedIcon: Icon(
            Icons.settings,
            size: 26,
          )),
    ];
    await tester.pumpWidget(boilerplate(routes: routes, navBarItems: navItems));

    await tester.pumpAndSettle();
    expect(NavbarNotifier2.currentIndex, equals(0));
    // expect('Feed 0 card'.textX(), findsOneWidget);
    NavbarNotifier2.index = 1;
    await tester.pumpAndSettle();
    expect(NavbarNotifier2.currentIndex, equals(1));
    // expect('Product 1'.textX(), findsOneWidget);
    NavbarNotifier2.index = 2;
    await tester.pumpAndSettle();
    expect(NavbarNotifier2.currentIndex, equals(2));
    // expect('Hi! This is your Profile Page'.textX(), findsOneWidget);

    // change background color
    await tester.pumpAndSettle();
    expect(NavbarNotifier2.currentIndex, equals(2));
    backgroundColor = Colors.green;
    await tester.pumpAndSettle();
    expect(NavbarNotifier2.currentIndex, equals(2));
  });

}
