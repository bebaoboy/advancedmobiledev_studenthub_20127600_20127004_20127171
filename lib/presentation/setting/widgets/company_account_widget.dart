import 'package:boilerplate/domain/entity/account/account.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:collection/collection.dart';
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
    Icon profileIcon = Icon(
      Icons.business,
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
          leading: widget.name.type == UserType.company
              ? widget.name.user.roles!.firstWhereOrNull(
                          (element) => element.name == UserType.company.name) !=
                      null
                  ? profileIcon
                  : const Icon(Icons.usb_off)
              : const Icon(Icons.no_cell),
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
