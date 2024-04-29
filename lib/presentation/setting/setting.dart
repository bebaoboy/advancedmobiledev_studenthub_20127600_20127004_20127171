import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:boilerplate/core/widgets/onboarding_screen.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
// import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/profile/profile_student.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_info_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_student_form_store.dart';
import 'package:boilerplate/presentation/setting/widgets/company_account_widget.dart';
import 'package:boilerplate/presentation/setting/widgets/student_account_widget.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_dialog/material_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import '../../di/service_locator.dart';
import '../../domain/entity/account/account.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  //stores:---------------------------------------------------------------------
  // final ThemeStore _themeStore = getIt<ThemeStore>();
  final UserStore _userStore = getIt<UserStore>();

  List<Account> accountList = [];

  @override
  void initState() {
    print("init setting");
    accountList = [
      // guest acc
      if (_userStore.user == null ||
          (_userStore.user != null &&
              _userStore.savedUsers.firstWhereOrNull(
                    (element) => element.email == _userStore.user!.email,
                  ) ==
                  null))
        Account(
            _userStore.user != null && _userStore.user!.email.isNotEmpty
                ? _userStore.user!
                : User(email: "", name: "Guest", roles: [UserType.naught]),
            type: UserType.naught,
            children: [],
            isLoggedIn: true),

      // true acc
      for (var u in _userStore.savedUsers)
        Account(u,
            type: UserType.company,
            children: [
              Account(u,
                  type: UserType.student,
                  isLoggedIn: _userStore.user != null &&
                      u.email == _userStore.user!.email)
            ],
            isLoggedIn:
                _userStore.user != null && u.email == _userStore.user!.email)
    ];

    for (var element in accountList) {
      TreeNode<Account> node = TreeNode<Account>(data: element);
      node.addAll(element.children.map((e) => TreeNode<Account>(data: e)));
      sampleTree.add(node);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  double height = 0;
  double calculateTreeHeight(List<Account> list) {
    double height = 0;
    for (var element in list) {
      height += 75.0;
      if (element.isExpanded) {
        if (element.children.isNotEmpty) {
          // //print(element.name + ": " + height.toString());

          height += calculateTreeHeight(element.children);
        }
      }
      //print("${element.name}: $height");
    }
    return height;
  }

  void calculate(List<Account> list) {
    var h = calculateTreeHeight(accountList);
    // print("TREEEEEEEEHEIGHT: $h");
    setState(() {
      height = h;
    });
  }

  final sampleTree = TreeNode<Account>.root();

  // ignore: unused_field
  TreeViewController? _controller;
  Widget _buildAccountTree() {
    if (height == 0) calculate(accountList);
    return AnimatedContainer(
      height: max(MediaQuery.of(context).size.height * 0.3,
          min(height, MediaQuery.of(context).size.height * 0.5)),
      duration: const Duration(milliseconds: 550),
      curve: Curves.fastOutSlowIn,
      child: Container(
        child: TreeView.simple<Account>(
            tree: sampleTree,
            showRootNode: false,
            expansionIndicatorBuilder: (context, node) =>
                ChevronIndicator.rightDown(
                  tree: node,
                  alignment: Alignment.topRight,
                  color: Theme.of(context).colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
            indentation: const Indentation(style: IndentStyle.none),
            onItemTap: (item) {
              // print(item.data!.name);
              if (item.data == null || _userStore.user == null) return;
              print("tap ${item.data!.type}");

              if (item.data!.type == UserType.company) {
                if (item.data!.isExpanded &&
                    (!item.data!.isLoggedIn ||
                        (item.data!.isLoggedIn &&
                            item.data!.type != _userStore.user!.type))) {
                  showAnimatedDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return ClassicGeneralDialogWidget(
                        contentText:
                            'Do you want to switch account to ${item.data!.user.email} (company)?',
                        negativeText: Lang.get('cancel'),
                        positiveText: 'Yes',
                        onPositiveClick: () async {
                          Navigator.of(context).pop();
                          if (item.data!.user.companyProfile == null) {
                            showAnimatedDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return ClassicGeneralDialogWidget(
                                  contentText:
                                      '${item.data!.user.email} dont have company profile? Create now?',
                                  negativeText: Lang.get('cancel'),
                                  positiveText: 'Yes',
                                  onPositiveClick: () async {
                                    Navigator.of(context).pop();

                                    Navigator.of(context).push(
                                        MaterialPageRoute2(
                                            routeName: Routes.profile));
                                  },
                                  onNegativeClick: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              animationType: DialogTransitionType.size,
                              curve: Curves.fastOutSlowIn,
                              duration: const Duration(seconds: 1),
                            );
                          } else {
                            switchAccount(item.data!);
                          }
                        },
                        onNegativeClick: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    animationType: DialogTransitionType.size,
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(seconds: 1),
                  );
                }
                setState(() {
                  item.data!.isExpanded = !item.data!.isExpanded;
                });
              } else if (item.data!.type == UserType.student) {
                if (item.data!.isExpanded &&
                    (!item.data!.isLoggedIn ||
                        (item.data!.isLoggedIn &&
                            item.data!.type != _userStore.user!.type))) {
                  showAnimatedDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext ctx) {
                      return ClassicGeneralDialogWidget(
                        contentText:
                            'Do you want to switch account to ${item.data!.user.email} (student)?',
                        negativeText: Lang.get('cancel'),
                        positiveText: 'Yes',
                        onPositiveClick: () async {
                          Navigator.of(ctx).pop();
                          if (item.data!.user.studentProfile == null) {
                            showAnimatedDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext ctx2) {
                                return ClassicGeneralDialogWidget(
                                  contentText:
                                      '${item.data!.user.email} dont have student profile? Create now?',
                                  negativeText: Lang.get('cancel'),
                                  positiveText: 'Yes',
                                  onPositiveClick: () async {
                                    Navigator.of(ctx2).pop();
                                    setState(() {
                                      loading = true;
                                    });

                                    final ProfileStudentStore infoStore =
                                        getIt<ProfileStudentStore>();

                                    await infoStore.getTechStack();
                                    await infoStore.getSkillset();
                                    setState(() {
                                      loading = false;
                                    });

                                    Navigator.of(context)
                                        .push(MaterialPageRoute2(
                                            child: ProfileStudentScreen(
                                      fullName: item.data!.user.name,
                                    )));
                                  },
                                  onNegativeClick: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              animationType: DialogTransitionType.size,
                              curve: Curves.fastOutSlowIn,
                              duration: const Duration(seconds: 1),
                            );
                          } else {
                            switchAccount(item.data!);
                          }
                        },
                        onNegativeClick: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    animationType: DialogTransitionType.size,
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(seconds: 1),
                  );
                }
              }
              calculate(accountList);
            },
            onTreeReady: (controller) {
              _controller = controller;
              controller.expandAllChildren(sampleTree);
            },
            builder: (context, node) => _getComponent(account: node.data!)),
        //     TreeView(
        //   startExpanded: true,
        //   children: _getChildAccount(accountList),
        // )
      ),
    );
  }

  // List<Widget> _getChildAccount(List<Account> accounts) {
  //   return accounts.map((a) {
  //     if (a.type == UserType.company) {
  //       return TreeViewChild(
  //         parent: _getComponent(account: a),
  //         children: _getChildAccount(a.children),
  //       );
  //     }
  //     return Container(
  //       margin: const EdgeInsets.only(left: 10.0),
  //       child: _getComponent(account: a),
  //     );
  //   }).toList();
  // }

  /// switch from student to company
  switchAccount(Account account) async {
    print("switch account");
    account.isLoggedIn = true;
    // await _userStore.logout();
    if (_userStore.user != null) {
      _userStore.user!.type = account.type;
      if (_userStore.user != null) {
        SharedPreferences.getInstance().then(
          (value) {
            value.setString(Preferences.current_user_role,
                _userStore.user!.type.name.toLowerCase().toString());
          },
        );
      }

      DeviceUtils.hideKeyboard(context);
      Future.delayed(const Duration(seconds: 1), () {
        // _userStore.login(
        //     account.user.email, "", account.type, account.user.roles!,
        //     fastSwitch: true);
        _userStore.success = true;
        Navigator.of(context).pushReplacement(MaterialPageRoute2(
          routeName: Routes.home,
        ));
      });
    }
  }

  Widget _getComponent({required Account account}) {
    if (account.type != UserType.company) {
      return StudentAccountWidget(
        isLoggedIn: account.isLoggedIn,
        name: account,
        isLoggedInProfile: account.isLoggedIn &&
            _userStore.user != null &&
            account.type == _userStore.user!.type,

        // onTap: () => switchAccount(account),
      );
    } else {
      return CompanyAccountWidget(
        isLoggedIn: account.isLoggedIn,
        isLoggedInProfile: account.isLoggedIn &&
            _userStore.user != null &&
            account.type == _userStore.user!.type,
        name: account,
        // onTap: () {
        //   //print(account.name);

        //   // setState(() {
        //   //   account.isExpanded = !account.isExpanded;
        //   //   calculate(accountList);
        //   // });
        // },
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(Lang.get("profile_text")),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      IconButton(onPressed: () => {}, icon: const Icon(Icons.search))
    ];
  }

  bool loading = false;

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return loading
        ? const LoadingScreen()
        : Material(
            child: Stack(children: <Widget>[
              Container(child: _buildRightSide()),
            ]),
          );
  }

  Widget _buildRightSide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(fit: FlexFit.loose, child: _buildAccountTree()),
            const Divider(
              height: 3,
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
                onTap: () async {
                  //int n = Random().nextInt(3);
                  if (_userStore.user != null &&
                      _userStore.user!.type != UserType.naught) {
                    if (_userStore.user!.type == UserType.company) {
                      if (_userStore.user!.companyProfile == null) {
                        showAnimatedDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return ClassicGeneralDialogWidget(
                              contentText:
                                  'User ${_userStore.user!.email} chưa có profile Company. Tạo ngay?',
                              negativeText: Lang.get('cancel'),
                              positiveText: 'Yes',
                              onPositiveClick: () {
                                Navigator.of(context).pop();

                                Navigator.of(context).push(MaterialPageRoute2(
                                    routeName: Routes.profile));
                                return;
                              },
                              onNegativeClick: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                          animationType: DialogTransitionType.size,
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(seconds: 1),
                        );
                      } else {
                        navigate(
                            context,
                            _userStore.user != null &&
                                    _userStore.user!.type == UserType.company
                                ? Routes.viewProfileCompany
                                : Routes.viewProfileStudent);
                      }
                    } else {
                      if (_userStore.user!.studentProfile == null) {
                        showAnimatedDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext ctx) {
                            return ClassicGeneralDialogWidget(
                              contentText:
                                  'User ${_userStore.user!.email} chưa có profile Student. Tạo ngay?',
                              negativeText: Lang.get('cancel'),
                              positiveText: 'Yes',
                              onPositiveClick: () async {
                                Navigator.of(ctx).pop();
                                final ProfileStudentStore infoStore =
                                    getIt<ProfileStudentStore>();

                                await infoStore.getTechStack();
                                await infoStore.getSkillset();

                                Navigator.of(context).push(MaterialPageRoute2(
                                    routeName: Routes.profileStudent));
                                return;
                              },
                              onNegativeClick: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                          animationType: DialogTransitionType.size,
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(seconds: 1),
                        );
                      } else {
                        try {
                          setState(() {
                            loading = true;
                          });
                        } catch (e) {
                          loading = true;
                        }
                        try {
                          if (_userStore.studentId != null) {
                            final ProfileStudentStore infoStore =
                                getIt<ProfileStudentStore>();

                            infoStore.setStudentId(
                                _userStore.user!.studentProfile!.objectId!);
                            await infoStore.getInfo().then(
                                  (value) {},
                                );
                            final ProfileStudentFormStore formStore =
                                getIt<ProfileStudentFormStore>();
                            await formStore.getProfileStudent(
                                _userStore.user!.studentProfile!.objectId!);
                          }
                        } catch (e) {
                          ///
                        }
                        try {
                          setState(() {
                            loading = false;
                          });
                          navigate(
                              context,
                              _userStore.user != null &&
                                      _userStore.user!.type == UserType.company
                                  ? Routes.viewProfileCompany
                                  : Routes.viewProfileStudent);
                        } catch (e) {
                          loading = false;
                        }
                      }
                    }
                  }
                },
                leading: const Icon(Icons.person),
                title: Text(
                  Lang.get('profile_text'),
                )),
            const Divider(
              height: 3,
            ),
            ListTile(
                leading: const Icon(Icons.settings),
                onTap: () {
                  Navigator.push(context,
                          MaterialPageRoute2(child: const RealSettingPage()))
                      .then(
                    (value) {
                      setState(() {});
                    },
                  );
                },
                title: Text(
                  Lang.get('setting_text'),
                )),
            const Divider(
              height: 3,
            ),
            ListTile(
                onTap: () async {
                  await Navigator.push(
                    context,
                    ModalSheetRoute(
                      builder: (context) => OnboardingSheet(
                        height: MediaQuery.of(context).size.height,
                        onSheetDismissed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool(Preferences.first_time, true);
                        },
                      ),
                    ),
                  );
                },
                leading: const Icon(Icons.help_outline),
                title: Text(
                  Lang.get('about'),
                )),
            ListTile(
                onTap: () {
                  showAnimatedDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return ClassicGeneralDialogWidget(
                        contentText: Lang.get("logout_confirm"),
                        negativeText: Lang.get('cancel'),
                        positiveText: 'OK',
                        onPositiveClick: () {
                          _userStore.logout();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute2(routeName: Routes.login),
                              (Route<dynamic> route) => false);
                        },
                        onNegativeClick: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    animationType: DialogTransitionType.size,
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(seconds: 1),
                  );
                },
                leading: const Icon(Icons.logout),
                title: Text(
                  Lang.get('logout'),
                )),
          ],
        ),
      ),
    );
  }

  Widget navigate(BuildContext context, String route) {
    Future.delayed(const Duration(milliseconds: 0), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute2(routeName: route), (_) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------

  @override
  void dispose() {
    // ToDO: implement dispose
    super.dispose();
  }
}

class RealSettingPage extends StatefulWidget {
  const RealSettingPage({super.key});

  @override
  State<RealSettingPage> createState() => _RealSettingPageState();
}

class _RealSettingPageState extends State<RealSettingPage> {
  final LanguageStore _languageStore = getIt<LanguageStore>();

  final ThemeStore _themeStore = getIt<ThemeStore>();
  @override
  Widget build(BuildContext context) {
    showDialogModified<T>(
        {required BuildContext context, required Widget child}) {
      showDialog<T>(
        context: context,
        builder: (BuildContext context) => child,
      ).then<void>((T? value) {
        // The value passed to Navigator.pop() or null.
      });
    }

    buildLanguageDialog() {
      showDialogModified<String>(
        context: context,
        child: MaterialDialog(
          borderRadius: 5.0,
          enableFullWidth: true,
          title: Text(
            Lang.get('home_tv_choose_language'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          headerColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          closeButtonColor: Colors.white,
          enableCloseButton: true,
          enableBackButton: false,
          onCloseButtonClicked: () {
            Navigator.of(context).pop();
          },
          children: _languageStore.supportedLanguages
              .map(
                (object) => ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.all(0.0),
                  title: Text(
                    object.language,
                    style: TextStyle(
                      color: _languageStore.locale == object.locale
                          ? Theme.of(context).primaryColor
                          : _themeStore.darkMode
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // change user language based on selected locale
                    _languageStore.changeLanguage(object.locale);
                  },
                ),
              )
              .toList(),
        ),
      );
    }

    Widget buildLanguageButton() {
      return ListTile(
        leading: const Icon(
          Icons.language,
        ),
        title: Text(Lang.get("home_tv_choose_language")),
        onTap: () {
          buildLanguageDialog();
        },
      );
    }

    Widget buildThemeButton() {
      return Observer(
        builder: (context) {
          return ListTile(
            leading: Icon(
              _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
            ),
            title: Text(Lang.get("home_tv_choose_theme")),
            onTap: () {
              _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
            },
          );
        },
      );
    }

    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(Lang.get("setting_text")),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildThemeButton(),
            buildLanguageButton(),
          ],
        ),
      );
    });
  }
}
