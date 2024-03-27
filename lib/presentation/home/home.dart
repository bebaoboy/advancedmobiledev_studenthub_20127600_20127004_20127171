import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/presentation/dashboard/what.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                      Text(Lang.get('home_title')),
                      const SizedBox(height: 30),
                      Text(Lang.get('home_intro')),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: RoundedButtonWidget(
                          onPressed: () {
                            // Handle your action
                            Navigator.of(context).push(
                              MaterialPageRoute2(routeName: Routes.welcome),
                            );
                          },
                          buttonText: Lang.get('company'),
                          buttonColor: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: RoundedButtonWidget(
                          onPressed: () {
                            // Handle your action
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const What(),),
                            );
                          },
                          buttonText: Lang.get('student'),
                          buttonColor: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  )),
              Text(Lang.get('home_description')),
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
