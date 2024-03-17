
import 'package:flutter/material.dart';

class AlertTab extends StatefulWidget {
  @override
  State<AlertTab> createState() => _AlertTabState();
}

class _AlertTabState extends State<AlertTab> {
  @override
  Widget build(BuildContext context) {
    return _buildAlertContent();
  }

  Widget _buildAlertContent() {
    return const Column(
      children: <Widget>[
        Text("This is alert page"),
      ],
    );
  }
}
