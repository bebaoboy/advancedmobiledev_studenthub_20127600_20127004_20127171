import 'package:boilerplate/core/widgets/refresh_indicator/indicators/plane_indicator.dart';
import 'package:boilerplate/core/widgets/refresh_indicator/widgets/example_app_bar.dart';
import 'package:boilerplate/core/widgets/refresh_indicator/widgets/example_list.dart';
import 'package:flutter/material.dart';

class PlaneIndicatorScreen extends StatefulWidget {
  const PlaneIndicatorScreen({super.key});

  @override
  State<PlaneIndicatorScreen> createState() => _PlaneIndicatorScreenState();
}

class _PlaneIndicatorScreenState extends State<PlaneIndicatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: PlaneIndicator(
        onRefresh: ()=>Future.value(),
        child: const ExampleList(),
      ),
    );
  }
}
