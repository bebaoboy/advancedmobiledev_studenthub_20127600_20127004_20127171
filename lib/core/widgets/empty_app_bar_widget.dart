import 'package:boilerplate/core/widgets/language_button_widget.dart';
import 'package:boilerplate/core/widgets/theme_button_widget.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 30,
      titleSpacing: 0,
      title: Container(
          margin: const EdgeInsets.only(left: 20),
          child: Text(AppLocalizations.of(context).translate('appbar_title'))),
      actions: [
        LanguageButton(),
        ThemeButton(),
        IconButton(
          onPressed: () {
            Navigator.of(context)
              ..push(MaterialPageRoute2(routeName: Routes.setting));
          },
          icon: const Icon(
            Icons.account_circle,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(0.0, 0.0);
}
