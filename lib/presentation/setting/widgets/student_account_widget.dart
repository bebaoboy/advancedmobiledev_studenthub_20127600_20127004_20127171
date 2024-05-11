import 'package:boilerplate/domain/entity/account/account.dart';
import 'package:flutter/material.dart';

class StudentAccountWidget extends StatefulWidget {
  final Account name;
  final bool isLoggedIn;
  final bool isLoggedInProfile;
  final VoidCallback? onTap;

  const StudentAccountWidget(
      {super.key,
      required this.name,
      this.isLoggedIn = false,
      this.onTap,
      this.isLoggedInProfile = false});

  @override
  State<StudentAccountWidget> createState() => _StudentAccountWidgetState();
}

class _StudentAccountWidgetState extends State<StudentAccountWidget> {
  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
        widget.name.user.name + (widget.name.user.isVerified ? " (*)" : ""),
        style: widget.isLoggedIn
            ? Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5))
            : Theme.of(context).textTheme.bodySmall);

    var icon = widget.isLoggedIn ? Icons.person : Icons.no_cell;
    if (widget.name.user.studentProfile == null) icon = Icons.person_off;
    Icon profileIcon = Icon(
      icon,
      color: widget.isLoggedIn && widget.isLoggedInProfile
          ? Theme.of(context).colorScheme.primary
          : null,
    );

    return ListTile(
      onTap: widget.onTap,
      textColor: Theme.of(context)
          .colorScheme
          .primary
          .withOpacity(widget.isLoggedIn ? 0.5 : 0),
      leading: profileIcon,
      title: titleWidget,
    );
  }
}
