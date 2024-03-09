import 'dart:math';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/setting/widgets/company_account_widget.dart';
import 'package:boilerplate/presentation/setting/widgets/student_account_widget.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:tree_view_flutter/tree_view_flutter.dart';

import '../../constants/strings.dart';
import '../../di/service_locator.dart';
import '../../domain/entity/account/account.dart';

enum AccountType { company, student }

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  //stores:---------------------------------------------------------------------
  // final ThemeStore _themeStore = getIt<ThemeStore>();
  final UserStore _userStore = getIt<UserStore>();

  List<Account> accountList = [
    Account(AccountType.company, 'Hai Pham',
        [Account(AccountType.student, 'Hai Pham Student', [])])
  ];

  @override
  void initState() {
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

  Widget _buildAccountTree() {
    return Expanded(
      child: SizedBox(
        height: 150,
        child: TreeView(
          startExpanded: true,
          children: _getChildAccount(accountList),
        ),
      ),
    );
  }

  List<Widget> _getChildAccount(List<Account> accounts) {
    return accounts.map((a) {
      if (a.type == AccountType.company) {
        return TreeViewChild(
          parent: _getComponent(account: a),
          children: _getChildAccount(a.children),
        );
      }
      return Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: _getComponent(account: a),
      );
    }).toList();
  }

  Widget _getComponent({required Account account}) {
    if (account.type == AccountType.company) {
      return CompanyAccountWidget(name: account.name);
    } else {
      return StudentAccountWidget(name: account.name);
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
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(child: _buildAccountTree()),
            const Divider(
              height: 3,
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
                onTap: () {
                  //int n = Random().nextInt(3);
                  navigate(
                      context, Routes.profileStep2);
                },
                leading: const Icon(Icons.person),
                title: Text(
                  AppLocalizations.of(context).translate('profile_text'),
                )),
            const Divider(
              height: 3,
            ),
            ListTile(
                onTap: () => navigate(context, Routes.setting),
                leading: const Icon(Icons.settings),
                title: Text(
                  AppLocalizations.of(context).translate('setting_text'),
                )),
            const Divider(
              height: 3,
            ),
            ListTile(
                onTap: () => _userStore.logout(),
                leading: const Icon(Icons.logout),
                title: Text(
                  AppLocalizations.of(context).translate('logout_text'),
                )),
          ],
        ),
      ),
    );
  }

  Widget navigate(BuildContext context, String route) {
    Future.delayed(const Duration(milliseconds: 0), () {
      Navigator.of(context)
        ..pushReplacement(MaterialPageRoute2(routeName: route));
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title:
                AppLocalizations.of(context).translate('profile_change_error'),
            duration: const Duration(seconds: 3),
          ).show(context);
        }
      });
    }

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
