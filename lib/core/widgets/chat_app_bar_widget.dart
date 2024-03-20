import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 30,
      titleSpacing: 0,
      toolbarHeight: 250,
      title: Container(
          margin: const EdgeInsets.only(left: 20),
          child: Text(title,)),
      actions: [
        // LanguageButton(),
        // ThemeButton(),
        IconButton(
          onPressed: () {
            Navigator.of(context)
              ..push(MaterialPageRoute2(routeName: Routes.setting));
          },
          icon: const Icon(
            Icons.expand_circle_down_outlined,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(0.0, 60.0);
}
