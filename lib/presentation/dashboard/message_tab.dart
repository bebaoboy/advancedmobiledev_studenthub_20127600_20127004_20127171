import 'package:boilerplate/core/widgets/refresh_indicator/indicators/plane_indicator.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({super.key});

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  final List<Map<String, dynamic>> messages = [
    {
      'icon': Icons.message,
      'name': 'Luis Pham',
      'role': 'Senior frontend developer (Fintech)',
      'message': 'Clear expectation about your project or deliverables',
      'date': '6/6/2024'
    },
    {
      'icon': Icons.message,
      'name': 'John Doe',
      'role': 'Junior backend developer (Healthcare)',
      'message': 'Looking forward to working with you',
      'date': '7/6/2024'
    },
    {
      'icon': Icons.message,
      'name': 'Xingapore',
      'role': 'Sey',
      'message': 'Clear expectation about your project or deliverables',
      'date': '6/6/2024'
    },
    {
      'icon': Icons.message,
      'name': 'Malaysia Nguyen',
      'role': 'Doctor',
      'message': 'Looking forward to working with you',
      'date': '7/6/2024'
    },
    // Add more messages here
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: _buildMessageContent(),
    );
  }

  Widget _buildMessageContent() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          top: 0,
          child: PlaneIndicator(
            onRefresh: () => Future.delayed(const Duration(seconds: 3)),
            child: Stack(children: [
              Positioned.fill(
                top: 80,
                child: ListView.separated(
                  controller: ScrollController(),
                  itemCount: messages.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.black),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        //print('Tile clicked');
                        Navigator.of(
                                NavigationService.navigatorKey.currentContext!)
                            .push(MaterialPageRoute2(
                                routeName: Routes.message,
                                arguments: messages[index]['name']));
                        // You can replace the print statement with your function
                      },
                      child: ListTile(
                        tileColor: Colors.transparent,
                        leading: Icon(messages[index]
                            ['icon']), // Replace with actual icons
                        title: Text(
                          messages[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(messages[index]['role']),
                            Text(messages[index]['message']),
                          ],
                        ),
                        trailing: Text(messages[index]['date']),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: Lang.get("search"),
              hintText: Lang.get("search"),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
