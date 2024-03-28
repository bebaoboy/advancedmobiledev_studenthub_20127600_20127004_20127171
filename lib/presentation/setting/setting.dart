import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
// import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/setting/widgets/company_account_widget.dart';
import 'package:boilerplate/presentation/setting/widgets/student_account_widget.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../constants/strings.dart';
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
    var companyAccounts = _userStore.savedUsers.where(
      (element) => element.type == UserType.company,
    );
    accountList = [
      if (_userStore.user != null &&
          _userStore.savedUsers.firstWhereOrNull(
                (element) => element.email == _userStore.user!.email,
              ) ==
              null)
        Account(_userStore.user!, children: [], isLoggedIn: true),
      for (var u in companyAccounts)
        Account(u,
            children: List.from(_userStore.savedUsers
                .where(
                  (element) => element.type == UserType.student,
                )
                .map(
                  (e) => Account(e, children: []),
                )),
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
    //print("TREEEEEEEEHEIGHT: $h");
    if (h != height) {
      setState(() {
        height = h;
      });
    }
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
                  color: Colors.blue[700],
                  padding: const EdgeInsets.all(8),
                ),
            indentation: const Indentation(style: IndentStyle.none),
            onItemTap: (item) {
              // print(item.data!.name);
              print("tap");
              setState(() {
                item.data!.isExpanded = !item.data!.isExpanded;
                calculate(accountList);
              });
              if (item.data!.user.type == UserType.company) {
                switchAccount(item.data!);
              }
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

  switchAccount(Account account) {
    if (!account.isLoggedIn) {
      account.isLoggedIn = true;
      _userStore.logout();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute2(routeName: Routes.login),
          (Route<dynamic> route) => false);
      DeviceUtils.hideKeyboard(context);
      Future.delayed(Duration(seconds: 1), () {
        _userStore.login(account.user.email, "", account.user.type,
            fastSwitch: true);
      });
    }
  }

  Widget _getComponent({required Account account}) {
    if (account.user.type == UserType.company) {
      return CompanyAccountWidget(
        isLoggedIn: account.isLoggedIn,
        name: account,
        onTap: () {
          //print(account.name);

          setState(() {
            account.isExpanded = !account.isExpanded;
            calculate(accountList);
          });
        },
      );
    } else {
      return StudentAccountWidget(
        isLoggedIn: _userStore.user != null &&
            account.user.email == _userStore.user!.email,
        name: account,
        onTap: () => switchAccount(account),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(Strings.appName),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      IconButton(onPressed: () => {}, icon: const Icon(Icons.search))
    ];
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
      child: Stack(children: <Widget>[
        Container(child: _buildRightSide()),
      ]),
    );
  }

  Widget _buildRightSide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
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
                onTap: () {
                  //int n = Random().nextInt(3);
                  navigate(context, Routes.profileStep2);
                },
                leading: const Icon(Icons.person),
                title: Text(
                  Lang.get('profile_text'),
                )),
            const Divider(
              height: 3,
            ),
            ListTile(
                onTap: () => navigate(context, Routes.setting),
                leading: const Icon(Icons.settings),
                title: Text(
                  Lang.get('setting_text'),
                )),
            const Divider(
              height: 3,
            ),
            ListTile(
                onTap: () {
                  _userStore.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute2(routeName: Routes.login),
                      (Route<dynamic> route) => false);
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
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute2(routeName: route));
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
