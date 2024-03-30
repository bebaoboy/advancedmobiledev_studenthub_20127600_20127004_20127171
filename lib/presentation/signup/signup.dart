import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/signup/store/signup_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/service_locator.dart';

class RadioModel {
  bool isSelected;
  final IconData icon;
  String text;
  final Color selectedColor;
  final Color defaultColor;

  RadioModel(this.isSelected, this.icon, this.text, this.selectedColor,
      this.defaultColor);
}

class RadioItem extends StatefulWidget {
  final RadioModel _item;

  const RadioItem(this._item, {super.key});

  @override
  State<RadioItem> createState() => _RadioItemState();
}

class _RadioItemState extends State<RadioItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height: 50.0,
                width: 50.0,
                child: Center(
                  child: Icon(
                    widget._item.icon,
                    color: widget._item.isSelected
                        ? widget._item.selectedColor
                        : widget._item.defaultColor,
                  ),
                ),
              ),
              const Spacer(), // use Spacer
              Checkbox(
                checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: widget._item.isSelected,
                shape: const CircleBorder(),
                onChanged: (bool? value) {
                  // setState(() {
                  //   _item.isSelected = value!;
                  // });
                },
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 10.0),
            child: AutoSizeText(
              widget._item.text,
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: widget._item.isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: widget._item.isSelected
                    ? widget._item.selectedColor
                    : widget._item.defaultColor,
              ),
              minFontSize: 15,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final SignupStore _signupStore = getIt<SignupStore>();

  var type = UserType.naught;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sampleData.isEmpty) {
      sampleData.add(RadioModel(
          false,
          Icons.account_box_outlined,
          Lang.get("signup_student_role_text"),
          Theme.of(context).colorScheme.primary,
          Colors.black));
      sampleData.add(RadioModel(
          false,
          Icons.business,
          Lang.get("signup_company_role_text"),
          Theme.of(context).colorScheme.primary,
          Colors.black));
    } else {
      sampleData[0].text = Lang.get("signup_student_role_text");
      sampleData[1].text = Lang.get("signup_company_role_text");
    }
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

  List<RadioModel> sampleData = List.empty(growable: true);

  Widget _buildRightSide() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height *
                (MediaQuery.of(context).orientation == Orientation.landscape
                    ? 1.4
                    : 1)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 24.0),
            Center(
              child: AutoSizeText(
                Lang.get('signup_main_text'),
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
                    _buildAccountTypeRadioGroup(),
                    // _buildForgotPasswordButton(),
                    _buildSignUpButton(),
                    const SizedBox(height: 24.0),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeRadioGroup() {
    return SizedBox(
        height: 280,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: sampleData[0].isSelected
                      ? const Color.fromARGB(53, 141, 141, 141)
                      : _themeStore.darkMode
                          ? const Color.fromARGB(255, 233, 233, 233)
                          : Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10.0) //         <--- border radius here
                      )),
              child: InkWell(
                //highlightColor: Colors.red,
                splashColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  setState(() {
                    sampleData[1].isSelected = false;
                    sampleData[0].isSelected = true;
                    type = UserType.student;
                  });
                },
                child: RadioItem(sampleData[0]),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: sampleData[1].isSelected
                      ? const Color.fromARGB(53, 141, 141, 141)
                      : _themeStore.darkMode
                          ? const Color.fromARGB(255, 233, 233, 233)
                          : Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10.0) //         <--- border radius here
                      )),
              child: InkWell(
                //highlightColor: Colors.red,
                splashColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  setState(() {
                    sampleData[0].isSelected = false;
                    sampleData[1].isSelected = true;
                    type = UserType.company;
                  });
                },
                child: RadioItem(sampleData[1]),
              ),
            )
          ],
        ));
  }

  Widget _buildSignUpButton() {
    return RoundedButtonWidget(
      buttonText: Lang.get('signup_btn_sign_up'),
      buttonColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
      onPressed: () async {
        if (type == UserType.naught) {
          _showErrorMessage("Select a role to continue");
        } else {
          _signupStore.setUserType(type);
          Navigator.of(context).push(MaterialPageRoute2(
              routeName: sampleData[0].isSelected
                  ? Routes.signUpStudent
                  : Routes.signUpCompany));
        }
      },
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(const Duration(milliseconds: 0), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute2(routeName: Routes.home),
          (Route<dynamic> route) => false);
    });

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
    super.dispose();
  }
}
