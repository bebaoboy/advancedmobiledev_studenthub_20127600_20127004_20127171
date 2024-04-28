import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/signup/store/signup_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:toastification/toastification.dart';

import '../../di/service_locator.dart';

class SignUpCompanyScreen extends StatefulWidget {
  const SignUpCompanyScreen({super.key});

  @override
  _SignUpCompanyScreenState createState() => _SignUpCompanyScreenState();
}

class _SignUpCompanyScreenState extends State<SignUpCompanyScreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userFullnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final SignupStore _formStore = getIt<SignupStore>();
  // final UserStore _userStore = getIt<UserStore>();

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;

  bool loading = false;
  bool checked = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: const EmptyAppBar(),
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
              return _formStore.success
                  ? navigate(context)
                  : _showErrorMessage(_formStore.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _formStore.isLoading || loading,
                // child: CustomProgressIndicatorWidget(),
                child: const LoadingScreen(),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height *
                (MediaQuery.of(context).orientation == Orientation.landscape
                    ? 1.2
                    : 1)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 24.0),
            Center(
              child: AutoSizeText(
                Lang.get('signup_company_main_text'),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                minFontSize: 10,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  children: [
                    _buildFullnameField(),
                    _buildUserIdField(),
                    _buildPasswordField(),
                    _buildPasswordConfirmField(),
                    // _buildForgotPasswordButton(),
                    const SizedBox(height: 24.0),
                    Observer(
                      builder: (context) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        child: Transform.translate(
                          offset: const Offset(-8, 0),
                          child: CheckboxListTile(
                            title: Transform.translate(
                              offset: const Offset(-10, 0),
                              child: AutoSizeText(
                                Lang.get('signup_company_policy_agree'),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800),
                                minFontSize: 10,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            value: _formStore.hasAcceptPolicy,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (newValue) {
                              _formStore.changeAcceptState();
                            },
                            dense: true,
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    _buildSignUpCompanyButton(),
                    const SizedBox(height: 24.0),
                    RichText(
                      text: TextSpan(
                        text: Lang.get('signup_company_student_prompt'),
                        style: TextStyle(
                            fontSize: 18,
                            color: _themeStore.darkMode
                                ? Colors.white
                                : Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  " ${Lang.get('signup_company_student_prompt_action')}",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute2(
                                          routeName: Routes.signUpStudent), (_) => false);
                                }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullnameField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('signup_company_et_fullname'),
          inputType: TextInputType.emailAddress,
          icon: Icons.account_box,
          textController: _userFullnameController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _formStore.setFullname(_userFullnameController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _formStore.signUpFormErrorStore.fullname,
        );
      },
    );
  }

  Widget _buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('signup_company_et_email'),
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _formStore.setEmail(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _formStore.signUpFormErrorStore.email == null
              ? null
              : Lang.get(_formStore.signUpFormErrorStore.email),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('signup_company_et_password'),
          isObscure: true,
          icon: Icons.lock,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: _formStore.signUpFormErrorStore.password == null
              ? null
              : Lang.get(_formStore.signUpFormErrorStore.password),
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
          hint: Lang.get('signup_company_et_password_confirm'),
          isObscure: true,
          icon: Icons.lock,
          textController: _passwordConfirmController,
          errorText: _formStore.signUpFormErrorStore.repeatPassword == null
              ? null
              : Lang.get(_formStore.signUpFormErrorStore.repeatPassword),
          onChanged: (value) {
            _formStore.setConfirmPassword(_passwordConfirmController.text);
          },
        );
      },
    );
  }

  Widget _buildSignUpCompanyButton() {
    return RoundedButtonWidget(
      buttonText: Lang.get('signup_company_sign_up'),
      buttonColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
      onPressed: () async {
        if (_formStore.canRegister) {
          DeviceUtils.hideKeyboard(context);
          _formStore.signUp(_userFullnameController.text,
              _userEmailController.text, _passwordController.text);
          setState(() {
            loading = true;
          });
        } else {
          _showErrorMessage(Lang.get('login_error_missing_fields'));
        }
        // if (_formStore.canSignUpCompany) {
        //   DeviceUtils.hideKeyboard(context);
        //   _userStore.login(
        //       _userEmailController.text, _passwordController.text);
        // } else {
        //   _showErrorMessage(AppLocalizations.of(context)
        //       .translate('login_error_missing_fields'));
        // }

        // Navigator.of(context)
        //     .push(MaterialPageRoute2(routeName: Routes.profile));
      },
    );
  }

  Widget navigate(BuildContext context) {
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool(Preferences.is_logged_in, true);
    // });
    loading = false;

    Future.delayed(const Duration(seconds: 2)).then(
      (value) {
        showAnimatedDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext c) {
            return ClassicGeneralDialogWidget(
              contentText: Lang.get('signup_email_sent'),
              // negativeText: ':Debug:',
              positiveText: 'OK',
              onPositiveClick: () {
                Navigator.of(c).pop();
              },
              // onNegativeClick: () {
              //   Navigator.of(c).pop();
              //   Navigator.of(context)
              //       .push(MaterialPageRoute2(routeName: Routes.profile));
              // },
            );
          },
          animationType: DialogTransitionType.size,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(seconds: 1),
        ).then((v) => Navigator.of(context).pop());
      },
    );
    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          Toastify.show(context, Lang.get('error'), message,
              ToastificationType.error, () {});
        }
      });
    }

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _userFullnameController.dispose();
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
