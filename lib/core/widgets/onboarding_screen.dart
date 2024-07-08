import 'package:boilerplate/core/widgets/onboarding/flutter_onboarding_slider.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: OnBoardingSlider(
        imageVerticalOffset: -100,
        centerBackground: true,
        finishButtonText: 'Register',
        onFinish: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool(Preferences.first_time, true);

          Navigator.of(context).pop();
        },
        skipFunctionOverride: !kReleaseMode
            ? () async {
                try {
                  var datasource = getIt<ProjectDataSource>();

                  datasource.deleteAll();
                } catch (e) {
                  //
                }
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool(Preferences.first_time, true);
              }
            : null,
        finishButtonStyle: FinishButtonStyle(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        skipTextButton: Text(
          'Skip',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          '',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailingFunction: () {
          //Navigator.of(context).pop();
        },
        controllerColor: Theme.of(context).colorScheme.primary,
        totalPage: 3,
        headerBackgroundColor:Theme.of(context).colorScheme.background,
        pageBackgroundColor: Theme.of(context).colorScheme.background,
        background: [
          Image.asset(
            'assets/images/slide_1.png',
            height: MediaQuery.of(context).size.height * 0.8,
          ),
          Image.asset(
            'assets/images/slide_2.png',
            height: MediaQuery.of(context).size.height * 0.8,
          ),
          Image.asset(
            'assets/images/slide_3.png',
            height: MediaQuery.of(context).size.height * 0.8,
          ),
        ],
        speed: 1.8,
        pageBodies: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                
                Text(
                  Lang.get("appbar_title"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "${Lang.get('home_title')}\n\n20127600 - 20127004 - 20127171",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    
                    fontSize: 13.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                
                Text(
                  Lang.get("appbar_title"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  Lang.get('home_intro'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    
                    fontSize: 13.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                
                Text(
                  'Start now!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  Lang.get('home_description'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    
                    fontSize: 13.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSheet extends StatefulWidget {
  const OnboardingSheet({
    super.key,
    required this.onSheetDismissed,
    required this.height,
  });
  final onSheetDismissed;
  final double height;

  @override
  State<OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends State<OnboardingSheet> {
  TextEditingController controller = TextEditingController();
  bool isSuggestionTapped = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SheetContentScaffold is a special Scaffold designed for use in a sheet.
    // It has slots for an app bar and a sticky bottom bar, similar to Scaffold.
    // However, it differs in that its height reduces to fit the 'body' widget.
    final content = Container(
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SheetContentScaffold(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        // The bottom bar sticks to the bottom unless the sheet extent becomes
        // smaller than this threshold extent.
        // With the following configuration, the sheet height will be
        // 500px + (app bar height) + (bottom bar height).
        body: SizedBox(
          height: widget.height,
          child: const OnBoarding(),
        ),
        // appBar: buildAppBar(context),
        // bottomBar: buildBottomBar(),
      ),
    );

    final physics = StretchingSheetPhysics(
      parent: SnappingSheetPhysics(
        snappingBehavior: SnapToNearest(
          snapTo: [
            const Extent.proportional(1),
          ],
        ),
      ),
    );

    return SheetDismissible(
      onDismiss: () {
        widget.onSheetDismissed();
        return true;
      },
      child: DraggableSheet(
        physics: physics,
        keyboardDismissBehavior: const SheetKeyboardDismissBehavior.onDrag(
            isContentScrollAware: true),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: content,
        ),
      ),
    );
  }
}
