import 'package:boilerplate/core/widgets/backguard.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
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
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      try {
        if (_userStore.shouldChangePass) {
          Navigator.of(context).pushReplacement(MaterialPageRoute2(
              routeName: Routes.forgetPasswordChangePassword));
        } else if (_userStore.user != null &&
            _userStore.user!.type != UserType.naught &&
            _userStore.user!.email.isNotEmpty) {
          print("switch account navigate home");
          final ProfileStudentStore infoStore = getIt<ProfileStudentStore>();
          if (_userStore.user!.studentProfile != null) {
            infoStore.setStudentId(_userStore.user!.studentProfile!.objectId!);
          }
          infoStore.getInfo().then(
                (value) {},
              );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute2(routeName: Routes.welcome),
          );
        }
      } catch (E) {
        print(E.toString);
        print("cannot redirect from home");
      }
    });
  }

  final UserStore _userStore = getIt<UserStore>();

  @override
  Widget build(BuildContext context) {
    return BackGuard(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      children: [
                        Text(Lang.get('home_title'), textAlign: TextAlign.center,),
                        const SizedBox(height: 30),
                        Text(Lang.get('home_intro'), textAlign: TextAlign.center,),
                        const SizedBox(height: 25),
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
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute2(routeName: Routes.welcome),
                                );
                              } else {
                                showAnimatedDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return ClassicGeneralDialogWidget(
                                      contentText:
                                          'User ${_userStore.user!.email} chưa có profile Company. Tạo ngay?',
                                      negativeText: Lang.get('cancel'),
                                      positiveText: 'Yes',
                                      onPositiveClick: () {
                                        Navigator.of(context).pop();
      
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
                            buttonColor: Theme.of(context).colorScheme.primary,
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute2(routeName: Routes.welcome),
                                );
                              } else {
                                showAnimatedDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return ClassicGeneralDialogWidget(
                                      contentText:
                                          'User ${_userStore.user!.email} chưa có profile Student. Tạo ngay?',
                                      negativeText: Lang.get('cancel'),
                                      positiveText: 'Yes',
                                      onPositiveClick: () {
                                        Navigator.of(context).pop();
      
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
                            buttonColor: Theme.of(context).colorScheme.primary,
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    )),
                Text(Lang.get('home_description')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return const MainAppBar();
  }
}
