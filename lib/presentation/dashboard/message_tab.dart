import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:flutter/material.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({super.key});

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  @override
  Widget build(BuildContext context) {
    return _buildMessageContent();
  }

  Widget _buildMessageContent() {
    return Column(
      children: <Widget>[
        Center(
            child: RoundedButtonWidget(
          buttonText: "Open Chat",
          onPressed: () {

          },
        )),
      ],
    );
  }
}
