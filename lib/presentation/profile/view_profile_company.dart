import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/under_text_field_widget.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../di/service_locator.dart';
import 'store/form/profile_form_store.dart';

// enum CompanyScope {
//   single, // 1
//   small, // 2-9
//   medium, // 10-100
//   large, // 100-1000
//   xLarge // 1000+
// }

class ViewProfileCompany extends StatefulWidget {
  const ViewProfileCompany({super.key});

  @override
  _ViewProfileCompanyState createState() => _ViewProfileCompanyState();
}

class _ViewProfileCompanyState extends State<ViewProfileCompany> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final ProfileFormStore _formStore = getIt<ProfileFormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //textEdittingController
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _websiteURLController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _companyFocusNode = FocusNode();

  CompanyScope _companySize = CompanyScope.solo;
  bool enabled = false;

  @override
  void initState() {
    _formStore.errorStore.errorMessage = "";

    if (_userStore.user != null) {
      if (_userStore.user!.companyProfile != null) {
        _companySize = _userStore.user!.companyProfile!.scope;
        _companyNameController.text =
            _userStore.user!.companyProfile!.companyName;
        _websiteURLController.text = _userStore.user!.companyProfile!.website;
        _descriptionController.text =
            _userStore.user!.companyProfile!.description;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        bool b = !enabled;
        if (enabled) {
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
        }
        return b;
      },
      child: Material(
        child: Stack(children: <Widget>[
          Container(child: _buildRightSide()),
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
                visible: _userStore.isLoading,
                child: const CustomProgressIndicatorWidget(),
              );
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildCompanyScopeSelection(BuildContext context) {
    int length = CompanyScope.values.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        for (int i = 1; i <= length; i++)
          if (_companySize.name == CompanyScope.values[i - 1].name)
            ListTile(
              enabled: enabled,
              contentPadding: EdgeInsets.zero,
              // onTap: i > CompanyScope.values.length + 1
              //     ? null
              //     : () {
              //         setState(() {
              //           _companySize = CompanyScope.values[i - 1];
              //         });
              //       },
              title: Text(Lang.get('profile_question_1_choice_$i'),
                  style: Theme.of(context).textTheme.bodyLarge),
              leading: Radio<CompanyScope>(
                toggleable: false,
                value: CompanyScope.values[i - 1],
                groupValue: _companySize,
                onChanged: i > CompanyScope.values.length + 1
                    ? null
                    : (CompanyScope? value) => {
                          setState(() => _companySize = value!),
                        },
              ),
            ),
      ],
    );
  }

  Widget _buildCompanyNameField(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Lang.get('profile_question_title_2'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            BorderTextField(
              readOnly: !enabled,
              inputDecoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              inputType: TextInputType.name,
              icon: Icons.person,
              iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
              textController: _companyNameController,
              inputAction: TextInputAction.next,
              onChanged: (value) {
                _formStore.setCompanyName(_companyNameController.text);
              },
              errorText: _formStore.profileFormErrorStore.companyName,
            ),
          ],
        );
      },
    );
  }

  Widget _buildWebsiteField(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Lang.get('profile_question_title_3'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            BorderTextField(
              readOnly: !enabled,
              inputDecoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              inputType: TextInputType.url,
              icon: Icons.web,
              autoFocus: false,
              iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
              textController: _websiteURLController,
              inputAction: TextInputAction.next,
              onChanged: (value) {
                _formStore.setWebsite(_websiteURLController.text);
              },
              errorText: _formStore.profileFormErrorStore.website,
              onFieldSubmitted: (value) =>
                  {FocusScope.of(context).requestFocus(_companyFocusNode)},
            ),
          ],
        );
      },
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Lang.get('profile_question_title_4'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        BorderTextField(
          errorText: _formStore.profileFormErrorStore.description,

          readOnly: !enabled,
          inputDecoration: const InputDecoration(
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          ),
          inputType: TextInputType.multiline,
          icon: Icons.person,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          // inputAction: TextInputAction.next,
          onChanged: (value) {
            _formStore.setDescription(_descriptionController.text);
          },
          textController: _descriptionController,
          // onSubmitted: (value) =>
          //     {FocusScope.of(context).requestFocus(_companyFocusNode)},
          minLines: 3,
          maxLines: 5,
          // maxLength: 500,
        ),
        // TextField(
        //   readOnly: !enabled,
        //   decoration: const InputDecoration(
        //       border: OutlineInputBorder(
        //           borderSide: BorderSide(color: Colors.black))),
        //   onChanged: (value) {
        //     _formStore.setDescription(_descriptionController.text);
        //   },
        //   controller: _descriptionController,
        //   onSubmitted: (value) =>
        //       {FocusScope.of(context).requestFocus(_companyFocusNode)},
        //   minLines: 3,
        //   maxLines: 5,
        // ),
      ],
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                Lang.get('profile_welcome_title'),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const SizedBox(
              height: 10,
            ),
            _buildCompanyNameField(context),
            const SizedBox(
              height: 15,
            ),
            _buildWebsiteField(context),
            const SizedBox(
              height: 15,
            ),
            _buildDescriptionField(context),
            const SizedBox(
              height: 25,
            ),
            _buildCompanyScopeSelection(context),
            const SizedBox(
              height: 30,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RoundedButtonWidget(
                    buttonText: enabled ? Lang.get("save") : Lang.get('edit'),
                    buttonColor: Theme.of(context).colorScheme.primary,
                    textColor: Colors.white,

                    onPressed: () {
                      if (enabled) {
                        print("save profile");
                        var id = _userStore.user!.companyProfile!.objectId!;
                        if (_formStore.canContinue) {
                          _formStore.updateProfileCompany(
                              _companyNameController.text,
                              _websiteURLController.text,
                              _descriptionController.text,
                              _companySize,
                              int.tryParse(id) ?? -1);
                        }
                      }

                      setState(() {
                        enabled = !enabled;
                      });
                    },
                    // color: Colors.orange,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  // MaterialButton(
                  //   onPressed: () => navigate(context),
                  //   // color: Colors.orange,
                  //   child: Text(
                  //     Lang.get('cancel'),
                  //     style: Theme.of(context).textTheme.bodyLarge,
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
          ],
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
                  '${_formStore.companyName} update profile successfully!',
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
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: Lang.get('profile_change_error'),
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
    _companyFocusNode.dispose();
    _descriptionController.dispose();
    _companyNameController.dispose();
    _websiteURLController.dispose();
    super.dispose();
  }
}
