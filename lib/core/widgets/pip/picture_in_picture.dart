import 'package:boilerplate/core/widgets/animated_theme_app.dart';
import 'package:boilerplate/core/widgets/pip/pip_params.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:flutter/material.dart';

class PictureInPicture {
  static bool isActive = false;
  static GlobalKey<PiPMaterialAppState> pipKey = GlobalKey();
  static void stopPiP() {
    Navigator.of(NavigationService.navigatorKey.currentContext!)
        .push(MaterialPageRoute2(child: pipKey.currentState?.changeOverlay()));
    isActive = false;
  }

  static void startPiP({required Widget pipWidget}) {
    pipKey.currentState?.changeOverlay(overlay: pipWidget);
    isActive = true;
  }

  static void updatePiPParams({required PiPParams pipParams}) {
    pipKey.currentState?.updatePiPParams(pipParams: pipParams);
  }
}
