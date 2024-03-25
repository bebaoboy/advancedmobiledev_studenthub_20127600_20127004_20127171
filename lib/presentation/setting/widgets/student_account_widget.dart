import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class StudentAccountWidget extends StatelessWidget {
  final String name;

  const StudentAccountWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    Widget titleWidget =
        Text(name, style: Theme.of(context).textTheme.bodySmall);
    Widget subtitleWidget =
        Text(Lang.get('student'), style: Theme.of(context).textTheme.bodyLarge);
    Icon profileIcon = const Icon(Icons.person);

    return ListTile(
      leading: profileIcon,
      title: titleWidget,
      subtitle: subtitleWidget,
      onTap: (() => print(name)),
    );
  }
}
