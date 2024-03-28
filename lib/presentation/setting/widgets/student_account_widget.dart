import 'package:boilerplate/domain/entity/account/account.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:flutter/material.dart';

class StudentAccountWidget extends StatelessWidget {
  final Account name;
  final bool isLoggedIn;
  final VoidCallback? onTap;

  const StudentAccountWidget(
      {super.key, required this.name, this.isLoggedIn = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(name.user.name,
        style: isLoggedIn ? Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.5)) : Theme.of(context).textTheme.bodySmall);
    Widget subtitleWidget =
        Text(name.user.email, style: Theme.of(context).textTheme.bodyLarge);
    Icon profileIcon = const Icon(Icons.person);

    return ListTile(
      onTap: onTap,
      textColor: Theme.of(context)
          .colorScheme
          .primary
          .withOpacity(isLoggedIn ? 0.5 : 0),
      leading: name.user.type != UserType.naught ?  profileIcon : const Icon(Icons.no_cell),
      title: titleWidget,
      subtitle: name.user.type != UserType.naught ? subtitleWidget: null,
    );
  }
}
