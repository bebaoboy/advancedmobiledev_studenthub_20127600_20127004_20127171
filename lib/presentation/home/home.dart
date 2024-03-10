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

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    children: [
                      Text(
                          AppLocalizations.of(context).translate('home_title')),
                      SizedBox(height: 30),
                      Text(
                          AppLocalizations.of(context).translate('home_intro')),
                      SizedBox(height: 25),
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: FloatingActionButton(
                          heroTag: "F1",
                          onPressed: () {
                            // Handle your action
                            Navigator.of(context)
                              ..push(
                                MaterialPageRoute2(routeName: Routes.welcome),
                              );
                          },
                          child: Text(AppLocalizations.of(context)
                              .translate('Company_button')),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: FloatingActionButton(
                          heroTag: "F2",
                          onPressed: () {
                            // Handle your action
                          },
                          child: Text(AppLocalizations.of(context)
                              .translate('Student_button')),
                        ),
                      ),
                      SizedBox(height: 25),
                    ],
                  )),
              Text(AppLocalizations.of(context).translate('home_description')),
            ],
          ),
        ),
      ),
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
//       TextButton(
//         onPressed: () async {
//           await FirebaseAnalytics.instance.logEvent(
//             name: "select_content",
//             parameters: {
//               "content_type": "image",
//               "item_id": 1,
//             },
//           );

//           //throw Exception();
//         },
//         child:  Text(AppLocalizations.of(context).translate("exception_test")),
//       ),
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
          icon: Icon(Icons.person, size: 25),
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
      icon: Icon(
        Icons.power_settings_new,
      ),
    );
  }

  Widget _buildLanguageButton() {
    return IconButton(
      onPressed: () {
        _buildLanguageDialog();
      },
      icon: Icon(
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
          style: TextStyle(
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
                contentPadding: EdgeInsets.all(0.0),
                title: Text(
                  object.language!,
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
                  _languageStore.changeLanguage(object.locale!);
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
