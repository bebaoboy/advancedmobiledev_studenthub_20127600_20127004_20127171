import 'package:boilerplate/domain/entity/account/account.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:flutter/material.dart';

class StudentAccountWidget extends StatefulWidget {
  final Account name;
  final bool isLoggedIn;
  final VoidCallback? onTap;

  const StudentAccountWidget(
      {super.key, required this.name, this.isLoggedIn = false, this.onTap});

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
    // Widget subtitleWidget = Text(widget.name.user.email,
    //     style: Theme.of(context).textTheme.bodyLarge);
    Icon profileIcon = Icon(
      Icons.person,
      color: widget.name.user.type == UserType.student && widget.isLoggedIn
          ? Theme.of(context).colorScheme.primary
          : null,
    );

    return ListTile(
      onTap: widget.onTap,
      textColor: Theme.of(context)
          .colorScheme
          .primary
          .withOpacity(widget.isLoggedIn ? 0.5 : 0),
      leading: widget.name.type == UserType.student
          ? widget.name.user.studentProfile != null
              ? profileIcon
              : const Icon(Icons.person_off)
          : const Icon(Icons.no_cell),
      title: titleWidget,
      // subtitle:
      //     widget.name.user.type != UserType.naught ? subtitleWidget : null,
    );
  }
}
