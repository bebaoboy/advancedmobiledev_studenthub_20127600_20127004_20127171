import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
              Text(AppLocalizations.of(context).translate('Welcome')),
              Text(AppLocalizations.of(context).translate('Start')),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 200,
                height: 50,
                child: RoundedButtonWidget(
                  onPressed: () {
                    Navigator.of(context)
                      ..pushAndRemoveUntil(
                          MaterialPageRoute2(routeName: Routes.dashboard),
                          (Route<dynamic> route) => false);
                  },
                  buttonText:
                      AppLocalizations.of(context).translate('Start_button'),
                  buttonColor: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                ),
              ),
            ],
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
