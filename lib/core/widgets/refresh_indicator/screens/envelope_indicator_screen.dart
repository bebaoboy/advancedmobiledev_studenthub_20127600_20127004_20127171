import 'package:boilerplate/core/widgets/refresh_indicator/indicators/envelope_indicator.dart';
import 'package:boilerplate/core/widgets/refresh_indicator/widgets/example_app_bar.dart';
import 'package:boilerplate/core/widgets/refresh_indicator/widgets/example_list.dart';
import 'package:flutter/material.dart';

class EnvelopIndicatorScreen extends StatelessWidget {
  const EnvelopIndicatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(
        title: "Envelope indicator",
      ),
      body: EnvelopRefreshIndicator(
        accent: appContentColor,
        onRefresh: () => Future<void>.delayed(const Duration(seconds: 2)),
        child: const ExampleList(),
      ),
    );
  }
}
