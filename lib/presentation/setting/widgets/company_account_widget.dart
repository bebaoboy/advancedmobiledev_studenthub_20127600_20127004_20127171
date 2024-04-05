import 'package:boilerplate/domain/entity/account/account.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:flutter/material.dart';

class CompanyAccountWidget extends StatefulWidget {
  final Account name;
  final VoidCallback? onPressedNext;
  final onTap;
  final bool isLoggedIn;
  final bool isLoggedInProfile;

  const CompanyAccountWidget(
      {super.key,
      required this.name,
      this.onPressedNext,
      this.onTap,
      this.isLoggedIn = false,
      this.isLoggedInProfile = false,});

  @override
  State<CompanyAccountWidget> createState() => _CompanyAccountWidgetState();
}

class _CompanyAccountWidgetState extends State<CompanyAccountWidget> {
  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
        widget.name.user.name + (widget.name.user.isVerified ? " (*)" : ""),
        style: widget.isLoggedIn
            ? Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5))
            : Theme.of(context).textTheme.bodySmall);
    Widget subtitleWidget = Text(widget.name.user.email,
        style: Theme.of(context).textTheme.bodyLarge);
    var icon = widget.isLoggedIn ? Icons.business : Icons.no_cell;
    if (widget.name.user.companyProfile == null) icon = Icons.tv_off;
    Icon profileIcon = Icon(
      icon,
      color: widget.isLoggedInProfile
          ? Theme.of(context).colorScheme.primary
          : null,
    );

    // IconButton expandButton = IconButton(
    //   icon: const Icon(Icons.navigate_next),
    //   onPressed: onPressedNext,
    // );

    return Column(
      children: [
        ListTile(
          onTap: widget.onTap,
          textColor: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(widget.isLoggedIn ? 0.5 : 0),
          leading: profileIcon,
          title: titleWidget,
          subtitle:
              widget.name.type == UserType.company ? subtitleWidget : null,
          // trailing: expandButton,
        ),
        const Divider(
          height: 3,
        )
      ],
    );
  }
}
