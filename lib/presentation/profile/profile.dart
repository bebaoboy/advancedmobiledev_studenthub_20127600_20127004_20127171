import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/core/widgets/under_text_field_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:toastification/toastification.dart';

import '../../di/service_locator.dart';
import 'store/form/profile_form_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final ProfileFormStore _formStore = getIt<ProfileFormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //textEdittingController
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _websiteURLController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();

  late FocusNode _companyFocusNode;

  CompanyScope _companySize = CompanyScope.solo;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return const MainAppBar();
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
      child: Stack(children: <Widget>[
        Center(child: _buildRightSide()),
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
    );
  }

  Widget _buildCompanySizeSelection(BuildContext context) {
    int length = CompanyScope.values.length;
    return Observer(
        builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                for (int i = 1; i <= length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: i > CompanyScope.values.length + 1
                        ? null
                        : () {
                            setState(() {
                              _companySize = CompanyScope.values[i - 1];
                              _formStore.setCompanyScope(_companySize);
                            });
                          },
                    title: Text(Lang.get('profile_question_1_choice_$i'),
                        style: Theme.of(context).textTheme.bodyLarge),
                    leading: Radio<CompanyScope>(
                      value: CompanyScope.values[i - 1],
                      groupValue: _companySize,
                      onChanged: i > CompanyScope.values.length + 1
                          ? null
                          : (CompanyScope? value) {
                              setState(() => _companySize = value!);
                              _formStore
                                  .setCompanyScope(value ?? CompanyScope.solo);
                            },
                    ),
                  ),
              ],
            ));
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
            const SizedBox(
              height: 8,
            ),
            BorderTextField(
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
              errorText: _formStore.profileFormErrorStore.companyName == null
                  ? null
                  : Lang.get(_formStore.profileFormErrorStore.companyName),
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
            const SizedBox(
              height: 8,
            ),
            BorderTextField(
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
              errorText: _formStore.profileFormErrorStore.website == null
                  ? null
                  : Lang.get(_formStore.profileFormErrorStore.website),
              onFieldSubmitted: (value) =>
                  {FocusScope.of(context).requestFocus(_companyFocusNode)},
            ),
          ],
        );
      },
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Observer(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Lang.get('profile_question_title_4'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(
            height: 8,
          ),
          BorderTextField(
            inputDecoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black))),
            onChanged: (value) {
              _formStore.setDescription(_descriptionController.text);
            },
            textController: _descriptionController,
            // onSubmitted: (value) =>
            //     {FocusScope.of(context).requestFocus(_companyFocusNode)},
            minLines: 3,
            maxLines: 5,
            errorText: null,
            isIcon: false,
          ),
        ],
      ),
    );
  }

//   Widget _buildEmailField(BuildContext context) {
//     return Observer(
//       builder: (context) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               Lang.get('signup_company_et_email'),
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//             BorderTextField(
//               inputDecoration: const InputDecoration(
//                 border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black)),
//               ),
//               inputType: TextInputType.emailAddress,
//               icon: Icons.web,
//               autoFocus: false,
//               iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
//               textController: _emailController,
//               inputAction: TextInputAction.next,
//               onChanged: (value) {
//                 _formStore.setEmail(_emailController.text);
//               },
//               errorText: _formStore.profileFormErrorStore.email == null
//                   ? null
//                   : Lang.get(_formStore.profileFormErrorStore.email),
//               // onFieldSubmitted: (value) =>
//               //     {FocusScope.of(context).requestFocus(_companyFocusNode)},
//             ),
//           ],
//         );
//       },
//     );
//   }

  // Widget _buildEmailField(BuildContext context) {
  //   return Observer(
  //     builder: (context) {
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             Lang.get('signup_company_et_email'),
  //             style: Theme.of(context).textTheme.bodySmall,
  //           ),
  //           TextFieldWidget(
  //             inputDecoration: const InputDecoration(
  //               border: OutlineInputBorder(
  //                   borderSide: BorderSide(color: Colors.black)),
  //             ),
  //             inputType: TextInputType.emailAddress,
  //             icon: Icons.web,
  //             autoFocus: false,
  //             iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
  //             textController: _emailController,
  //             inputAction: TextInputAction.next,
  //             onChanged: (value) {
  //               _formStore.setEmail(_emailController.text);
  //             },
  //             errorText: _formStore.profileFormErrorStore.email == null
  //                 ? null
  //                 : Lang.get(_formStore.profileFormErrorStore.email),
  //             // onFieldSubmitted: (value) =>
  //             //     {FocusScope.of(context).requestFocus(_companyFocusNode)},
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              height: 10,
            ),
            Center(
              child: Text(
                Lang.get('profile_common_body'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              Lang.get('profile_question_title_1'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            _buildCompanySizeSelection(context),
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
            // _buildEmailField(context),
            // const SizedBox(
            //   height: 25,
            // ),
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RoundedButtonWidget(
                    buttonText: Lang.get('continue'),
                    buttonColor: Theme.of(context).colorScheme.primary,
                    textColor: Colors.white,
                    onPressed: () {
                      _formStore.setEmail("a@gmail.com");
                      if (_formStore.canContinue) {
                        _formStore.addProfileCompany(
                            _companyNameController.text,
                            _websiteURLController.text,
                            _descriptionController.text,
                            _companySize);
                        // navigate(context);
                      } else {
                        _showErrorMessage(
                            Lang.get('login_error_missing_fields'));
                      }
                    },
                  ),
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_formStore.success) {
        _formStore.success = false;
        showAnimatedDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return ClassicGeneralDialogWidget(
              contentText:
                  '${_formStore.companyName} create profile successfully!',
              positiveText: 'OK',
              onPositiveClick: () {
                Navigator.of(context).pop();
                _userStore.user?.type = UserType.company;

                Navigator.of(NavigationService.navigatorKey.currentContext ??
                        context)
                    .pushAndRemoveUntil(
                        MaterialPageRoute2(
                            routeName: Routes.welcome, arguments: true),
                        (Route<dynamic> route) => false);
                return;
              },
            );
          },
          animationType: DialogTransitionType.size,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(seconds: 1),
        );
      }
      // _formStore.addProfileCompanyFuture;
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute2(routeName: Routes.login),
      //     (Route<dynamic> route) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          Toastify.show(context, Lang.get('profile_change_error'), message,
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
    _descriptionController.dispose();
    _companyNameController.dispose();
    _websiteURLController.dispose();
    super.dispose();
  }
}
