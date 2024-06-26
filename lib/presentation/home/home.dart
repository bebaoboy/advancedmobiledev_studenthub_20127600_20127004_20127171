import 'package:boilerplate/core/widgets/backguard.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_info_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool enabled = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        if (_userStore.shouldChangePass) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute2(
              routeName: Routes.forgetPasswordChangePassword), (_) => false);
        } else if (_userStore.user != null &&
            _userStore.user!.type != UserType.naught &&
            _userStore.user!.email.isNotEmpty) {
          print("switch account navigate home");
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute2(routeName: Routes.dashboard), (_) => false
            );
          });
        } else {
          if (mounted) {
            setState(() {
              enabled = true;
            });
          }
        }
      } catch (E) {
        print(E.toString);
        print("cannot redirect from home");
        if (mounted) {
          setState(() {
            enabled = true;
          });
        }
      }
    });
  }

  final UserStore _userStore = getIt<UserStore>();

  @override
  Widget build(BuildContext context) {
    return BackGuard(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: !enabled
            ? const Center(
                child: LoadingScreenWidget(
                  size: 80,
                ),
              )
            : Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Lang.get('profile_welcome_title'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          Lang.get('home_intro'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        if (enabled)
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: RoundedButtonWidget(
                              onPressed: () {
                                // Handle your action
                                if (_userStore.user == null) return;
                                // if (_userStore.user!.roles!.firstWhereOrNull(
                                //       (element) =>
                                //           element.name == UserType.company.name,
                                //     ) !=
                                //     null)
                                if (_userStore.user!.companyProfile != null) {
                                  _userStore.user!.type = UserType.company;
                                  if (_userStore.user != null) {
                                    SharedPreferences.getInstance().then(
                                      (value) {
                                        value.setString(
                                            Preferences.current_user_role,
                                            _userStore.user!.type.name
                                                .toLowerCase()
                                                .toString());
                                      },
                                    );
                                  }
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute2(
                                        routeName: Routes.dashboard), (_) => false
                                  );
                                } else {
                                  showAnimatedDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext ctx) {
                                      return ClassicGeneralDialogWidget(
                                        contentText:
                                            'User ${_userStore.user!.email} chưa có profile Company. Tạo ngay?',
                                        negativeText: Lang.get('cancel'),
                                        positiveText: 'Yes',
                                        onPositiveClick: () async {
                                          Navigator.of(ctx).pop();
                                          final ProfileStudentStore infoStore =
                                              getIt<ProfileStudentStore>();

                                          await infoStore.getTechStack();
                                          await infoStore.getSkillset();
                                          Navigator.of(context).push(
                                              MaterialPageRoute2(
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
                                }
                              },
                              buttonText: Lang.get('company'),
                              buttonColor:
                                  Theme.of(context).colorScheme.primary,
                              textColor: Colors.white,
                            ),
                          ),
                        const SizedBox(height: 10),
                        if (enabled)
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: RoundedButtonWidget(
                              onPressed: () {
                                // Handle your action
                                if (_userStore.user == null) return;
                                if (_userStore.user!.studentProfile != null) {
                                  _userStore.user!.type = UserType.student;
                                  if (_userStore.user != null) {
                                    SharedPreferences.getInstance().then(
                                      (value) {
                                        value.setString(
                                            Preferences.current_user_role,
                                            _userStore.user!.type.name
                                                .toLowerCase()
                                                .toString());
                                      },
                                    );
                                  }
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute2(
                                        routeName: Routes.dashboard), (_) => false
                                  );
                                } else {
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
                                          Navigator.of(context).push(
                                              MaterialPageRoute2(
                                                  routeName:
                                                      Routes.profileStudent));
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
                                }
                              },
                              buttonText: Lang.get('student'),
                              buttonColor:
                                  Theme.of(context).colorScheme.primary,
                              textColor: Colors.white,
                            ),
                          ),
                        const SizedBox(height: 25),
                        Text(Lang.get('home_description')),
                        // ElevatedButton(
                        //   onPressed: () => createTextNotification(),
                        //   child: const Text('Show Text Notification'),
                        // ),
                        // const SizedBox(height: 20),
                        // ElevatedButton(
                        //   onPressed: () => createImageNotification(),
                        //   child: const Text('Show Image Notification'),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return MainAppBar(
      name: _userStore.user != null ? _userStore.user!.name : "",
    );
  }
}
