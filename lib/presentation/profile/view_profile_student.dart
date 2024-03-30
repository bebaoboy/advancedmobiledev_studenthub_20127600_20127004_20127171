import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_student_form_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../constants/strings.dart';
import '../../di/service_locator.dart';

class ViewProfileStudent extends StatefulWidget {
  const ViewProfileStudent({super.key});

  @override
  _ViewProfileStudentState createState() => _ViewProfileStudentState();
}

class _ViewProfileStudentState extends State<ViewProfileStudent> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final ProfileStudentFormStore _formStore = getIt<ProfileStudentFormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //textEdittingController
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _websiteURLController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late FocusNode _companyFocusNode;

  bool enabled = false;

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
    return AppBar(
      title: const Text(Strings.appName),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      // IconButton(
      //     onPressed: () => {
      //           Navigator.of(context).pushAndRemoveUntil(
      //               MaterialPageRoute2(routeName: Routes.login),
      //               (Route<dynamic> route) => false)
      //         },
      //     icon: const Icon(Icons.person_rounded))
    ];
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
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
            TextFieldWidget(
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
                // _formStore.setCompanyName(_companyNameController.text);
              },
              errorText: null,
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
            TextFieldWidget(
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
                // _formStore.setWebsite(_websiteURLController.text);
              },
              errorText: null,
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
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))),
          onChanged: (value) {
            // _formStore.setDescription(_descriptionController.text);
          },
          controller: _descriptionController,
          onSubmitted: (value) =>
              {FocusScope.of(context).requestFocus(_companyFocusNode)},
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
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
                "${Lang.get('profile_welcome_title')}, STUDENT",
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
            const SizedBox(
              height: 30,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    onPressed: () {
                      if (enabled) {
                        // TODO: save profile
                        _showErrorMessage("OK");
                      }
                      setState(() {
                        enabled = !enabled;
                      });
                    },
                    // color: Colors.orange,
                    child: Text(
                      enabled ? Lang.get("save") : Lang.get('edit'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  MaterialButton(
                    onPressed: () => navigate(context),
                    // color: Colors.orange,
                    child: Text(
                      Lang.get('cancel'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
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
    Future.delayed(const Duration(milliseconds: 0), () {
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute2(routeName: Routes.setting), (Route<dynamic> route) => false);
      Navigator.of(context).pop();
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
    _descriptionController.dispose();
    _companyNameController.dispose();
    _websiteURLController.dispose();
    super.dispose();
  }
}
