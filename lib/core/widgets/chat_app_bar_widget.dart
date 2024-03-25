import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar(
      {super.key, required this.title, required this.openScheduleDialog});
  final String title;
  final Function openScheduleDialog;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 30,
      titleSpacing: 0,
      toolbarHeight: 250,
      title: Container(
          margin: const EdgeInsets.only(left: 20),
          child: Text(
            title,
          )),
      actions: [
        // LanguageButton(),
        // ThemeButton(),
        IconButton(
          onPressed: () {
            showBottomSheet();
          },
          icon: const Icon(
            Icons.expand_circle_down_outlined,
          ),
        ),
      ],
    );
  }

  void showBottomSheet() {
    showAdaptiveActionSheet(
      title: Text(
        "Chat ${Lang.get("option")}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      context: NavigationService.navigatorKey.currentContext!,
      isDismissible: true,
      barrierColor: Colors.black87,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: Container(
              alignment: Alignment.topLeft,
              child: Text(
                Lang.get("schedule_interview"),
                style: TextStyle(fontWeight: FontWeight.normal),
              )),
          onPressed: (context) {
            openScheduleDialog();
          },
        ),
        BottomSheetAction(
          title: Container(
              alignment: Alignment.topLeft,
              child: Text(Lang.get('cancel'),
                  style: const TextStyle(fontWeight: FontWeight.w100))),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(0.0, 60.0);
}
