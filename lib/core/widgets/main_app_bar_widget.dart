import 'dart:math';

import 'package:badges/badges.dart';
import 'package:boilerplate/core/widgets/swipable_page_route/swipeable_page_route.dart';

import 'package:boilerplate/core/widgets/material_dialog/dialog_buttons.dart';
import 'package:boilerplate/core/widgets/material_dialog/dialog_widget.dart';
import 'package:boilerplate/core/widgets/material_dialog/navigator.dart';
import 'package:boilerplate/core/widgets/shared_preference_view.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/myMockData.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MainAppBar(
      {super.key, this.isHomePage = true, this.theme = true, this.name = ""});
  final bool isHomePage;
  final bool theme;
  final String name;
  @override
  State<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => Size(
      0.0,
      NavigationService.navigatorKey.currentContext != null
          ? MediaQuery.of(NavigationService.navigatorKey.currentContext!)
                      .orientation ==
                  Orientation.landscape
              ? 30
              : 60
          : 60);
}

class _MainAppBarState extends State<MainAppBar> {
  //stores:---------------------------------------------------------------------
  // final ThemeStore _themeStore = getIt<ThemeStore>();
  final UserStore _userStore = getIt<UserStore>();
  bool isDark = false;

  Widget _buildProfileButton() {
    return IconButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute2(routeName: Routes.setting));
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => SettingScreen()));
      },
      icon: const Icon(Icons.account_circle, size: 25),
    );
  }

  // Widget _buildLanguageButton() {
  //   return IconButton(
  //     onPressed: () {
  //       _buildLanguageDialog();
  //     },
  //     icon: const Icon(
  //       Icons.language,
  //     ),
  //   );
  // }

  // _buildLanguageDialog() {
  //   _showDialog<String>(
  //     context: context,
  //     child: MaterialDialog(
  //       borderRadius: 5.0,
  //       enableFullWidth: true,
  //       title: Text(
  //         Lang.get('home_tv_choose_language'),
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontSize: 16.0,
  //         ),
  //       ),
  //       headerColor: Theme.of(context).primaryColor,
  //       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //       closeButtonColor: Colors.white,
  //       enableCloseButton: true,
  //       enableBackButton: false,
  //       onCloseButtonClicked: () {
  //         Navigator.of(context).pop();
  //       },
  //       children: _languageStore.supportedLanguages
  //           .map(
  //             (object) => ListTile(
  //               dense: true,
  //               contentPadding: const EdgeInsets.all(0.0),
  //               title: Text(
  //                 object.language,
  //                 style: TextStyle(
  //                   color: _languageStore.locale == object.locale
  //                       ? Theme.of(context).primaryColor
  //                       : _themeStore.darkMode
  //                           ? Colors.white
  //                           : Colors.black,
  //                 ),
  //               ),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 // change user language based on selected locale
  //                 _languageStore.changeLanguage(object.locale);
  //               },
  //             ),
  //           )
  //           .toList(),
  //     ),
  //   );
  // }

  // _showDialog<T>({required BuildContext context, required Widget child}) {
  //   showDialog<T>(
  //     context: context,
  //     builder: (BuildContext context) => child,
  //   ).then<void>((T? value) {
  //     // The value passed to Navigator.pop() or null.
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // return DarkTransition(
    //     isDark: isDark,
    //     offset: Offset(MediaQuery.of(context).size.width * 0.7, 20),
    //     childBuilder: (context, x) =>
    return kIsWeb
        ? AppBar(
            // automaticallyImplyLeading: widget.showBackButton,
            scrolledUnderElevation: 0,
            leadingWidth: 30,
            titleSpacing: 0,
            toolbarHeight: 250,
            // flexibleSpace: Container(child: Column(
            // children: [
            //   Container(height: 900, child: Center(child: Text(Lang.get('ooooooooooooooooooooo"),),)
            // ],)),
            title: Container(
                margin: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    showRandomBadge();
                  },
                  onLongPress: () {
                    Navigator.of(context).push(MaterialPageRoute2(
                        child: const SharedPreferenceView()));
                  },
                  onDoubleTap: () {
                    Navigator.of(context).push(MaterialPageRoute2(
                        routeName: Routes.viewProjectProposalsCard,
                        arguments: myProjects[0]));
                  },
                  child: Text((_userStore.user != null &&
                              _userStore.user!.type == UserType.company
                          ? "© "
                          : "") +
                      (widget.name.isNotEmpty
                          ? widget.name
                          : Lang.get('appbar_title'))),
                )),
            actions: [
              // _buildLanguageButton(),
              // _buildThemeButton(),
              // LanguageButton(),
              // if (widget.theme) ThemeButton(),
              _buildProfileButton(),
              // _buildLogoutButton(),
            ],
            // )
          )
        : MorphingAppBar(
            leadingWidth: 30,
            titleSpacing: 0,
            toolbarHeight: 250,
            // flexibleSpace: Container(child: Column(
            // children: [
            //   Container(height: 900, child: Center(child: Text(Lang.get('ooooooooooooooooooooo"),),)
            // ],)),
            title: Container(
                margin: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.of(context).pushAndRemoveUntil(
                    //     MaterialPageRoute2(routeName: Routes.home),
                    //     (Route<dynamic> route) => false);
                    // Navigator.of(context)
                    //     .push(MaterialPageRoute2(child: const Welcome2()));

                    AnimatedDialog.showAnimatedDialog(
                      context,
                      onClose: (p0) => print("hiii"),
                      contentTextAlign: TextAlign.center,
                      contentText: 'You can\'t undo this',
                      title: "Are you sure?",
                      color: Colors.white,
                      dialogWidth: kIsWeb ? 0.3 : null,
                      lottieBuilder: Lottie.asset(
                        'assets/animations/loading_animation.json',
                        fit: BoxFit.contain,
                      ),
                      positiveText: "Delete",
                      positiveIcon: Icons.delete_forever,
                      onPositiveClick: (context) {
                        DialogNavigator.of(context).push(
                          AnimatedDialog.getMaterialDialog(
                              // msgAlign: TextAlign.center,
                              title: "Delete done!",
                              // dialogWidth: kIsWeb ? 0.3 : null,
                              actions: [
                                IconsButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(['Test', 'List']);
                                  },
                                  color: Colors.blue,
                                  text: 'OK',
                                  iconData: Icons.cloud_done_sharp,
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  iconColor: Colors.white,
                                ),
                              ]),
                        );
                      },
                      negativeText: "Cancel",
                      negativeIcon: Icons.close_sharp,
                      onNegativeClick: (context) {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                  onDoubleTap: () {
                    showRandomBadge();
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.of(context).push(MaterialPageRoute2(
                          routeName: Routes.viewProjectProposalsCard,
                          arguments: myProjects[0]));
                    });
                    // AnimatedDialog.showBottomAnimatedDialog(
                    //   context,
                    //   onClose: (p0) => print("hiii"),
                    //   contentTextAlign: TextAlign.center,
                    //   contentText: 'You can\'t undo this',
                    //   title: "Are you sure?",
                    //   color: Colors.white,
                    //   dialogWidth: kIsWeb ? 0.3 : null,
                    //   lottieBuilder: Lottie.asset(
                    //     'assets/animations/loading_animation.json',
                    //     fit: BoxFit.contain,
                    //   ),
                    //   positiveText: "Delete",
                    //   positiveIcon: Icons.delete_forever,
                    //   onPositiveClick: (context) {
                    //     AnimatedDialog.showBottomMaterialDialog(
                    //       onClose: (value) => Navigator.of(context).pop(),
                    //       context: context,
                    //       // msgAlign: TextAlign.center,
                    //       title: "Delete done!",
                    //       // dialogWidth: kIsWeb ? 0.3 : null,
                    //       actions: [
                    //         IconsButton(
                    //           onPressed: () {
                    //             Navigator.of(context).pop(['Test', 'List']);
                    //           },
                    //           color: Colors.blue,
                    //           text: 'OK',
                    //           iconData: Icons.cloud_done_sharp,
                    //           textStyle: const TextStyle(color: Colors.white),
                    //           iconColor: Colors.white,
                    //         ),
                    //         IconsButton(
                    //           onPressed: () {
                    //             Navigator.of(context).pop(['Test', 'List']);
                    //           },
                    //           color: Colors.blue,
                    //           text: 'OK',
                    //           iconData: Icons.cloud_done_sharp,
                    //           textStyle: const TextStyle(color: Colors.white),
                    //           iconColor: Colors.white,
                    //         ),
                    //       ],
                    //     );
                    //   },
                    //   negativeText: "Cancel",
                    //   negativeIcon: Icons.close_sharp,
                    //   onNegativeClick: (context) {
                    //     Navigator.of(context).pop(['Test', 'List']);
                    //   },
                    // );
                  },
                  onLongPress: () {
                    Navigator.of(context).push(MaterialPageRoute2(
                        child: const SharedPreferenceView()));
                  },
                  child: Text((_userStore.user != null &&
                              _userStore.user!.type == UserType.company
                          ? "© "
                          : "") +
                      (widget.name.isNotEmpty
                          ? widget.name
                          : Lang.get('appbar_title'))),
                )),
            actions: [
              // _buildLanguageButton(),
              // _buildThemeButton(),
              // LanguageButton(),
              // if (widget.theme) ThemeButton(),
              _buildProfileButton(),
              // _buildLogoutButton(),
            ],
            // )
          );
  }

  showRandomBadge() {
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
    var animations = [
      BadgeAnimation.fade,
      BadgeAnimation.rotation,
      BadgeAnimation.scale,
      BadgeAnimation.size,
      BadgeAnimation.slide
    ];
    int r = Random().nextInt(100);
    var b = Random().nextBool();
    NavbarNotifier2.updateBadge(
        0,
        NavbarBadge(
            badgeText: "${b ? r : ""}",
            color: b
                ? null
                : themeColorSeed[Random().nextInt(themeColorSeed.length)],
            showBadge: Random().nextInt(5) > 1,
            badgeAnimation: animations[Random().nextInt(animations.length)](),
            animationDuration:
                Duration(milliseconds: (Random().nextInt(5) + 5) * 600)));
    b = Random().nextBool();
    NavbarNotifier2.updateBadge(
        1,
        NavbarBadge(
            badgeText: "${b ? r : ""}",
            color: b
                ? null
                : themeColorSeed[Random().nextInt(themeColorSeed.length)],
            showBadge: Random().nextInt(5) > 1,
            badgeAnimation: animations[Random().nextInt(animations.length)](),
            animationDuration:
                Duration(milliseconds: (Random().nextInt(5) + 5) * 600)));
    b = Random().nextBool();
    NavbarNotifier2.updateBadge(
        2,
        NavbarBadge(
            badgeText: "${b ? r : ""}",
            color: b
                ? null
                : themeColorSeed[Random().nextInt(themeColorSeed.length)],
            showBadge: Random().nextInt(5) > 1,
            badgeAnimation: animations[Random().nextInt(animations.length)](),
            animationDuration:
                Duration(milliseconds: (Random().nextInt(5) + 5) * 600)));
    b = Random().nextBool();
    NavbarNotifier2.updateBadge(
        3,
        NavbarBadge(
            badgeText: "${b ? r : ""}",
            color: b
                ? null
                : themeColorSeed[Random().nextInt(themeColorSeed.length)],
            showBadge: Random().nextInt(5) > 1,
            badgeAnimation: animations[Random().nextInt(animations.length)](),
            animationDuration:
                Duration(milliseconds: (Random().nextInt(5) + 5) * 600)));
  }
}
