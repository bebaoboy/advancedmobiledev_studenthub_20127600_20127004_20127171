import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
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
              buttonColor: Colors.black,
          buttonText: "Open Chat",
          onPressed: () {
            Navigator.of(NavigationService.navigatorKey.currentContext!)
                .push(MaterialPageRoute2(routeName: Routes.message, arguments: "Demo User Name"));
          },
        )),
      ],
    );
  }
}
