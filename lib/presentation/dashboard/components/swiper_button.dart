import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';

Widget swipeRightButton(AppinioSwiperController controller) {
  // We can listen to the controller to get updated as the card shifts position!
  return ListenableBuilder(
    listenable: controller,
    builder: (context, child) {
      final SwiperPosition? position = controller.position;
      final SwiperActivity? activity = controller.swipeActivity;
      // Lets measure the progress of the swipe iff it is a horizontal swipe.
      final double progress = (activity is Swipe || activity == null) &&
              position != null &&
              position.offset.toAxisDirection().isHorizontal
          ? position.progressRelativeToThreshold.clamp(-1, 1)
          : 0;
      // Lets animate the button according to the
      // progress. Here we'll color the button more grey as we swipe away from
      // it.
      final Color color = Color.lerp(
        Colors.green,
        Colors.grey,
        (-1 * progress).clamp(0, 1),
      )!;
      return GestureDetector(
        onTap: () => controller.swipeRight(),
        child: Transform.scale(
          scale: 1 + .1 * progress.clamp(0, 1),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.9),
                  spreadRadius: -10,
                  blurRadius: 20,
                  offset: const Offset(0, 20), // changes position of shadow
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      );
    },
  );
}

Widget customSwipeRightButton(
    AppinioSwiperController controller, Function? sendHire) {
  // We can listen to the controller to get updated as the card shifts position!
  return ListenableBuilder(
    listenable: controller,
    builder: (context, child) {
      final SwiperPosition? position = controller.position;
      final SwiperActivity? activity = controller.swipeActivity;
      // Lets measure the progress of the swipe iff it is a horizontal swipe.
      final double progress = (activity is Swipe || activity == null) &&
              position != null &&
              position.offset.toAxisDirection().isHorizontal
          ? position.progressRelativeToThreshold.clamp(-1, 1)
          : 0;
      // Lets animate the button according to the
      // progress. Here we'll color the button more grey as we swipe away from
      // it.
      final Color color = Color.lerp(
        Colors.green,
        Colors.grey,
        (-1 * progress).clamp(0, 1),
      )!;
      return Transform.scale(
        scale: 1 + .1 * progress.clamp(0, 1),
        child: Container(
            alignment: Alignment.center,
            child: MaterialButton(
              onPressed: () {
                sendHire!() ?? () {};
                controller.swipeRight();
              },
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              child: const Text('Send hire'),
            )),
      );
    },
  );
}

//swipe card to the left side
Widget swipeLeftButton(AppinioSwiperController controller) {
  return ListenableBuilder(
    listenable: controller,
    builder: (context, child) {
      final SwiperPosition? position = controller.position;
      final SwiperActivity? activity = controller.swipeActivity;
      final double horizontalProgress =
          (activity is Swipe || activity == null) &&
                  position != null &&
                  position.offset.toAxisDirection().isHorizontal
              ? -1 * position.progressRelativeToThreshold.clamp(-1, 1)
              : 0;
      final Color color = Color.lerp(
        const Color(0xFFFF3868),
        Colors.grey,
        (-1 * horizontalProgress).clamp(0, 1),
      )!;
      return GestureDetector(
        onTap: () => controller.swipeLeft(),
        child: Transform.scale(
          // Increase the button size as we swipe towards it.
          scale: 1 + .1 * horizontalProgress.clamp(0, 1),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.9),
                  spreadRadius: -10,
                  blurRadius: 20,
                  offset: const Offset(0, 20), // changes position of shadow
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ),
      );
    },
  );
}

Widget customSwipeLeftButton(
    AppinioSwiperController controller, Function? sendMessage) {
  return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final SwiperPosition? position = controller.position;
        final SwiperActivity? activity = controller.swipeActivity;
        final double horizontalProgress =
            (activity is Swipe || activity == null) &&
                    position != null &&
                    position.offset.toAxisDirection().isHorizontal
                ? -1 * position.progressRelativeToThreshold.clamp(-1, 1)
                : 0;
        final Color color = Color.lerp(
          const Color(0xFFFF3868),
          Colors.grey,
          (-1 * horizontalProgress).clamp(0, 1),
        )!;
        return Container(
            alignment: Alignment.center,
            child: MaterialButton(
              onPressed: sendMessage!() ?? () {},
              textColor: Colors.black,
              color: Colors.grey.shade300,
              child: const Text('Send Message'),
            ));
      });
}

//unswipe card
Widget unswipeButton(AppinioSwiperController controller) {
  return GestureDetector(
    onTap: () => controller.unswipe(),
    child: Container(
      height: 60,
      width: 60,
      alignment: Alignment.center,
      child: const Icon(
        Icons.rotate_left_rounded,
        color: Colors.grey,
      ),
    ),
  );
}
