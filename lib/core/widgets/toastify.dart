import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Toastify {
  static show(
      BuildContext context, String title, String message, ToastificationType type, Function callback,) {
    Future.delayed(const Duration(milliseconds: 0), () {
      try {
        if (message.isNotEmpty) {
          toastification.show(
            type: type,
            style: ToastificationStyle.fillColored,
            primaryColor: Theme.of(context).colorScheme.primary,
            closeButtonShowType: CloseButtonShowType.onHover,
            context: context,
            description: Text(message),
            title: Text(title),
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
            dismissDirection: DismissDirection.endToStart,
            animationDuration: const Duration(milliseconds: 300),
            callbacks: ToastificationCallbacks(
                onAutoCompleteCompleted: (e) => callback(),
                onDismissed: (e) => callback(),
                onCloseButtonTap: (e) => callback(),
                onTap: (e) => callback()),
          );
        }
      } catch (e) {
        print("cannot show toast");
      }
    });
  }
}
