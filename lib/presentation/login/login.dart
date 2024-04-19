// ignore_for_file: unused_local_variable

import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/backguard.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/onboarding_screen.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/forget_password_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/presentation/setting/settings_drawer.dart';
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
import 'package:boilerplate/utils/workmanager/work_manager_helper.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_helper/size_helper.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:toastification/toastification.dart';

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
    checkIntro(context);
  }

  checkIntro(context) {
    Future.delayed(Duration.zero, () async {
      bool firstTime = false;
      final prefs = await SharedPreferences.getInstance();
      firstTime = prefs.getBool(Preferences.first_time) ?? false;
      if (!firstTime) {
        await showIntroBottomSheet(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackGuard(
      child: Scaffold(
        appBar: const EmptyAppBar(),
        body: _buildBody(),
        endDrawer: const SettingScreenDrawer(),
        // drawer: const SettingScreenDrawer(),
        drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      ),
    );
  }

  Future showIntroBottomSheet(BuildContext context) async {
    return await Navigator.push(
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
          ),

//           Positioned(
//             height: 1000,
//             width: 2000,
//             top: o.dy,
//             left: o.dx,
//             child: GestureDetector(
//                 onPanUpdate: (details) => setState(() {
//                       o += Offset(details.delta.dx, details.delta.dy);
//                     }),
//                 child: PageView(
//                   children: [
//                     Container(color: Colors.amber.withOpacity(0.1),),
//                     AbsorbPointer(child: Container(color: Colors.blue.withOpacity(0.1),)),
//                     Container(color: Colors.red.withOpacity(0.1),)
// ,
//                   ],
//                 )),
//           )
        ],
      ),
    );
  }

  Offset o = Offset.zero;

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
      child: LimitedBox(
        maxHeight: SizeHelper.of(context, printScreenInfo: true).help(
          mobileExtraLarge: MediaQuery.of(context).size.height * 0.9,
          desktopExtraLarge: MediaQuery.of(context).size.height * 0.9,
          mobileExtraLargeLandscape: MediaQuery.of(context).size.width * 0.9,
        ),
        // MediaQuery.of(context).orientation == Orientation.landscape
        //     ? MediaQuery.of(context).size.width * 0.9
        //     : MediaQuery.of(context).size.height * 0.9,
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
                      child: Container(
                        constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height * 0.3),
                        child: Image.asset(
                          'assets/images/img_login.png',
                          scale: 1.2,
                        ),
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
      initializing = true;
      print("LOADING = ${_userStore.isLoading}");
      log("login", "BEBAOBOY");
      Future.delayed(const Duration(milliseconds: 1000), () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute2(routeName: Routes.home),
            (Route<dynamic> route) => false);
      });
      Future.delayed(const Duration(milliseconds: 1200), () async {
        if (NavigationService.navigatorKey.currentContext != null) {
          initCube(NavigationService.navigatorKey.currentContext!);
        }
      });
    }
    return Container();
  }

  _loginCube(context, user) async {
    await CubeChatConnection.instance.login(user).then((cubeUser) async {
      SharedPrefs.saveNewUser(cubeUser);
      log(cubeUser.toString(), "BEBAOBOY");
      if (CubeChatConnection.instance.isAuthenticated() &&
          CubeChatConnection.instance.currentUser != null) {
        // log(
        //     (CubeSessionManager.instance.activeSession!.user == null)
        //         .toString(),
        //     "BEBAOBOY");
      }
      initForegroundService();

      CallManager.instance.init(context);

      await PushNotificationsManager.instance.init();

      WorkMangerHelper.registerProfileFetch();
    }).catchError((exception) {
      //_processLoginError(exception);

      log(exception.toString(), "BEBAOBOY");
      return;
    });
  }

  initCube(context) async {
    final UserStore userStore = getIt<UserStore>();
    // CubeUser user;

    if (userStore.user != null) {
      try {
        if (CubeChatConnection.instance.currentUser != null &&
            !userStore.user!.email.contains(
                CubeChatConnection.instance.currentUser!.login ?? "????")) {
          print("change user --- LOGING OUT cb");
          await SharedPreferences.getInstance().then((preference) async {
            PushNotificationsManager.instance.unsubscribe();
            CallManager.instance.destroy();
            CubeChatConnection.instance.destroy();

            SharedPrefs.deleteUserData();
            await signOut();
          });
        }
        // var user = userStore.user!.email == "user1@gmail.com"
        //     ? utils.users[0]
        //     : userStore.user!.email == "user2@gmail.com"
        //         ? utils.users[1]
        //         : utils.users[2];
        CubeUser user;

        if (userStore.user != null && userStore.user!.email.isNotEmpty) {
          if (userStore.savedUsers.firstWhereOrNull(
                (element) => element.email == userStore.user!.email,
              ) ==
              null) {
            userStore.savedUsers.add(userStore.user!);
          }
          Future.delayed(const Duration(seconds: 0), () async {
            try {
              user = CubeUser(
                login: userStore.user!.email,
                email: userStore.user!.email,
                fullName: userStore.user!.email.split("@").first.toUpperCase(),
                password: DEFAULT_PASS,
              );
              if (CubeSessionManager.instance.isActiveSessionValid() &&
                  CubeSessionManager.instance.activeSession!.user != null) {
                if (CubeChatConnection.instance.isAuthenticated()) {
                } else {
                  _loginCube(context, user);
                }
              } else {
                // create session
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
                _loginCube(context, user);
              }
            } catch (e) {
              print("cannot init cube");
            }
          });
        }
        // user = utils.users[2];
        else {}
      } catch (e) {
        ///
      }
    } else {
      // user = utils.users[2];
    }
  }

  bool error = false;
  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty && !error) {
      error = true;
      Toastify.show(context, Lang.get('error'), message,
          ToastificationType.error, () => error = false);
    }

    return const SizedBox.shrink();
  }

  _showNotificationMessage(String message) {
    if (message.isNotEmpty && !error) {
      error = true;
      Toastify.show(context, Lang.get('notification'), message,
          ToastificationType.info, () => error = false);
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
