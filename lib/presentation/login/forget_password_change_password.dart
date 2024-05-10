import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/forget_password_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:toastification/toastification.dart';

import '../../di/service_locator.dart';

class ForgetPasswordChangePasswordScreen extends StatefulWidget {
  const ForgetPasswordChangePasswordScreen({super.key});

  @override
  _ForgetPasswordChangePasswordScreenState createState() =>
      _ForgetPasswordChangePasswordScreenState();
}

class _ForgetPasswordChangePasswordScreenState
    extends State<ForgetPasswordChangePasswordScreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final ForgetPasswordStore _formStore = getIt<ForgetPasswordStore>();
  final UserStore _userStore = getIt<UserStore>();

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
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
          Observer(
            builder: (context) {
              return _formStore.changePassSuccess
                  ? navigate(context)
                  : _showErrorMessage(_formStore.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: loading,
                // child: CustomProgressIndicatorWidget(),
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        loading = false;
                      });
                    },
                    child: const LoadingScreen()),
              );
            },
          )
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
                    Lang.get('forget_password_welcome_back'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    minFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AutoSizeText(
                    Lang.get('forget_password_main_text3'),
                    style: const TextStyle(fontSize: 13),
                    minFontSize: 10,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Image.asset(
                  //   'assets/images/img_login.png',
                  //   scale: 1.2,
                  // ),
                  const SizedBox(height: 44.0),
                  // _buildUserIdField(),
                  _buildNewPasswordField(),
                  _buildConfirmNewPasswordField(),
                  // _buildForgotPasswordButton(),
                  const SizedBox(height: 44.0),
                  _buildSignInButton(),
                  // RichText(
                  //   text: TextSpan(
                  //     text: Lang.get('signup_sign_up_prompt'),
                  //     style: TextStyle(
                  //         fontSize: 18,
                  //         color: _themeStore.darkMode
                  //             ? Colors.white
                  //             : Colors.black),
                  //     children: <TextSpan>[
                  //       TextSpan(
                  //           text:
                  //               " ${Lang.get('signup_sign_up_prompt_action')}",
                  //           style: TextStyle(
                  //               color: Theme.of(context).colorScheme.primary,
                  //               fontWeight: FontWeight.w600),
                  //           recognizer: TapGestureRecognizer()
                  //             ..onTap = () {
                  //               Navigator.of(context).pop();
                  //             }),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          // Align(
          //   heightFactor: 2,
          //   alignment: Alignment.bottomCenter,
          //   child: Column(
          //     children: [
          //       _buildFooterText(),
          //       const SizedBox(
          //         height: 14,
          //       ),
          //       _buildSignUpButton(),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('forget_password_et_user_password'),
          isObscure: true,
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _newPasswordController,
          focusNode: _passwordFocusNode,
          errorText: _formStore.formErrorStore.newPassword == null
              ? null
              : Lang.get(_formStore.formErrorStore.newPassword),
          onChanged: (value) {
            _formStore.setNewPassword(_newPasswordController.text);
          },
        );
      },
    );
  }

  Widget _buildConfirmNewPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('forget_password_et_user_password_confirm'),
          isObscure: true,
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _confirmNewPasswordController,
          errorText: _formStore.formErrorStore.confirmNewPassword == null
              ? null
              : Lang.get(_formStore.formErrorStore.confirmNewPassword),
          onChanged: (value) {
            _formStore
                .setNewConfirmPassword(_confirmNewPasswordController.text);
          },
        );
      },
    );
  }

  Widget _buildSignInButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: RoundedButtonWidget(
          buttonText: Lang.get('forget_password_change_password'),
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          onPressed: () async {
            setState(() {
              loading = true;
            });
            if (_formStore.canResetPassword) {
              DeviceUtils.hideKeyboard(context);
              _formStore.changePassword();
            } else {
              _showErrorMessage(Lang.get('login_error_missing_fields'));
            }
          }),
    );
  }

  Widget navigate(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      //print("LOADING = $loading");
      loading = false;
      _userStore.shouldChangePass = false;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute2(routeName: Routes.forgetPasswordDone), (_) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          loading = false;
        });
        if (message.isNotEmpty) {
          Toastify.show(
              context,
              "",
              message,
              aboveNavbar: !NavbarNotifier2.isNavbarHidden,
              ToastificationType.error,
              () {});
        }
      });
    }

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
