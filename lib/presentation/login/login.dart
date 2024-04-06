import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/backguard.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/forget_password_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/presentation/video_call/managers/call_manager.dart';
import 'package:boilerplate/presentation/video_call/managers/push_notifications_manager.dart';
import 'package:boilerplate/presentation/video_call/utils/configs.dart';
import 'package:boilerplate/presentation/video_call/utils/platform_utils.dart';
import 'package:boilerplate/presentation/video_call/utils/pref_util.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/service_locator.dart';
import 'package:boilerplate/presentation/video_call/utils/configs.dart'
    as utils;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.email = ""});
  final String? email;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final ForgetPasswordStore _forgetPasswordStore = getIt<ForgetPasswordStore>();
  final UserStore _userStore = getIt<UserStore>();

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;
  bool initializing = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _userEmailController.text = widget.email ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return BackGuard(
      child: Scaffold(
        appBar: const EmptyAppBar(),
        body: _buildBody(),
      ),
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
                  : _showErrorMessage(_userStore.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _userStore.isLoading,
                // child: CustomProgressIndicatorWidget(),
                child: GestureDetector(
                    onTap: () {
                      // setState(() {
                      //   loading = false;
                      // });
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
      child: LimitedBox(
        maxHeight: MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.height * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      Lang.get('login_main_text'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800),
                      minFontSize: 10,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Expanded(
                      child: Image.asset(
                        'assets/images/img_login.png',
                        scale: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    _buildUserIdField(),
                    _buildPasswordField(),
                    _buildForgotPasswordButton(),
                    _buildSignInButton(),
                    Expanded(
                        child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildFooterText(),
                    )),
                    const SizedBox(
                      height: 14,
                    ),
                    _buildSignUpButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('login_et_user_email'),
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _formStore.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _formStore.formErrorStore.userEmail == null
              ? null
              : Lang.get(_formStore.formErrorStore.userEmail),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Lang.get('login_et_user_password'),
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

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: FractionalOffset.centerRight,
      child: MaterialButton(
        padding: const EdgeInsets.all(0.0),
        child: Text(
          Lang.get('login_btn_forgot_password'),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.orangeAccent, fontSize: 12),
        ),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute2(routeName: Routes.forgetPassword));
        },
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: RoundedButtonWidget(
        buttonText: Lang.get('login_btn_sign_in'),
        buttonColor: Theme.of(context).colorScheme.primary,
        textColor: Colors.white,
        onPressed: () async {
          if (_formStore.canLogin) {
            DeviceUtils.hideKeyboard(context);
            await _userStore.login(_userEmailController.text,
                _passwordController.text, UserType.naught, []);
            _forgetPasswordStore.setOldPassword(_passwordController.text);
          } else {
            _showErrorMessage(Lang.get('login_error_missing_fields'));
          }
        },
      ),
    );
  }

  Widget _buildFooterText() {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: Row(children: <Widget>[
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: const Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
        Text(
          Lang.get('login_btn_sign_up_prompt'),
          style: const TextStyle(fontSize: 12),
        ),
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: const Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
      ]),
    );
  }

  Widget _buildSignUpButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        margin: const EdgeInsets.fromLTRB(50, 0, 50, 50),
        child: RoundedButtonWidget(
          buttonText: Lang.get('login_btn_sign_up'),
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          onPressed: () async {
            Navigator.of(context)
                .push(MaterialPageRoute2(routeName: Routes.signUp));
          },
        ),
      ),
    );
  }

  Widget navigate(BuildContext context) {
    // print("${_userStore.user!.type.name} ${_userStore.user!.email}");
    if (_userStore.notification.isNotEmpty) {
      _showNotificationMessage(_userStore.notification);
      return Container();
    }

    if (_forgetPasswordStore.mailSentSuccess && !initializing) {
      initializing = true;
      _forgetPasswordStore.saveShouldChangePass();
      Future.delayed(const Duration(milliseconds: 10), () async {
        // //print("LOADING = $loading");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute2(routeName: Routes.forgetPasswordChangePassword),
            (Route<dynamic> route) => false);
      });
      return Container();
    }

    if (!_userStore.isLoading && !initializing) {
      Future.delayed(const Duration(milliseconds: 1000), () async {
        print("LOADING = ${_userStore.isLoading}");
        setState(() {
          initializing = true;
        });
        log("login", "BEBAOBOY");
        initCube(context);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute2(routeName: Routes.home),
            (Route<dynamic> route) => false);
      });
    }
    return Container();
  }

  initCube(context) async {
    final UserStore userStore = getIt<UserStore>();
    // CubeUser user;

    if (userStore.user != null) {
      try {
        if (CubeChatConnection.instance.currentUser != null &&
            !userStore.user!.email.contains(
                CubeChatConnection.instance.currentUser!.login ?? "????")) {
          //print("change user --- LOGING OUT");
          await SharedPreferences.getInstance().then((preference) async {
            CallManager.instance.destroy();
            CubeChatConnection.instance.destroy();
            PushNotificationsManager.instance.unsubscribe();

            SharedPrefs.deleteUserData();
            await signOut();
          });
        }
        // var user = userStore.user!.email == "user1@gmail.com"
        //     ? utils.users[0]
        //     : userStore.user!.email == "user2@gmail.com"
        //         ? utils.users[1]
        //         : utils.users[2];
        var user = CubeUser(
          login: userStore.user!.email,
          email: userStore.user!.email,
          fullName: userStore.user!.email.split("@").first.toUpperCase(),
          password: DEFAULT_PASS,
        );
        try {
          var value;
          try {
            value = await createSession(user);
          } catch (e) {
            log(e.toString(), "BEBAOBOY");
            user = await signUp(user);
            user.password ??= DEFAULT_PASS;

            value = await createSession(user);
          }
          var cb = await getUserByLogin(user.login!);
          if (cb != null) user = cb;
          user.password ??= DEFAULT_PASS;
          print(user);
          utils.users.add(user);
          CubeSessionManager.instance.activeSession = value;

          await CubeChatConnection.instance.login(user).then((cubeUser) async {
            SharedPrefs.saveNewUser(cubeUser);
            log(cubeUser.toString(), "BEBAOBOY");
            if (CubeChatConnection.instance.isAuthenticated() &&
                CubeChatConnection.instance.currentUser != null) {
              log(
                  (CubeSessionManager.instance.activeSession!.user == null)
                      .toString(),
                  "BEBAOBOY");
            }

            initForegroundService();
            checkSystemAlertWindowPermission(context);

            requestNotificationsPermission();

            CallManager.instance.init(context);

            PushNotificationsManager.instance.init();

            Navigator.pushReplacement(
                context,
                MaterialPageRoute2(
                    routeName:
                        userStore.isLoggedIn ? Routes.home : Routes.login));
          }).catchError((exception) {
            //_processLoginError(exception);

            log(exception.toString(), "BEBAOBOY");
          });
          // _controller.stop();
        } catch (exception) {
          //_processLoginError(exception);

          log(exception.toString(), "BEBAOBOY");

          deleteSessionsExceptCurrent()
              .then((voidResult) {})
              .catchError((error) {});
        }
      } catch (e) {
        print(e.toString());
        print("error init cubit login screen");
      }
    } else {
      // user = utils.users[2];
    }
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
          ).show(NavigationService.navigatorKey.currentContext!);
        }
      });
    }

    return const SizedBox.shrink();
  }

  _showNotificationMessage(String message) {
    Future.delayed(const Duration(milliseconds: 0), () {
      if (message.isNotEmpty) {
        FlushbarHelper.createInformation(
          message: message,
          title: Lang.get('notification'),
          duration: const Duration(seconds: 3),
        ).show(NavigationService.navigatorKey.currentContext!);
      }
    });
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
