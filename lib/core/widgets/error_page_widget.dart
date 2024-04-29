import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Image.asset(
              'assets/images/error.jpg',
              width: 120,
              height: 120,
            )),
            const SizedBox(height: 12),
            Text(
              errorDetails.summary.toString()
,              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: kDebugMode ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Text(
                    kDebugMode
                        // ? 'https://docs.flutter.dev/testing/errors'
                        ? errorDetails.stack.toString()
                        : Lang.get("sorry_text"),
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.black, fontSize: kDebugMode ? 10 : 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            RoundedButtonWidget(
              onPressed: () {
                Navigator.of(context).pop();
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
