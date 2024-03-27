import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class PiPTestScreen extends StatefulWidget {
  const PiPTestScreen({super.key});

  @override
  State<PiPTestScreen> createState() => _PiPTestScreenState();
}

class _PiPTestScreenState extends State<PiPTestScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
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
              const Text("Welcome to PiP"),
              const Text("Enjoy picture-in-picture experience only on android"),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 200,
                height: 50,
                child: RoundedButtonWidget(
                  onPressed: () {
                    // Navigator.of(context).pushAndRemoveUntil(
                    //     MaterialPageRoute2(routeName: Routes.dashboard),
                    //     (Route<dynamic> route) => false);
                  },
                  buttonText: Lang.get('Start_button'),
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
  // PreferredSizeWidget _buildAppBar() {
  //   return PiPAppBar();
  // }
}
