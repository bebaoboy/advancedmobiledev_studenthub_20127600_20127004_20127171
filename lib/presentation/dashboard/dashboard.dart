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

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: _selectedIndex == 0
            ? _buildProjectContent()
            : _selectedIndex == 1
                ? _buildDashBoardContent()
                : _selectedIndex == 2
                    ? _buildMessageContent()
                    : _buildAlertContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
        unselectedLabelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w200),
        unselectedIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.business),
            label: 'Projects',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: 'Dashboard',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.message),
            label: 'Message',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: 'Alerts',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Theme.of(context).colorScheme.background,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDashBoardContent() {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                  AppLocalizations.of(context).translate('Dashboard_your_job')),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 100,
                height: 30,
                child: FloatingActionButton(
                  heroTag: "F3",
                  onPressed: () {
                    Navigator.of(context)
                      ..pushAndRemoveUntil(
                          MaterialPageRoute2(routeName: Routes.project_post),
                          (Route<dynamic> route) => false);
                  },
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('Dashboard_post_job'),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 34,
        ),
        Align(
          alignment: Alignment.center,
          child:
              Text(AppLocalizations.of(context).translate('Dashboard_intro')),
        ),
        Align(
          alignment: Alignment.center,
          child:
              Text(AppLocalizations.of(context).translate('Dashboard_content')),
        ),
      ],
    );
  }

  Widget _buildProjectContent() {
    return const Column(
      children: <Widget>[
        Text("This is project page"),
      ],
    );
  }

  Widget _buildMessageContent() {
    return const Column(
      children: <Widget>[
        Text("This is message page"),
      ],
    );
  }

  Widget _buildAlertContent() {
    return const Column(
      children: <Widget>[
        Text("This is alert page"),
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
