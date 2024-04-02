// ignore_for_file: unused_field, must_be_immutable, prefer_final_fields, prefer_const_declarations, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:boilerplate/core/widgets/language_button_widget.dart';
import 'package:boilerplate/core/widgets/pip/picture_in_picture.dart';
import 'package:boilerplate/core/widgets/pip/pip_params.dart';
import 'package:boilerplate/core/widgets/pip/pip_view_corner.dart';
import 'package:boilerplate/core/widgets/pip/pip_widget.dart';
import 'package:boilerplate/core/widgets/refresh_indicator/indicators/plane_indicator.dart';
import 'package:boilerplate/core/widgets/theme_button_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/mockData.dart';
import 'package:boilerplate/presentation/dashboard/alert_tab.dart';
import 'package:boilerplate/presentation/dashboard/dashboard_tab.dart';
import 'package:boilerplate/presentation/dashboard/message_tab.dart';
import 'package:boilerplate/presentation/dashboard/project_tab.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/welcome/pip_test.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/custom_page_route_navbar.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:rxdart/rxdart.dart';

// ---------------------------------------------------------------------------
class What extends StatefulWidget {
  const What({super.key});

  @override
  State<What> createState() => _WhatState();
}

class _WhatState extends State<What> with TickerProviderStateMixin {
  final int _selectedIndex = 1;

  final UserStore _userStore = getIt<UserStore>();
  late AnimationController _planeController;
  @override
  void initState() {
    _pageController.addListener(
      () {
        setState(() {
          pageValue = _pageController.page ?? 0;
        });
      },
    );
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    for (final cloud in _clouds) {
      cloud.controller = AnimationController(
        vsync: this,
        duration: cloud.dr,
      );
    }
    for (final cloud in _clouds2) {
      cloud.controller = AnimationController(
        vsync: this,
        duration: cloud.dr,
      );
    }
    for (final cloud in _clouds3) {
      cloud.controller = AnimationController(
        vsync: this,
        duration: cloud.dr,
      );
    }

    childs = [
      KeepAlivePage(ProjectTab(
        scrollController: ScrollController(),
      )),
      KeepAlivePage(DashBoardTab(
              pageController: _pageController,
            )),
      const KeepAlivePage(MessageTab()),
      const KeepAlivePage(AlertTab())
    ];
    _routes = [
      {
        '/': const Center(child: Text("????")),
        Routes.favortieProject: getRoute(Routes.favortieProject, context),
      },
      {
        '/': const Center(child: Text("Pull it harder")),
      },
      {
        '/': const Center(child: Text("????")),

        // ProfileEdit.route: ProfileEdit(),
      },
      {
        '/': const Center(child: Text("????")),
      },
    ];

    super.initState();
  }

  List<Widget> childs = [];
  List<NavbarItem> items = [];
  List<Map<String, Widget>> _routes = [];
  DateTime oldTime = DateTime.now();
  final _pageController2 = IndexController();
  final _pageController = PageController(initialPage: 1);
  final LanguageStore _languageStore = getIt<LanguageStore>();
  String lastLocale = "";
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
  double expHeight = 500;
  @override
  void dispose() {
    _planeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant What oldWidget) {
    if (lastLocale != _languageStore.locale) {
      // print("change locale");
      initItems();
      // print("change locale");
      lastLocale = _languageStore.locale;
    }
    super.didUpdateWidget(oldWidget);
  }

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

  bool open = false;
  double scale1 = 1;
  double scale4 = 1;
  double scale2 = 0;
  double scale3 = 0;
  double op1 = 0;

