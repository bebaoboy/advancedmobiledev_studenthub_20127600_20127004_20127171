import 'package:boilerplate/core/widgets/refresh_indicator/indicators/plane_indicator.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({super.key, required this.scrollController});
  final ScrollController scrollController;
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
        padding: const EdgeInsets.only(bottom: 20.0),
        child: _buildMessageContent());
  }

  Widget _buildTopRowList() {
    return SizedBox(
      height: 72,
      child: Scrollbar(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 18,
          itemBuilder: (context, index) {
            return Container(
              width: 64,
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => print("flutter"),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: Image.network(
                            'https://docs.flutter.dev/assets/images/404/dash_nest.png',
                            fit: BoxFit.cover,
                          ).image,
                          radius: 50.0,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 1,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          top: 60,
          child: PlaneIndicator(
            onRefresh: () => Future.delayed(const Duration(seconds: 3)),
            child: Stack(children: [
              Positioned.fill(
                top: 30,
                child: ListView.separated(
                  controller: widget.scrollController,
                  itemCount: messages.length + 1,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.black),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: _buildTopRowList());
                    }
                    int index = i - 1;
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
