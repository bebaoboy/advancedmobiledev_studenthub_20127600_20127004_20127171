import 'package:boilerplate/core/widgets/shared_preference_view.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/swipable_page_route/swipeable_page_route.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = getIt<UserStore>();
    return kIsWeb
        ? AppBar(
            leadingWidth: 30,
            titleSpacing: 0,
            title: Container(
                margin: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                    onDoubleTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => const What(),
                      //   ),
                      // );
                    },
                    onLongPress: () {
                      Navigator.of(context).push(MaterialPageRoute2(
                          child: const SharedPreferenceView()));
                    },
                    child: Text(Lang.get('appbar_title')))),
            actions: [
              // LanguageButton(),
              // ThemeButton(),
              if (userStore.savedUsers.isNotEmpty)
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute2(routeName: Routes.setting));
                  },
                  icon: const Icon(
                    Icons.account_circle,
                  ),
                ),
            ],
          )
        : MorphingAppBar(
            leadingWidth: 30,
            titleSpacing: 0,
            title: Container(
                margin: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                    onDoubleTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => const What(),
                      //   ),
                      // );
                    },
                    onLongPress: () {
                      Navigator.of(context).push(MaterialPageRoute2(
                          child: const SharedPreferenceView()));
                    },
                    child: Text(Lang.get('appbar_title')))),
            actions: [
              // LanguageButton(),
              // ThemeButton(),
              if (userStore.savedUsers.isNotEmpty)
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute2(routeName: Routes.setting));
                  },
                  icon: const Icon(
                    Icons.account_circle,
                  ),
                ),
            ],
          );
  }

  @override
  Size get preferredSize => Size(
      0.0,
      NavigationService.navigatorKey.currentContext != null
          ? MediaQuery.of(NavigationService.navigatorKey.currentContext!)
                      .orientation ==
                  Orientation.landscape
              ? 30
              : 60
          : 60);
}
