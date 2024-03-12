import 'package:flutter/material.dart';

class CompanyAccountWidget extends StatelessWidget {
  final String name;
  final VoidCallback? onPressedNext;

  const CompanyAccountWidget({super.key, 
    required this.name,
    this.onPressedNext,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget =
        Text(name, style: Theme.of(context).textTheme.bodySmall);
    Widget subtitleWidget =
        Text('company', style: Theme.of(context).textTheme.bodyText1);
    Icon profileIcon = const Icon(Icons.person);

    IconButton expandButton = IconButton(
      icon: const Icon(Icons.navigate_next),
      onPressed: onPressedNext,
    );

    return Column(
      children: [
        ListTile(
          leading: profileIcon,
          title: titleWidget,
          subtitle: subtitleWidget,
          trailing: expandButton,
          onTap: (() => print(name)),
        ),
        const Divider(
          height: 3,
        )
      ],
    );
  }
}
