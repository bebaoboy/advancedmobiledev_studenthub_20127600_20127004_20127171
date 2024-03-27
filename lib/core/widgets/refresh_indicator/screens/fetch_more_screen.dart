import 'package:boilerplate/core/widgets/refresh_indicator/indicators/swipe_action.dart';
import 'package:boilerplate/core/widgets/refresh_indicator/widgets/example_app_bar.dart';
import 'package:boilerplate/core/widgets/refresh_indicator/widgets/example_list.dart';
import 'package:flutter/material.dart';

class FetchMoreScreen extends StatefulWidget {
  const FetchMoreScreen({super.key});

  @override
  State<FetchMoreScreen> createState() => _FetchMoreScreenState();
}

class _FetchMoreScreenState extends State<FetchMoreScreen> {
  int _itemsCount = 10;

  Future<void> _fetchMore() async {
    // Simulate fetch time
    await Future<void>.delayed(const Duration(seconds: 2));
    // make sure that the widget is still mounted.
    if (!mounted) return;
    // Add more fake elements
    setState(() {
      _itemsCount += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(title: "Scroll to fetch more"),
      body: FetchMoreIndicator(
        onAction: _fetchMore,
        child: ExampleList(
          itemCount: _itemsCount,
          countElements: true,
        ),
      ),
    );
  }
}
