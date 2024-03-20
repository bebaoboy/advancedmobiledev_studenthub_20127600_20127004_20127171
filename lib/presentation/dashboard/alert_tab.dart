import 'package:flutter/material.dart';

class AlertTab extends StatefulWidget {
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
      'subtitle': 'How are you doing?\n6/6/2024',
      'action': null,
    },
    // Add more alerts here
  ];

  @override
  Widget build(BuildContext context) {
    return _buildAlertsContent();
  }

  Widget _buildAlertsContent() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            itemCount: alerts.length,
            separatorBuilder: (context, index) => Divider(color: Colors.black),
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
                            // You can replace the print statement with your function
                          },
                          child: Text(alerts[index]['action']),
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
