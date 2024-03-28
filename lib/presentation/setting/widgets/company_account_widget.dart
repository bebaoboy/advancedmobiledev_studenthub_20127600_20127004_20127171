import 'package:boilerplate/domain/entity/account/account.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class CompanyAccountWidget extends StatelessWidget {
  final Account name;
  final VoidCallback? onPressedNext;
  final onTap;
  final bool isLoggedIn;

  const CompanyAccountWidget(
      {super.key,
      required this.name,
      this.onPressedNext,
      this.onTap,
      this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(name.user.name,
        style: isLoggedIn
            ? Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5))
            : Theme.of(context).textTheme.bodySmall);
    Widget subtitleWidget =
        Text(name.user.email, style: Theme.of(context).textTheme.bodyLarge);
    Icon profileIcon = const Icon(Icons.business);

    // IconButton expandButton = IconButton(
    //   icon: const Icon(Icons.navigate_next),
    //   onPressed: onPressedNext,
    // );

    return Column(
      children: [
        ListTile(
          textColor: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(isLoggedIn ? 0.5 : 0),
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
