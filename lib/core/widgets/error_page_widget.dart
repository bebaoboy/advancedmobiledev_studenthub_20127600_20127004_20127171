import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorPage({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/error.jpg'),
            const SizedBox(height: 12),
            Text(
              kDebugMode
                  ? errorDetails.summary.toString()
                  : 'Oups! Something went wrong!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: kDebugMode ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 21),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: AutoSizeText(
                    minFontSize: 11,
                    kDebugMode
                        // ? 'https://docs.flutter.dev/testing/errors'
                        ? errorDetails.stack.toString()
                        : "We encountered an error and have notified our engineering team about it. Sorry for this inconvenience :'(.",
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            RoundedButtonWidget(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute2(routeName: Routes.splash),
                    (Route<dynamic> route) => false);
              },
              buttonText: Lang.get('continue'),
              buttonColor: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
