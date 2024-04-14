import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ForgetPasswordSentScreen extends StatefulWidget {
  const ForgetPasswordSentScreen({super.key});

  @override
  _ForgetPasswordSentScreenState createState() =>
      _ForgetPasswordSentScreenState();
}

class _ForgetPasswordSentScreenState extends State<ForgetPasswordSentScreen> {
  //stores:---------------------------------------------------------------------
  // final ThemeStore _themeStore = getIt<ThemeStore>();

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _buildLeftSide(),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildRightSide(),
                    ),
                  ],
                )
              : Container(child: _buildRightSide()),
        ],
      ),
    );
  }

  Widget _buildLeftSide() {
    return SizedBox.expand(
      child: Image.asset(
        Assets.carBackground,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      controller: ScrollController(),
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const EmptyAppBar(),
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  AutoSizeText(
                    Lang.get('forget_password_sent'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    minFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 34.0),
                  // _buildSignInButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSignInButton() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 50),
  //     child: RoundedButtonWidget(
  //       buttonText: "OK",
  //       buttonColor: Theme.of(context).colorScheme.primary,
  //       textColor: Colors.white,
  //       onPressed: () async {
  //         Navigator.of(context).pushReplacement(
  //             MaterialPageRoute2(routeName: Routes.login));
  //       },
  //     ),
  //   );
  // }

  Widget navigate(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute2(routeName: Routes.forgetPasswordChangePassword),
        (Route<dynamic> route) => false);
// =======
//     // SharedPreferences.getInstance().then((prefs) {
//     //   prefs.setBool(Preferences.is_logged_in, true);
//     // });

//     Future.delayed(const Duration(milliseconds: 0), () {
//       //print("LOADING = $loading");
//       Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute2(routeName: Routes.home),
//           (Route<dynamic> route) => false);
//     });
//

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  // ignore: unused_element
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          Toastify.show(
            context,
            "",
            message,
            aboveNavbar: !NavbarNotifier2.isNavbarHidden,
            ToastificationType.error,
            () {},
          );
        }
      });
    }

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    super.dispose();
  }
}