  @override
  Widget build(BuildContext context) {
    //print('check ${_userStore.user!.email} ${_userStore.user!.type.name}');
    if (items.isEmpty || lastLocale != _languageStore.locale) {
      initItems();
      // print("change locale");
      lastLocale = _languageStore.locale;
    }
    double screenWidth = MediaQuery.of(context).size.width;
    return DraggableHome(
        fullExpandedCallback: (v) async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            open = v;
            op1 = 1;
          });
        },
        stretchTriggerOffset: 350,
        fullyStretchable: true,
        initialCollapse: true,
        alwaysShowLeadingAndAction: true,
        appBarDefaultHeight: 60,
        centerTitle: false,
        alwaysShowTitle: true,
        actions: [
          LanguageButton(),
          ThemeButton(),
          _buildLogoutButton(),
        ],
        title: Lang.get('appbar_title'),
        headerWidget: Container(
          height: expHeight,
          color: Colors.transparent,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              AnimatedOpacity(
                  opacity: scale4,
                  duration: const Duration(seconds: 3),
                  child: Stack(children: [
                    for (final cloud in _clouds.sublist(1))
                      Transform.translate(
                        offset: Offset(((screenWidth) - cloud.width) * cloud.r2,
                            (cloud.dry * cloud.r)),
                        child: OverflowBox(
                          minWidth: cloud.wR.truncateToDouble(),
                          minHeight: cloud.wR.truncateToDouble(),
                          maxHeight: cloud.wR.truncateToDouble(),
                          maxWidth: cloud.wR.truncateToDouble(),
                          alignment: Alignment.topLeft,
                          child: Image(
                            color: cloud.color,
                            image: cloud.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ])),
              AnimatedScale(
                scale: scale2,
                duration: const Duration(seconds: 5),
                child: Center(
                  child: Text(
                    "Hold the red cloud",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: scale2,
                duration: const Duration(seconds: 3),
                child: Stack(
                  children: [
                    for (final cloud in _clouds2)
                      Transform.translate(
                        offset: Offset(((screenWidth) - cloud.width) * cloud.r2,
                            (cloud.dry * cloud.r)),
                        child: OverflowBox(
                          minWidth: cloud.wR.truncateToDouble(),
                          minHeight: cloud.wR.truncateToDouble(),
                          maxHeight: cloud.wR.truncateToDouble(),
                          maxWidth: cloud.wR.truncateToDouble(),
                          alignment: Alignment.topLeft,
                          child: Image(
                            color: cloud.color,
                            image: cloud.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    Transform.translate(
                      offset: Offset(
                        ((screenWidth) - _clouds[0].width) *
                            _clouds[0].r2 *
                            0.5,
                        (scale3 == 1
                            ? -1 *
                                (700 *
                                    CurveTween(curve: Curves.easeInOut)
                                        .transform(
                                            _clouds[0].controller!.value))
                            : _clouds[0].dry * _clouds[0].r),
                      ),
                      child: OverflowBox(
                        minWidth: 50,
                        minHeight: 50,
                        maxHeight: 80,
                        maxWidth: 80,
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onLongPress: () {
                            showAnimatedDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return ClassicGeneralDialogWidget(
                                  titleText: 'Welcome to StudentHub',
                                  contentText:
                                      'A marketplace to connect students with real-world project!',
                                  positiveText: 'OK',
                                  onPositiveClick: () async {
                                    Navigator.of(context).pop();
                                    for (final cloud in _clouds) {
                                      cloud.controller!.forward();
                                    }

                                    for (final cloud in _clouds2) {
                                      cloud.controller!.forward();
                                    }

                                    for (final cloud in _clouds3) {
                                      cloud.controller!.forward();
                                    }

                                    setState(() {
                                      scale2 = 0;
                                      scale3 = 1;
                                      scale4 = 0;
                                    });
                                  },
                                );
                              },
                              animationType: DialogTransitionType.size,
                              curve: Curves.fastOutSlowIn,
                              duration: const Duration(seconds: 1),
                            );
                          },
                          child: Image(
                            color: Theme.of(context).colorScheme.primary,
                            image: _clouds[0].image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedOpacity(
                opacity: scale3,
                duration: const Duration(seconds: 5),
                child: Center(
                  child: Text(
                    "Thanks for your patience!\nNow press back",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).size.width * 0.25,
                left: MediaQuery.of(context).size.width * 0.2,
                child: Text(
                  Lang.get('appbar_title'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
              ),

              AnimatedOpacity(
                duration: const Duration(seconds: 4),
                opacity: scale3,
                child: Stack(
                  children: [
                    for (final cloud in _clouds3)
                      Transform.translate(
                        offset: Offset(((screenWidth) - cloud.width) * cloud.r2,
                            (cloud.dry * cloud.r)),
                        child: OverflowBox(
                          minWidth: cloud.wR.truncateToDouble(),
                          minHeight: cloud.wR.truncateToDouble(),
                          maxHeight: cloud.wR.truncateToDouble(),
                          maxWidth: cloud.wR.truncateToDouble(),
                          alignment: Alignment.topLeft,
                          child: Image(
                            color: cloud.color,
                            image: cloud.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              open
                  ? Positioned(
                      bottom: MediaQuery.of(context).size.width * 0.25,
                      left: MediaQuery.of(context).size.width * 0.27,
                      child: AnimatedOpacity(
                        opacity: op1,
                        duration: const Duration(seconds: 3),
                        child: Text(
                          "Hold the airplane",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),

              /// plane
              Center(
                child: AnimatedOpacity(
                  opacity: (scale1 + 0.5).clamp(0, 1),
                  duration: const Duration(seconds: 5),
                  child: OverflowBox(
                    maxWidth: 172,
                    minWidth: 172,
                    maxHeight: 50,
                    minHeight: 50,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _planeController,
                      child: InkWell(
                        onLongPress: () async {
                          if (!open) return;
                          // await Future.delayed(Duration(seconds: 3));
                          setState(() {
                            if (scale1 == 1) {
                              scale1 = 0;
                              open = false;
                              scale2 = 1;
                              _planeController.forward();
                            }
                          });
                        },
                        child: Image.asset(
                          "assets/plane_indicator/plane.png",
                          width: 172,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      builder: (BuildContext context, Widget? child) {
                        return Transform.translate(
                          offset: Offset(
                              -1 *
                                  (300 *
                                      CurveTween(curve: Curves.easeInOut)
                                          .transform(_planeController.value)),
                              0),
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: [
          Container(
            padding: const EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height * 0.9,
            child: NavbarRouter2(
              pageController: _pageController2,
              initialIndex: 1,
              backButtonBehavior: BackButtonBehavior.exit,
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
                setState(() {});
              },
              onBackButtonPressed: (isExiting) {
                if (isExiting) {
                  var newTime = DateTime.now();
                  // ignore: unused_local_variable
                  int difference = newTime.difference(oldTime).inMilliseconds;
                  oldTime = newTime;
                  if (true) {
                    NavbarNotifier2.hideSnackBar(context);
                    PictureInPicture.updatePiPParams(
                      pipParams: const PiPParams(
                        pipWindowHeight: 200,
                        pipWindowWidth: 100,
                        bottomSpace: 64,
                        leftSpace: 64,
                        rightSpace: 64,
                        topSpace: 64,
                        minSize: Size(100, 200),
                        maxSize: Size(350, 900),
                        movable: true,
                        resizable: true,
                        initialCorner: PIPViewCorner.bottomRight,
                      ),
                    );
                    PictureInPicture.startPiP(
                        pipWidget: PiPWidget(
                      child: const PiPTestScreen(), //Optional

                      onPiPClose: () {
                        //Handle closing events e.g. dispose controllers.
                      },
                      elevation: 10, //Optional
                      pipBorderRadius: 10, //Optional
                    ));
                    return true;
                  }
                  // else {
                  //   NavbarNotifier2.showSnackBar(
                  //     context,
                  //     "Press Back again to exit",
                  //     /// offset from bottom of the screen
                  //     ///
                  //   );
                  //   oldTime = DateTime.now();
                  //   return false;
                  // }
                } else {
                  return isExiting;
                }
              },
              destinationAnimationCurve: Curves.fastOutSlowIn,
              destinationAnimationDuration: 200,
              decoration: NavbarDecoration(
                  navbarType: BottomNavigationBarType.shifting),
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
          ),
        ]);
  }

  Widget _buildLogoutButton() {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute2(routeName: Routes.login),
            (Route<dynamic> route) => false);
      },
      icon: const Icon(
        Icons.power_settings_new,
      ),
    );
  }

  var _clouds2 = [
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.6,
      dy: 10.0,
      image: AssetImage(Cloud.assets[1]),
      width: 100,
      duration: const Duration(milliseconds: 1200),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.6,
      dy: 10.0,
      image: AssetImage(Cloud.assets[1]),
      width: 100,
      duration: const Duration(milliseconds: 1200),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
  ];
  var _clouds = [
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.6,
      dy: 10.0,
      image: AssetImage(Cloud.assets[1]),
      width: 100,
      duration: const Duration(milliseconds: 1200),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
  ];

  var _clouds3 = [
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.6,
      dy: 10.0,
      image: AssetImage(Cloud.assets[1]),
      width: 100,
      duration: const Duration(milliseconds: 1200),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.6,
      dy: 10.0,
      image: AssetImage(Cloud.assets[1]),
      width: 100,
      duration: const Duration(milliseconds: 1200),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.15,
      dy: 80,
      image: AssetImage(Cloud.assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(Cloud.assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1000),
    ),
    Cloud(
      color: Cloud.dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(Cloud.assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    Cloud(
      color: Cloud.normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(Cloud.assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1500),
    ),
  ];

  // app bar methods:-----------------------------------------------------------
  // PreferredSizeWidget _buildAppBar() {
  //   return const MainAppBar();
  // }
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

class DraggableHome extends StatefulWidget {
  @override
  _DraggableHomeState createState() => _DraggableHomeState();

  /// Leading: A widget to display before the toolbar's title.
  final Widget? leading;

  /// Title: A Widget to display title in AppBar
  final String title;

  /// Center Title: Allows toggling of title from the center. By default title is in the center.
  final bool centerTitle;

  /// Action: A list of Widgets to display in a row after the title widget.
  final List<Widget>? actions;

  /// Always Show Leading And Action : This make Leading and Action always visible. Default value is false.
  final bool alwaysShowLeadingAndAction;

  /// Always Show Title : This make Title always visible. Default value is false.
  final bool alwaysShowTitle;

  /// Expanded by default.
  bool initialCollapse;
  final double appBarDefaultHeight;

  /// Drawer: Drawers are typically used with the Scaffold.drawer property.
  final Widget? drawer;

  /// Header Expanded Height : Height of the header widget. The height is a double between 0.0 and 1.0. The default value of height is 0.35 and should be less than stretchMaxHeigh
  final double headerExpandedHeight;

  /// Header Widget: A widget to display Header above body.
  final Widget headerWidget;

  /// headerBottomBar: AppBar or toolBar like widget just above the body.

  final Widget? headerBottomBar;

  /// backgroundColor: The color of the Material widget that underlies the entire DraggableHome body.
  final Color? backgroundColor;

  /// appBarColor: The color of the scaffold app bar.
  final Color? appBarColor;

  /// curvedBodyRadius: Creates a border top left and top right radius of body, Default radius of the body is 20.0. For no radius simply set value to 0.
  final double curvedBodyRadius;

  /// body: A widget to Body
  final List<Widget> body;

  /// fullyStretchable: Allows toggling of fully expand draggability of the DraggableHome. Set this to true to allow the user to fully expand the header.
  final bool fullyStretchable;

  /// stretchTriggerOffset: The offset of overscroll required to fully expand the header.
  final double stretchTriggerOffset;

  /// expandedBody: A widget to display when fully expanded as header or expandedBody above body.
  final Widget? expandedBody;

  /// stretchMaxHeight: Height of the expandedBody widget. The height is a double between 0.0 and 0.95. The default value of height is 0.9 and should be greater than headerExpandedHeight
  final double stretchMaxHeight;

  /// floatingActionButton: An object that defines a position for the FloatingActionButton based on the Scaffold's ScaffoldPrelayoutGeometry.
  final Widget? floatingActionButton;

  /// bottomSheet: A persistent bottom sheet shows information that supplements the primary content of the app. A persistent bottom sheet remains visible even when the user interacts with other parts of the app.
  final Widget? bottomSheet;

  /// bottomNavigationBarHeight: This is requires when using custom height to adjust body height. This make no effect on bottomNavigationBar.
  final double? bottomNavigationBarHeight;

  /// bottomNavigationBar: Snack bars slide from underneath the bottom navigation bar while bottom sheets are stacked on top.
  final Widget? bottomNavigationBar;

  /// floatingActionButtonLocation: An object that defines a position for the FloatingActionButton based on the Scaffold's ScaffoldPrelayoutGeometry.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// floatingActionButtonAnimator: Provider of animations to move the FloatingActionButton between FloatingActionButtonLocations.
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  /// physics: How the scroll view should respond to user input. For example, determines how the scroll view continues to animate after the user stops dragging the scroll view.
  final ScrollPhysics? physics;

  /// scrollController: An object that can be used to control the position to which this scroll view is scrolled.
  final ScrollController? scrollController;

  final Function? fullExpandedCallback;

  /// This will create DraggableHome.
  DraggableHome({
    super.key,
    this.fullExpandedCallback,
    this.leading,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.alwaysShowLeadingAndAction = false,
    this.alwaysShowTitle = false,
    required this.initialCollapse,
    this.appBarDefaultHeight = 60,
    this.headerExpandedHeight = 0.35,
    required this.headerWidget,
    this.headerBottomBar,
    this.backgroundColor,
    this.appBarColor,
    this.curvedBodyRadius = 20,
    required this.body,
    this.drawer,
    this.fullyStretchable = false,
    this.stretchTriggerOffset = 200,
    this.expandedBody,
    this.stretchMaxHeight = 0.9,
    this.bottomSheet,
    this.bottomNavigationBarHeight = kBottomNavigationBarHeight,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.physics,
    this.scrollController,
  })  : assert(headerExpandedHeight > 0.0 &&
            headerExpandedHeight < stretchMaxHeight),
        assert(
            !initialCollapse || (initialCollapse && appBarDefaultHeight > 0)),
        assert(
          (stretchMaxHeight > headerExpandedHeight) && (stretchMaxHeight < .95),
        );
}

class _DraggableHomeState extends State<DraggableHome> {
  final BehaviorSubject<bool> isFullyExpanded =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> isFullyCollapsed =
      BehaviorSubject<bool>.seeded(true);

  @override
  void dispose() {
    isFullyExpanded.close();
    isFullyCollapsed.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight =
        widget.appBarDefaultHeight + widget.curvedBodyRadius;

    final double topPadding = MediaQuery.of(context).padding.top;

    final double expandedHeight =
        MediaQuery.of(context).size.height * widget.headerExpandedHeight;
    final double fullyExpandedHeight =
        MediaQuery.of(context).size.height * (widget.stretchMaxHeight);
    return Scaffold(
      backgroundColor:
          widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      drawer: widget.drawer,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            // isFullyCollapsed
            if ((isFullyExpanded.value) &&
                notification.metrics.extentBefore > fullyExpandedHeight) {
              {
                isFullyExpanded.add(false);
                widget.fullExpandedCallback!(false);
              }
            }
            //isFullyCollapsed
            if (notification.metrics.extentBefore >
                expandedHeight - widget.appBarDefaultHeight - 50) {
              if (!(isFullyCollapsed.value)) isFullyCollapsed.add(true);
            } else {
              if ((isFullyCollapsed.value)) isFullyCollapsed.add(false);
            }
          }
          return false;
        },
        child: sliver(context, appBarHeight, fullyExpandedHeight,
            expandedHeight, topPadding),
      ),
      bottomSheet: widget.bottomSheet,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
    );
  }

  CustomScrollView sliver(
    BuildContext context,
    double appBarHeight,
    double fullyExpandedHeight,
    double expandedHeight,
    double topPadding,
  ) {
    return CustomScrollView(
      physics: widget.physics ?? const BouncingScrollPhysics(),
      controller: widget.scrollController,
      slivers: [
        StreamBuilder<List<bool>>(
          stream: CombineLatestStream.list<bool>([
            isFullyCollapsed.stream,
            isFullyExpanded.stream,
          ]),
          builder: (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {
            final List<bool> streams = (snapshot.data ?? [true, false]);
            final bool fullyCollapsed = streams[0];
            final bool fullyExpanded = streams[1];
            final double expandedHeight = 60;
            return SliverAppBar(
              backgroundColor:
                  !fullyCollapsed ? widget.backgroundColor : widget.appBarColor,
              leading: widget.alwaysShowLeadingAndAction
                  ? widget.leading
                  : !fullyCollapsed
                      ? const SizedBox()
                      : widget.leading,
              actions: widget.alwaysShowLeadingAndAction
                  ? widget.actions
                  : !fullyCollapsed
                      ? []
                      : widget.actions,
              elevation: 0,
              pinned: true,
              stretch: true,
              centerTitle: widget.centerTitle,
              title: widget.alwaysShowTitle
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute2(routeName: Routes.home),
                            (Route<dynamic> route) => false);
                      },
                      child: fullyCollapsed
                          ? Text(
                              widget.title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )
                          : const SizedBox())
                  : AnimatedOpacity(
                      opacity: fullyCollapsed ? 1 : 0,
                      duration: const Duration(milliseconds: 100),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              collapsedHeight: appBarHeight,
              expandedHeight:
                  fullyExpanded ? fullyExpandedHeight : expandedHeight,
              flexibleSpace: Stack(
                children: [
                  FlexibleSpaceBar(
                    stretchModes: [StretchMode.blurBackground],
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 0.2),
                      child: fullyExpanded
                          ? (widget.expandedBody ?? widget.headerWidget)
                          : widget.headerWidget,
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: roundedCorner(context),
                  ),
                  Positioned(
                    bottom: 0 + widget.curvedBodyRadius,
                    child: AnimatedContainer(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      curve: Curves.linear,
                      duration: const Duration(milliseconds: 100),
                      height: fullyCollapsed
                          ? 0
                          : fullyExpanded
                              ? 0
                              : kToolbarHeight,
                      width: MediaQuery.of(context).size.width,
                      child: fullyCollapsed
                          ? const SizedBox()
                          : fullyExpanded
                              ? const SizedBox()
                              : widget.headerBottomBar ?? Container(),
                    ),
                  )
                ],
              ),
              stretchTriggerOffset: widget.stretchTriggerOffset,
              onStretchTrigger: widget.fullyStretchable
                  ? () async {
                      if (!fullyExpanded) {
                        isFullyExpanded.add(true);
                        widget.fullExpandedCallback!(true);
                      }
                    }
                  : null,
            );
          },
        ),
        sliverList(context, appBarHeight + topPadding),
      ],
    );
  }

  Container roundedCorner(BuildContext context) {
    return Container(
      height: widget.curvedBodyRadius,
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.curvedBodyRadius),
        ),
      ),
    );
  }

  SliverList sliverList(BuildContext context, double topHeight) {
    final double bottomPadding =
        widget.bottomNavigationBar == null ? 0 : kBottomNavigationBarHeight;
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height -
                    topHeight -
                    bottomPadding,
                color: widget.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
              ),
              Column(
                children: [
                  expandedUpArrow(),
                  //Body
                  ...widget.body
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  StreamBuilder<bool> expandedUpArrow() {
    return StreamBuilder<bool>(
      stream: isFullyExpanded.stream,
      builder: (context, snapshot) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: (snapshot.data ?? false) ? 25 : 0,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: (snapshot.data ?? false) ? null : Colors.transparent,
            ),
          ),
        );
      },
    );
  }
}
