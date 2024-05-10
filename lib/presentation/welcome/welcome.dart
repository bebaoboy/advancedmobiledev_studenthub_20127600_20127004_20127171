import 'package:boilerplate/core/widgets/backguard.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.newRole = false});
  final bool newRole;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        var userStore = getIt<UserStore>();
        if (userStore.user != null) {
          // var projectStore = getIt<ProjectStore>();
          // await projectStore.getAllProject();
          if (userStore.companyId != null) {
            // await projectStore
            //     .getProjectByCompany(userStore.user!.companyProfile!.objectId!);
          }
          if (userStore.user!.type == UserType.student &&
              userStore.user!.studentProfile != null) {
            // await projectStore.getStudentProposalProjects(
            //     userStore.user!.studentProfile!.objectId!);
          }
        }
      } catch (e) {
        print("cannot get projects");
      }
    });
  }

  var userStore = getIt<UserStore>();

  @override
  Widget build(BuildContext context) {
    return BackGuard(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.signpost_outlined,
                  size: 25,
                ),
                const SizedBox(height: 20.0),
                Text(
                  "${Lang.get('Welcome')} ${userStore.user != null ? userStore.user!.name : ""}!\n${userStore.user != null ? ("(${userStore.user!.type.name})") : ""}",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                Text(
                  Lang.get('Start'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: RoundedButtonWidget(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute2(routeName: Routes.dashboard),
                          (Route<dynamic> route) => false);
                      if (widget.newRole) {
                        showAnimatedDialog(
                          context:
                              NavigationService.navigatorKey.currentContext ??
                                  context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return ClassicGeneralDialogWidget(
                              titleText: 'Welcome to StudentHub',
                              contentText:
                                  'A marketplace to connect students with real-world project!',
                              positiveText: 'OK',
                              onPositiveClick: () async {
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
                    buttonText: Lang.get('Start_button'),
                    buttonColor: Theme.of(context).colorScheme.primary,
                    textColor: Colors.white,
                  ),
                ),
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
