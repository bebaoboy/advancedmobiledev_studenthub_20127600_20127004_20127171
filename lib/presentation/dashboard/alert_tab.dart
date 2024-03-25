import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class AlertTab extends StatefulWidget {
  const AlertTab({super.key});

  @override
  State<AlertTab> createState() => _AlertTabState();
}

class _AlertTabState extends State<AlertTab> {
  final List<Map<String, dynamic>> alerts = [
    {
      'icon': Icons.star,
      'title': 'You have submitted to join project "Javis - AI Copilot"',
      'subtitle': '6/6/2024',
      'action': null,
    },
    {
      'icon': Icons.star,
      'title':
          'You have invited to interview for project "Javis - AI Copilot" at 14:00 March 20, Thursday',
      'subtitle': '6/6/2024',
      'action': 'Join',
    },
    {
      'icon': Icons.star,
      'title': 'You have offer to join project "Javis - AI Copilot"',
      'subtitle': '6/6/2024',
      'action': 'View offer',
    },
    {
      'icon': Icons.star,
      'title': 'Alex Jor',
      'subtitle':
          'I have read your requirement but I dont seem to...?\n6/6/2024',
      'action': null,
    },
    {
      'icon': Icons.star,
      'title': 'Alex Jor',
      'subtitle': 'Finish your project?\n6/6/2024',
      'action': null,
    },
    {
      'icon': Icons.star,
      'title': 'Alex Jor',
      'subtitle': 'How are you doing?\n6/6/2024',
      'action': null,
    },

    {
      'icon': Icons.star,
      'title': 'You have an offer to join project "Quantum Physics"',
      'subtitle': '6/6/2024',
      'action': 'View offer',
    },
    {
      'icon': Icons.star,
      'title': 'You have an offer to join project "HCMUS - Administration"',
      'subtitle': '6/6/2024',
      'action': 'View offer',
    },
    // Add more alerts here
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: _buildAlertsContent(),
    );
  }

  Widget _buildAlertsContent() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.black),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  print('Tile clicked');
                  // You can replace the print statement with your function
                },
                child: ListTile(
                  leading: Icon(alerts[index]['icon']),
                  title: Text(alerts[index]['title']),
                  subtitle: Text(alerts[index]['subtitle']),
                  trailing: alerts[index]['action'] != null
                      ? ElevatedButton(
                          onPressed: () {
                            print('${alerts[index]['action']} button clicked');
                            if (alerts[index]['action'] != null) {
                              if (alerts[index]['action'] == "Join") {
                                Navigator.of(NavigationService
                                        .navigatorKey.currentContext!)
                                    .push(MaterialPageRoute2(
                                        routeName: Routes.message,
                                        arguments: "Javis - AI Copilot"));
                              } else if (alerts[index]['action'] ==
                                  "View offer") {}
                            }
                            // You can replace the print statement with your function
                          },
                          child: Text(Lang.get(alerts[index]['action'])),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
