import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../di/service_locator.dart';

class ForgetPasswordChangePasswordcreen extends StatefulWidget {
  const ForgetPasswordChangePasswordcreen({super.key});

  @override
  _ForgetPasswordChangePasswordcreenState createState() =>
      _ForgetPasswordChangePasswordcreenState();
}

class _ForgetPasswordChangePasswordcreenState
    extends State<ForgetPasswordChangePasswordcreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
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
              return _userStore.success
                  ? navigate(context)
                  : _showErrorMessage(_formStore.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _userStore.isLoading || loading,
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
                  _buildPasswordField(),
                  _buildPasswordConfirmField(),
                  // _buildForgotPasswordButton(),
                  const SizedBox(height: 44.0),
                  _buildSignInButton(),
                  RichText(
                    text: TextSpan(
                      text: Lang.get('signup_sign_up_prompt'),
                      style: TextStyle(
                          fontSize: 18,
                          color: _themeStore.darkMode
                              ? Colors.white
                              : Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text:
                                " ${Lang.get('signup_sign_up_prompt_action')}",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pop();
                              }),
                      ],
                    ),
                  ),
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


  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('forget_password_et_user_password'),
          isObscure: true,
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: _formStore.formErrorStore.password == null
              ? null
              : Lang.get(_formStore.formErrorStore.password),
          onChanged: (value) {
            _formStore.setPassword(_passwordController.text);
          },
        );
      },
    );
  }

  Widget _buildPasswordConfirmField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('forget_password_et_user_password_confirm'),
          isObscure: true,
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _passwordConfirmController,
          errorText: _formStore.formErrorStore.confirmPassword == null
              ? null
              : Lang.get(_formStore.formErrorStore.confirmPassword),
          onChanged: (value) {
            _formStore.setConfirmPassword(_passwordConfirmController.text);
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
            await Future.delayed(const Duration(seconds: 1), () {
              //print("LOADING = $loading");
              loading = false;
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute2(routeName: Routes.forgetPasswordDone));
            });
            //   if (_formStore.canForgetPassword) {
            //     DeviceUtils.hideKeyboard(context);
            //     _userStore.login(
            //         _userEmailController.text, _passwordController.text);
            //         // loading = true;
            //   } else {
            //     _showErrorMessage(AppLocalizations.of(context)
            //         .get('login_error_missing_fields'));
            //   }
          }),
    );
  }


  Widget navigate(BuildContext context) {
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool(Preferences.is_logged_in, true);
    // });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: Lang.get('error'),
            duration: const Duration(seconds: 3),
          ).show(context);
        }
      });
    }

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
