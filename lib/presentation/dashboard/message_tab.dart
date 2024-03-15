import 'package:flutter/material.dart';

class MessageTab extends StatefulWidget {
  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  @override
  Widget build(BuildContext context) {
    return _buildMessageContent();
  }

  Widget _buildMessageContent() {
    return const Column(
      children: <Widget>[
        Text("This is message page"),
      ],
    );
  }
}
