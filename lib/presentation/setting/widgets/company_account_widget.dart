import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class CompanyAccountWidget extends StatelessWidget {
  final String name;
  final VoidCallback? onPressedNext;
  final onTap;

  const CompanyAccountWidget(
      {super.key, required this.name, this.onPressedNext, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget titleWidget =
        Text(name, style: Theme.of(context).textTheme.bodySmall);
    Widget subtitleWidget =
        Text(Lang.get('company'), style: Theme.of(context).textTheme.bodyText1);
    Icon profileIcon = const Icon(Icons.business);

    // IconButton expandButton = IconButton(
    //   icon: const Icon(Icons.navigate_next),
    //   onPressed: onPressedNext,
    // );

    return Column(
      children: [
        ListTile(
          leading: profileIcon,
          title: titleWidget,
          subtitle: subtitleWidget,
          // trailing: expandButton,
        ),
        const Divider(
          height: 3,
        )
      ],
    );
  }
}
