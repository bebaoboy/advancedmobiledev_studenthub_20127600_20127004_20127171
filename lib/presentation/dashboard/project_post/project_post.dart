import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_dialog/material_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectPostScreen extends StatefulWidget {
  const ProjectPostScreen({super.key});

  @override
  State<ProjectPostScreen> createState() => _ProjectPostScreenState();
}

class _ProjectPostScreenState extends State<ProjectPostScreen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  int _startIndex = 0;
  String title = "";
  String duration = "";
  String number = "";
  String description = "";
  String? groupValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: _startIndex == 0
            ? _buildOneContent()
            : _startIndex == 1
                ? _buildTwoContent()
                : _startIndex == 2
                    ? _buildThreeContent()
                    : _buildFourContent(),
      ),
    );
  }

  Widget _buildOneContent() {
    final controller1 = TextEditingController();
    return Column(
      children: <Widget>[
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(AppLocalizations.of(context).translate('1/4'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child:
              Text(AppLocalizations.of(context).translate('description_title')),
        ),
        SizedBox(
          height: 20,
        ),
        TextField(
          controller: controller1,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: AppLocalizations.of(context).translate('title_guide'),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(AppLocalizations.of(context).translate('examples_title')),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
              AppLocalizations.of(context).translate('example_description')),
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: SizedBox(
                  width: 150,
                  height: 50,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        title = controller1.text;
                        _startIndex++;
                      });
                    },
                    child:
                        Text(AppLocalizations.of(context).translate('scope')),
                  ))),
        ),
      ],
    );
  }

  Widget _buildTwoContent() {
    final controller2 = TextEditingController();

    return Column(
      children: <Widget>[
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(AppLocalizations.of(context).translate('2/4'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(AppLocalizations.of(context).translate('scope_title')),
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(AppLocalizations.of(context).translate('how_long'),
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context).translate('1-3')),
          value: '1 to 3 months',
          groupValue: groupValue,
          onChanged: (String? value) {
            setState(() {
              groupValue = value;
            });
          },
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context).translate('3-6')),
          value: '3 to 6 months',
          groupValue: groupValue,
          activeColor: Colors.red,
          onChanged: (String? value) {
            setState(() {
              groupValue = value;
            });
          },
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(AppLocalizations.of(context).translate('how_many'),
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: controller2,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: AppLocalizations.of(context).translate('number'),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: SizedBox(
                  width: 150,
                  height: 50,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        number = controller2.text;
                        duration = groupValue ?? 'Not estimated yet';
                        _startIndex++;
                      });
                    },
                    child: Text(AppLocalizations.of(context)
                        .translate('Next_Description')),
                  ))),
        ),
      ],
    );
  }

  Widget _buildThreeContent() {
    final controller3 = TextEditingController();

    return Column(
      children: <Widget>[
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(AppLocalizations.of(context).translate('3/4'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(AppLocalizations.of(context).translate('looking')),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
              AppLocalizations.of(context).translate('looking_description')),
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
              AppLocalizations.of(context).translate('project_describe'),
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 20,
        ),
        TextField(
          maxLines: 5,
          controller: controller3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: '',
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: SizedBox(
                  width: 150,
                  height: 50,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        description = controller3.text;
                        _startIndex++;
                      });
                    },
                    child:
                        Text(AppLocalizations.of(context).translate('review')),
                  ))),
        ),
      ],
    );
  }

  Widget _buildFourContent() {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(AppLocalizations.of(context).translate('4/4'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text("$title"),
        ),
        SizedBox(
          height: 20,
        ),
        Divider(color: Colors.black),
        Align(
          alignment: Alignment.topLeft,
          child: Text("$description"),
        ),
        Divider(color: Colors.black),
        SizedBox(
          height: 20,
        ),
        Row(
          children: <Widget>[
            Icon(Icons.alarm),
            SizedBox(
                width:
                    10), // You can adjust the space between the icon and the text
            Text(AppLocalizations.of(context).translate('project_scope') +
                '\n  - $duration'),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            Icon(Icons.people),
            SizedBox(
                width:
                    10), // You can adjust the space between the icon and the text
            Text(AppLocalizations.of(context).translate('student_require') +
                '\n  - $number'),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: SizedBox(
                  width: 150,
                  height: 50,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context)
                        ..pushAndRemoveUntil(
                            MaterialPageRoute2(routeName: Routes.dashboard),
                            (Route<dynamic> route) => false);
                    },
                    child: Text(
                        AppLocalizations.of(context).translate('post_job')),
                  ))),
        ),
      ],
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).translate('appbar_title')),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      _buildLanguageButton(),
      _buildThemeButton(),
      _buildProfileButton(),
      _buildLogoutButton(),
    ];
  }

  Widget _buildProfileButton() {
    return Observer(
      builder: (context) {
        return IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person, size: 25),
        );
      },
    );
  }

  Widget _buildThemeButton() {
    return Observer(
      builder: (context) {
        return IconButton(
          onPressed: () {
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
          icon: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      onPressed: () {
        SharedPreferences.getInstance().then((preference) {
          preference.setBool(Preferences.is_logged_in, false);
          Navigator.of(context)
            ..pushAndRemoveUntil(MaterialPageRoute2(routeName: Routes.login),
                (Route<dynamic> route) => false);
        });
      },
      icon: const Icon(
        Icons.power_settings_new,
      ),
    );
  }

  Widget _buildLanguageButton() {
    return IconButton(
      onPressed: () {
        _buildLanguageDialog();
      },
      icon: const Icon(
        Icons.language,
      ),
    );
  }

  _buildLanguageDialog() {
    _showDialog<String>(
      context: context,
      child: MaterialDialog(
        borderRadius: 5.0,
        enableFullWidth: true,
        title: Text(
          AppLocalizations.of(context).translate('home_tv_choose_language'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        headerColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        closeButtonColor: Colors.white,
        enableCloseButton: true,
        enableBackButton: false,
        onCloseButtonClicked: () {
          Navigator.of(context).pop();
        },
        children: _languageStore.supportedLanguages
            .map(
              (object) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.all(0.0),
                title: Text(
                  object.language,
                  style: TextStyle(
                    color: _languageStore.locale == object.locale
                        ? Theme.of(context).primaryColor
                        : _themeStore.darkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // change user language based on selected locale
                  _languageStore.changeLanguage(object.locale);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  _showDialog<T>({required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
    });
  }
}
