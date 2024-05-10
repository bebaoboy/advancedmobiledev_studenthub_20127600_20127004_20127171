// ignore_for_file: unused_element

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/stepper.dart';
import 'package:boilerplate/presentation/dashboard/dashboard.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';

import 'package:boilerplate/presentation/profile/store/form/profile_student_form_store.dart';
import 'package:boilerplate/presentation/profile/view_profile_student_tab1.dart';
import 'package:boilerplate/presentation/profile/view_profile_student_tab2.dart';
import 'package:boilerplate/presentation/profile/view_profile_student_tab3.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/page_transformer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../di/service_locator.dart';

class ViewProfileStudent extends StatefulWidget {
  const ViewProfileStudent({super.key});

  @override
  _ViewProfileStudentState createState() => _ViewProfileStudentState();
}

class _ViewProfileStudentState extends State<ViewProfileStudent> {
  //stores:---------------------------------------------------------------------
  // final ThemeStore _themeStore = getIt<ThemeStore>();
  final ProfileStudentFormStore _formStore = getIt<ProfileStudentFormStore>();
  // final UserStore _userStore = getIt<UserStore>();

  //textEdittingController
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _websiteURLController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // late FocusNode _companyFocusNode;

  bool enabled = false;
  String oldTranscript = "", oldCv = "";

