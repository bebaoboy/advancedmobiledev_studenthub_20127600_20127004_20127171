import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/service_locator.dart';

class SignUpStudentScreen extends StatefulWidget {
  @override
  _SignUpStudentScreenState createState() => _SignUpStudentScreenState();
}

class _SignUpStudentScreenState extends State<SignUpStudentScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _userFullnameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();

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
      appBar: EmptyAppBar(),
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
                child: LoadingScreen(),
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
      physics: ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height *
                (MediaQuery.of(context).orientation == Orientation.landscape
                    ? 1.4
                    : 0.9)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            EmptyAppBar(),
            SizedBox(height: 24.0),
            Center(
              child: AutoSizeText(
                AppLocalizations.of(context)
                    .translate('signup_student_main_text'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                minFontSize: 10,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 24.0),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  children: [
                    _buildFullnameField(),
                    _buildUserIdField(),
                    _buildPasswordField(),
                    // _buildForgotPasswordButton(),
                    SizedBox(height: 24.0),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Transform.translate(
                        offset: const Offset(-8, 0),
                        child: CheckboxListTile(
                          title: Transform.translate(
                            offset: const Offset(-10, 0),
                            child: AutoSizeText(
                              AppLocalizations.of(context)
                                  .translate('signup_company_policy_agree'),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                              minFontSize: 10,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          value: checked,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (newValue) {
                            setState(() {
                              checked = newValue ?? !checked;
                            });
                          },
                          dense: true,
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),

                    _buildSignUpStudentButton(),
                    SizedBox(height: 24.0),
                    RichText(
                      text: TextSpan(
                        text: AppLocalizations.of(context)
                            .translate('signup_student_company_prompt'),
                        style: TextStyle(fontSize: 18, color: _themeStore.darkMode ? Colors.white : Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: " " +
                                  AppLocalizations.of(context).translate(
                                      'signup_student_company_prompt_action'),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute2(
                                          routeName: Routes.signUpCompany));
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
          hint: AppLocalizations.of(context)
              .translate('signup_company_et_fullname'),
          inputType: TextInputType.emailAddress,
          icon: Icons.account_box,
          textController: _userFullnameController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          // onChanged: (value) {
          //   _formStore.setUserId(_userEmailController.text);
          // },
          // onFieldSubmitted: (value) {
          //   FocusScope.of(context).requestFocus(_passwordFocusNode);
          // },
          errorText: null,
        );
      },
    );
  }

  Widget _buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint:
              AppLocalizations.of(context).translate('signup_company_et_email'),
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _formStore.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _formStore.formErrorStore.userEmail == null ? null : AppLocalizations.of(context).translate(_formStore.formErrorStore.userEmail),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: AppLocalizations.of(context)
              .translate('signup_company_et_password'),
          isObscure: true,
          icon: Icons.lock,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: _formStore.formErrorStore.password == null ? null : AppLocalizations.of(context).translate(_formStore.formErrorStore.password),
          onChanged: (value) {
            _formStore.setPassword(_passwordController.text);
          },
        );
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: FractionalOffset.centerRight,
      child: MaterialButton(
        padding: EdgeInsets.all(0.0),
        child: Text(
          AppLocalizations.of(context).translate('login_btn_forgot_password'),
          style: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(color: Colors.orangeAccent),
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: RoundedButtonWidget(
        buttonText: AppLocalizations.of(context).translate('login_btn_sign_in'),
        buttonColor: Colors.orangeAccent,
        textColor: Colors.white,
        onPressed: () async {
          loading = true;
          // if (_formStore.canSignUpStudent) {
          //   DeviceUtils.hideKeyboard(context);
          //   _userStore.login(
          //       _userEmailController.text, _passwordController.text);
          // } else {
          //   _showErrorMessage(AppLocalizations.of(context)
          //       .translate('login_error_missing_fields'));
          // }
        },
      ),
    );
  }

  Widget _buildFooterText() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: <Widget>[
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
        Text(
          AppLocalizations.of(context).translate('login_btn_sign_up_prompt'),
          style: TextStyle(fontSize: 12),
        ),
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
      ]),
    );
  }

  Widget _buildSignUpStudentButton() {
    return Container(
      child: RoundedButtonWidget(
        buttonText:
            AppLocalizations.of(context).translate('signup_student_sign_up'),
        buttonColor: Theme.of(context).colorScheme.primary,
        textColor: Colors.white,
        onPressed: () async {
          // if (_formStore.canSignUpStudent) {
          //   DeviceUtils.hideKeyboard(context);
          //   _userStore.login(
          //       _userEmailController.text, _passwordController.text);
          // } else {
          //   _showErrorMessage(AppLocalizations.of(context)
          //       .translate('login_error_missing_fields'));
          // }
        },
      ),
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(Duration(milliseconds: 0), () {
      print("LOADING = $loading");
      // Navigator.of(context)
      //   ..pushAndRemoveUntil(MaterialPageRoute2(child: HomeScreen()),
      //       (Route<dynamic> route) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return SizedBox.shrink();
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
