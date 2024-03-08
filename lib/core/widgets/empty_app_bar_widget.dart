import 'package:boilerplate/core/widgets/language_button_widget.dart';
import 'package:boilerplate/core/widgets/theme_button_widget.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 30,
      titleSpacing: 0,
      title: Container(
          margin: EdgeInsets.only(left: 20),
          child: Text(AppLocalizations.of(context).translate('appbar_title'))),
      actions: [
        LanguageButton(),
        ThemeButton(),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.account_circle,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}