  @override
  void initState() {
    super.initState();
    _formStore.errorStore.errorMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      children = [
        const KeepAlivePage(ViewProfileStudentTab1()),
        const KeepAlivePage(ViewProfileStudentTab2()),
        const KeepAlivePage(ViewProfileStudentTab3()),
      ];
    }
    return Scaffold(
      primary: true,
      appBar:
          MainAppBar(name: "${Lang.get("edit")} ${Lang.get("profile_text")}"),
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool b = false;
        await showAnimatedDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return ClassicGeneralDialogWidget(
              contentText: Lang.get("discard_edit"),
              negativeText: Lang.get('cancel'),
              positiveText: 'OK',
              onPositiveClick: () {
                b = true;
                Navigator.of(context).pop();
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
        return b;
      },
      child: Material(
        child: Stack(children: <Widget>[
          Container(child: _buildRightSide()),
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
                visible: _formStore.isLoading,
                child: const LoadingScreen(),
              );
            },
          ),
        ]),
      ),
    );
  }

  // REQUIRED: USED TO CONTROL THE STEPPER.
  int activeStep = 0; // Initial step set to 0.

  // OPTIONAL: can be set directly.
  int dotCount = 3;

  /// Generates jump steps for dotCount number of steps, and returns them in a row.
  // Row steps() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: List.generate(dotCount, (index) {
  //       return Expanded(
  //         child: ElevatedButton(
  //           child: Text('${index + 1}'),
  //           onPressed: () {
  //             setState(() {
  //               activeStep = index;
  //             });
  //           },
  //         ),
  //       );
  //     }),
  //   );
  // }

  /// Returns the next button widget.
  // Widget nextButton() {
  //   return ElevatedButton(
  //     child: const Text('Next'),
  //     onPressed: () {
  //       /// ACTIVE STEP MUST BE CHECKED FOR (dotCount - 1) AND NOT FOR dotCount To PREVENT Overflow ERROR.
  //       if (activeStep < dotCount - 1) {
  //         setState(() {
  //           activeStep++;
  //         });
  //         pageController.move(activeStep);
  //       }
  //     },
  //   );
  // }

  // /// Returns the previous button widget.
  // Widget previousButton() {
  //   return ElevatedButton(
  //     child: const Text('Prev'),
  //     onPressed: () {
  //       // activeStep MUST BE GREATER THAN 0 TO PREVENT OVERFLOW.
  //       if (activeStep > 0) {
  //         setState(() {
  //           activeStep--;
  //         });
  //         pageController.move(activeStep);
  //       }
  //     },
  //   );
  // }

  IndexController pageController = IndexController();
  List<Widget> children = [];

  Widget _buildRightSide() {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // const SizedBox(
            //   height: 20,
            // ),
            // Center(
            //   child: Text(
            //     "${Lang.get('profile_welcome_title')}, STUDENT",
            //     style: Theme.of(context)
            //         .textTheme
            //         .bodyLarge
            //         ?.copyWith(fontWeight: FontWeight.w600),
            //   ),
            // ),
            LimitedBox(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              child: TransformerPageView(
                index: 0,
                duration: const Duration(milliseconds: 500),
                transformer: DepthPageTransformer(),
                itemCount: dotCount,
                controller: pageController,
                itemBuilder: (context, i) => children[i],
                onPageChanged: (value) {
                  setState(() {
                    activeStep = value!;
                  });
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FlutterStepIndicator(
                height: 20, // Set the height of the step indicator.
                // Enable or disable automatic scrolling.
                // put a list of tiles
                list: children, // Provide a list of steps or stages to display.
                onChange: (int index) {
                  // Define a callback function that triggers when the active step changes.
                  // You can perform actions based on the selected step here.
                },
                onClickItem: (p0) {
                  setState(() {
                    activeStep = p0;
                  });
                  pageController.move(activeStep);
                },
                page: activeStep, // Specify the current step or page.
                // positiveCheck:
                //     yourCustomCheckmarkWidget, // Optionally, use a custom checkmark widget.
                // positiveColor:
                //     yourColor, // Customize the color of positive (active) steps.
                // negativeColor:
                //     yourColor, // Customize the color of negative (disabled) steps.
                // progressColor:
                //     yourColor, // Customize the color of the progress indicator.
                // durationScroller:
                //     yourDuration, // Set the duration for scrolling animations.
                // durationCheckBulb:
                //     yourDuration, // Set the duration for checkmark bulb animations.
                // division:
                //     yourDivision, // Specify the number of divisions for rendering steps.
              ),
            ),

            /// Jump buttons.
            // Padding(padding: const EdgeInsets.all(18.0), child: steps()),

            // Next and Previous buttons.
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [previousButton(), nextButton()],
            // ),
            _buildSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        child: RoundedButtonWidget(
          buttonText: Lang.get('save'),
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          onPressed: () async {
            // _formStore
            //     .setResume(_cv != null ? _cv!.path ?? "" : '');
            // _formStore.setTranscript(
            //     _transcript != null ? _transcript!.path ?? "" : '');
            print(_formStore.techStack);
            print(_formStore.skillSet);
            print(_formStore.educations);
            print(_formStore.languages);
            print(_formStore.projectExperience);
            print(_formStore.resume);
            print(_formStore.transcript);
            var userStore = getIt<UserStore>();
            if (userStore.user != null &&
                userStore.user!.studentProfile != null) {
              _formStore.updateProfileStudent(
                _formStore.techStack,
                _formStore.skillSet,
                _formStore.languages,
                _formStore.educations,
                _formStore.projectExperience,
                _formStore.transcript,
                _formStore.resume,
                userStore.user!.studentProfile!.objectId ?? "-1",
              );
            }

            // Navigator.of(context).pushAndRemoveUntil(
            //     MaterialPageRoute2(routeName: Routes.home),
            //     (Route<dynamic> route) => false);
            // if (_formStore.canProfileStudent) {
            //   DeviceUtils.hideKeyboard(context);
            //   _userStore.login(
            //       _userEmailController.text, _passwordController.text);
            // } else {
            //   _showErrorMessage(AppLocalizations.of(context)
            //       .get('login_error_missing_fields'));
            // }
          },
        ),
      ),
    );
  }

  Widget navigate(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_formStore.success) {
        _formStore.success = false;
        showAnimatedDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return ClassicGeneralDialogWidget(
              contentText:
                  '${_formStore.fullName} update profile successfully!',
              negativeText: Lang.get('cancel'),
              positiveText: 'OK',
              onPositiveClick: () {
                Navigator.of(context).pop();
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
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      // Future.delayed(const Duration(milliseconds: 0), () {
      //   if (message.isNotEmpty) {
      //     FlushbarHelper.createError(
      //       message: message,
      //       title: Lang.get('profile_change_error'),
      //       duration: const Duration(seconds: 3),
      //     ).show(context);
      //   }
      // });
    }

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _descriptionController.dispose();
    _companyNameController.dispose();
    _websiteURLController.dispose();
    super.dispose();
  }
}
