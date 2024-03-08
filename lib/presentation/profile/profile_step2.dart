import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/setting/setting.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../constants/strings.dart';
import '../../di/service_locator.dart';
import 'store/form/profile_form_store.dart';

enum CompanySize {
  single, // 1

}

class ProfileStep2Screen extends StatefulWidget {
  @override
  _ProfileStep2ScreenState createState() => _ProfileStep2ScreenState();
}

class _ProfileStep2ScreenState extends State<ProfileStep2Screen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final ProfileFormStore _formStore = getIt<ProfileFormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //textEdittingController
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _websiteURLController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late FocusNode _companyFocusNode;

  CompanySize _companySize = CompanySize.single;

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
      IconButton(onPressed: () => {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute2(routeName: Routes.login), (Route<dynamic> route) => false)
      }, icon: const Icon(Icons.person_rounded))
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
              child: CustomProgressIndicatorWidget(),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildCompanySizeSelection(BuildContext context) {
    int length = CompanySize.values.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        for (int i = 1; i <= length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: i > CompanySize.values.length + 1
                ? null
                : () {
                    setState(() {
                      _companySize = CompanySize.values[i - 1];
                    });
                  },
            title: Text(
                AppLocalizations.of(context)
                    .translate('profile_question_1_choice_$i'),
                style: Theme.of(context).textTheme.bodyText1),
            leading: Radio<CompanySize>(
              value: CompanySize.values[i - 1],
              groupValue: _companySize,
              onChanged: i > CompanySize.values.length + 1
                  ? null
                  : (CompanySize? value) => {
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
              AppLocalizations.of(context)
                  .translate('profile_question_title_2'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextFieldWidget(
              inputDecoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              inputType: TextInputType.name,
              icon: Icons.person,
              iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
              textController: _companyNameController,
              inputAction: TextInputAction.next,
              autoFocus: true,
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
              AppLocalizations.of(context)
                  .translate('profile_question_title_3'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextFieldWidget(
              inputDecoration: InputDecoration(
                border: const OutlineInputBorder(
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
          AppLocalizations.of(context).translate('profile_question_title_4'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))),
          onChanged: (value) {
            _formStore.setDescription(_descriptionController.text);
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
                AppLocalizations.of(context).translate('profile_welcome_title'),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
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
                        _buildCompanySizeSelection(context),
                        const SizedBox(
              height: 30,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    onPressed: () => navigate(context),
                    color: Colors.orange,
                    child: Text(
                      AppLocalizations.of(context).translate('profile_edit'),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  SizedBox(width: 15,),
                  MaterialButton(
                    onPressed: () => navigate(context),
                    color: Colors.orange,
                    child: Text(
                      AppLocalizations.of(context).translate('profile_cancel'),
                      style: Theme.of(context).textTheme.bodyText1,
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
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.setting, (Route<dynamic> route) => false);
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
            title:
                AppLocalizations.of(context).translate('profile_change_error'),
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
