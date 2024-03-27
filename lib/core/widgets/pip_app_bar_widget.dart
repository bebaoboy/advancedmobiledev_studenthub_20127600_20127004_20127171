import 'package:boilerplate/core/widgets/pip/picture_in_picture.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PiPAppBar extends StatelessWidget implements PreferredSizeWidget {
  PiPAppBar({super.key, this.radius = 30});
  double? radius = 30;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius!),
              topRight: Radius.circular(radius!)),
        ),
        height: 30,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(
                  "PiP",
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.none),
                ),
              ),
            ),
            IconButton(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.zero,
              iconSize: 16,
              onPressed: () {
                PictureInPicture.stopPiP();
              },
              icon: const Icon(
                Icons.close,
              ),
            ),
          ],
        ));
  }

  @override
  Size get preferredSize => const Size(0.0, 30.0);
}
