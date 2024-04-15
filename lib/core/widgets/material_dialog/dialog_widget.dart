import 'package:animations/animations.dart';
import 'package:boilerplate/core/widgets/material_dialog/dialog.dart';
import 'package:boilerplate/core/widgets/material_dialog/dialog_buttons.dart';
import 'package:boilerplate/core/widgets/material_dialog/navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedDialog {
  ///[titleStyle] can be used to change the dialog title style
  static const TextStyle titleStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  ///[bcgColor] background default value
  static const Color bcgColor = Color(0xfffefefe);

  ///[holder] holder for the custom view
  static const Widget holder = SizedBox(
    height: 0,
  );

  /// [dialogShape] dialog outer shape
  static const ShapeBorder dialogShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)));

  /// [BottomSheetShape] bottom dialog outer shape
  static const ShapeBorder BottomSheetShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16)));

  static const CustomViewPosition customViewPosition =
      CustomViewPosition.BEFORE_TITLE;

  /// Displays normal Material dialog above the current contents of the app
  ///
  /// Wanna navigate INSIDE the dialog? Use
  /// ```dart
  /// DialogNavigator.of(context).push(
  ///       Dialogs.getMaterialDialog(...)
  /// );
  /// ```
  ///
  /// and pop out:
  /// ```dart
  /// DialogNavigator.of(context).pop();
  /// ```
  ///
  /// for closing the dialog:
  /// ```dart
  /// Navigator.of(context).pop();
  /// ```
  /// [context] your parent widget context
  ///
  /// [color] dialog background color
  ///
  /// [title] your dialog title
  ///
  /// [positiveText] your positive button text
  ///
  /// [negativeText] your negative button text
  ///
  /// [actions] Widgets to display a row of buttons after the [msg] widget.
  ///
  /// [onClose] used to listen to dialog close events.
  ///
  /// [onPositiveClick] used to listen to dialog positive button.
  ///
  /// [onNegativeClick] used to listen to dialog negative button.
  ///
  /// [titleStyle] your dialog title style
  ///
  /// [titleAlign] your dialog title alignment
  ///
  /// [contentText] your dialog description message
  ///
  /// [contentTextStyle] your dialog description style
  ///
  /// [contentTextAlign] your dialog description alignment
  ///
  /// [customView] a custom view shown in the dialog at [customViewPosition] and by default before the title

  static void showAnimatedDialog(
    BuildContext context, {
    String? title,
    String? contentText,
    String? positiveText,
    String? negativeText,
    String? singleActionText,
    IconData? positiveIcon,
    IconData? negativeIcon,
    bool? singleAction,
    Color? singleButtonColor,
    // List<Widget>? actions,
    Widget customView = holder,
    CustomViewPosition customViewPosition = CustomViewPosition.BEFORE_TITLE,
    LottieBuilder? lottieBuilder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    ShapeBorder dialogShape = dialogShape,
    TextStyle titleStyle = titleStyle,
    TextStyle? contentTextStyle,
    TextAlign? titleAlign,
    TextAlign? contentTextAlign = TextAlign.center,
    Color color = bcgColor,
    double? dialogWidth,
    Function(dynamic)? onClose,
    Function(BuildContext)? onPositiveClick,
    Function(BuildContext)? onNegativeClick,
    EdgeInsetsGeometry edgePadding = const EdgeInsets.all(12),
    Duration alignmentDuration = const Duration(milliseconds: 500),
    Curve alignmentCurve = const Cubic(0.2, 0, 0, 1),
    Duration sizeDuration = const Duration(milliseconds: 600),
    Curve sizeCurve = const Cubic(0.2, 0, 0, 1),
    Widget Function(Widget, Animation<double>)? transitionBuilder,
    Duration transitionDuration = const Duration(milliseconds: 600),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
    Curve transitionCurve = Curves.easeInOutCubicEmphasized,
    Curve reverseTransitionCurve = Curves.easeInOutCubicEmphasized,
    Decoration? defaultDecoration,
  }) {
    showModal(
        context: context,
        builder: (context) => FluidDialog(
              edgePadding: edgePadding,
              alignmentDuration: alignmentDuration,
              sizeDuration: sizeDuration,
              sizeCurve: sizeCurve,
              transitionBuilder: transitionBuilder,
              transitionDuration: transitionDuration,
              transitionCurve: transitionCurve,
              reverseTransitionCurve: reverseTransitionCurve,
              defaultDecoration: defaultDecoration,
              // Set the first page of the dialog.
              rootPage: FluidDialogPage(
                builder: (context) => DialogWidget(
                    msg: contentText,
                    title: title,
                    color: color,
                    dialogWidth: kIsWeb ? 0.3 : null,
                    animationBuilder: lottieBuilder,
                    customView: customView,
                    customViewPosition: customViewPosition,
                    titleStyle: titleStyle,
                    msgStyle: contentTextStyle,
                    msgAlign: contentTextAlign,
                    titleAlign: titleAlign,
                    actions: [
                      if (negativeText != null)
                        IconsButton(
                          shape: btnShape.copyWith(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                          onPressed: () {
                            if (onNegativeClick != null) {
                              onNegativeClick(context);
                            }
                          },
                          text: negativeText,
                          iconData: negativeIcon ?? Icons.cancel_outlined,
                          textStyle: const TextStyle(color: Colors.grey),
                          iconColor: Colors.grey,
                        ),
                      if (positiveText != null ||
                          ((singleAction ?? false) && singleActionText != null))
                        IconsButton(
                          text: positiveText ?? singleActionText ?? "<null>",
                          onPressed: () {
                            if (onPositiveClick != null) {
                              onPositiveClick(context);
                            }
                          },
                          iconData: positiveIcon ?? Icons.done_all,
                          color: Theme.of(context).colorScheme.primary,
                          textStyle: const TextStyle(color: Colors.white),
                          iconColor: Colors.white,
                        )
                    ]),
                // onPop: (value) => print("returned value is '$value'"),
              ),
            )).then((value) {
      if (onClose != null) onClose(value);
    });
  }

  /// Displays normal Material dialog above the current contents of the app
  /// [context] your parent widget context
  /// [color] dialog background color

  /// [title] your dialog title
  /// [titleStyle] your dialog title style
  /// [titleAlign] your dialog title alignment
  /// [msg] your dialog description message
  /// [msgStyle] your dialog description style
  /// [msgAlign] your dialog description alignment
  /// [customView] a custom view shown in the dialog at [customViewPosition] and by default before the title

  /// [actions] Widgets to display a row of buttons after the [msg] widget.
  /// [onClose] used to listen to dialog close events.

  static Future<void> _materialDialog({
    required BuildContext context,
    Function(dynamic value)? onClose,
    String? title,
    String? msg,
    List<Widget>? actions,
    Widget customView = holder,
    CustomViewPosition customViewPosition = CustomViewPosition.BEFORE_TITLE,
    LottieBuilder? lottieBuilder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    ShapeBorder dialogShape = dialogShape,
    TextStyle titleStyle = titleStyle,
    TextStyle? msgStyle,
    TextAlign? titleAlign,
    TextAlign? msgAlign,
    Color color = bcgColor,
    double? dialogWidth,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (context) {
        return Dialog(
          backgroundColor: color,
          shape: dialogShape,
          child: DialogWidget(
            title: title,
            dialogWidth: dialogWidth,
            msg: msg,
            actions: actions,
            animationBuilder: lottieBuilder,
            customView: customView,
            customViewPosition: customViewPosition,
            titleStyle: titleStyle,
            msgStyle: msgStyle,
            titleAlign: titleAlign,
            msgAlign: msgAlign,
            color: color,
          ),
        );
      },
    ).then((value) => onClose?.call(value));
  }

  static FluidDialogPage getMaterialDialog({
    String? title,
    String? msg,
    List<Widget>? actions,
    Widget customView = holder,
    CustomViewPosition customViewPosition = CustomViewPosition.BEFORE_TITLE,
    LottieBuilder? lottieBuilder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    ShapeBorder dialogShape = dialogShape,
    TextStyle titleStyle = titleStyle,
    TextStyle? msgStyle,
    TextAlign? titleAlign,
    TextAlign? msgAlign,
    Color color = bcgColor,
    double? dialogWidth,
  }) {
    return FluidDialogPage(
        builder: (context) => DialogWidget(
              title: title,
              dialogWidth: dialogWidth,
              msg: msg,
              actions: actions,
              animationBuilder: lottieBuilder,
              customView: customView,
              customViewPosition: customViewPosition,
              titleStyle: titleStyle,
              msgStyle: msgStyle,
              titleAlign: titleAlign,
              msgAlign: msgAlign,
              color: color,
            ));
  }

  /// Displays bottom sheet Material dialog above the current contents of the app
  static void showBottomMaterialDialog({
    required BuildContext context,
    Function(dynamic value)? onClose,
    String? title,
    String? msg,
    List<Widget>? actions,
    Widget customView = holder,
    CustomViewPosition customViewPosition = CustomViewPosition.BEFORE_TITLE,
    LottieBuilder? lottieBuilder,
    bool barrierDismissible = true,
    ShapeBorder dialogShape = BottomSheetShape,
    TextStyle titleStyle = titleStyle,
    TextStyle? msgStyle,
    Color color = bcgColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
  }) {
    showModalBottomSheet(
      context: context,
      shape: dialogShape,
      backgroundColor: color,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      routeSettings: routeSettings,
      transitionAnimationController: transitionAnimationController,
      builder: (context) => DialogWidget(
        title: title,
        msg: msg,
        actions: actions,
        animationBuilder: lottieBuilder,
        customView: customView,
        customViewPosition: customViewPosition,
        titleStyle: titleStyle,
        msgStyle: msgStyle,
        color: color,
      ),
    ).then((value) => onClose?.call(value));
  }

  static void showBottomAnimatedDialog(
    BuildContext context, {
    String? title,
    String? contentText,
    String? positiveText,
    String? negativeText,
    String? singleActionText,
    IconData? positiveIcon,
    IconData? negativeIcon,
    bool? singleAction,
    Color? singleButtonColor,
    // List<Widget>? actions,
    Widget customView = holder,
    CustomViewPosition customViewPosition = CustomViewPosition.BEFORE_TITLE,
    LottieBuilder? lottieBuilder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    ShapeBorder dialogShape = dialogShape,
    TextStyle titleStyle = titleStyle,
    TextStyle? contentTextStyle,
    TextAlign? titleAlign,
    TextAlign? contentTextAlign = TextAlign.center,
    Color color = bcgColor,
    double? dialogWidth,
    Function(dynamic)? onClose,
    Function(BuildContext)? onPositiveClick,
    Function(BuildContext)? onNegativeClick,
    EdgeInsetsGeometry edgePadding = const EdgeInsets.all(12),
    Duration alignmentDuration = const Duration(milliseconds: 500),
    Curve alignmentCurve = const Cubic(0.2, 0, 0, 1),
    Duration sizeDuration = const Duration(milliseconds: 600),
    Curve sizeCurve = const Cubic(0.2, 0, 0, 1),
    Widget Function(Widget, Animation<double>)? transitionBuilder,
    Duration transitionDuration = const Duration(milliseconds: 600),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
    Curve transitionCurve = Curves.easeInOutCubicEmphasized,
    Curve reverseTransitionCurve = Curves.easeInOutCubicEmphasized,
    Decoration? defaultDecoration,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    AnimationController? transitionAnimationController,
  }) {
    showModalBottomSheet(
        context: context,
        shape: dialogShape,
        backgroundColor: color,
        isScrollControlled: isScrollControlled,
        useRootNavigator: useRootNavigator,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        routeSettings: routeSettings,
        transitionAnimationController: transitionAnimationController,
        builder: (context) => FluidDialog(
              edgePadding: edgePadding,
              alignmentDuration: alignmentDuration,
              sizeDuration: sizeDuration,
              sizeCurve: sizeCurve,
              transitionBuilder: transitionBuilder,
              transitionDuration: transitionDuration,
              transitionCurve: transitionCurve,
              reverseTransitionCurve: reverseTransitionCurve,
              defaultDecoration: defaultDecoration,
              // Set the first page of the dialog.
              rootPage: FluidDialogPage(
                builder: (context) => DialogWidget(
                    msg: contentText,
                    title: title,
                    color: color,
                    dialogWidth: kIsWeb ? 0.3 : null,
                    animationBuilder: lottieBuilder,
                    customView: customView,
                    customViewPosition: customViewPosition,
                    titleStyle: titleStyle,
                    msgStyle: contentTextStyle,
                    msgAlign: contentTextAlign,
                    titleAlign: titleAlign,
                    actions: [
                      if (negativeText != null)
                        IconsButton(
                          shape: btnShape.copyWith(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                          onPressed: () {
                            if (onNegativeClick != null) {
                              onNegativeClick(context);
                            }
                          },
                          text: negativeText,
                          iconData: negativeIcon ?? Icons.cancel_outlined,
                          textStyle: const TextStyle(color: Colors.grey),
                          iconColor: Colors.grey,
                        ),
                      if (positiveText != null ||
                          ((singleAction ?? false) && singleActionText != null))
                        IconsButton(
                          text: positiveText ?? singleActionText ?? "<null>",
                          onPressed: () {
                            if (onPositiveClick != null) {
                              onPositiveClick(context);
                            }
                          },
                          iconData: positiveIcon ?? Icons.done_all,
                          color: Theme.of(context).colorScheme.primary,
                          textStyle: const TextStyle(color: Colors.white),
                          iconColor: Colors.white,
                        )
                    ]),
                // onPop: (value) => print("returned value is '$value'"),
              ),
            )).then((value) {
      if (onClose != null) onClose(value);
    });
  }
}

enum CustomViewPosition {
  BEFORE_ANIMATION,
  BEFORE_TITLE,
  BEFORE_MESSAGE,
  BEFORE_ACTION,
  AFTER_ACTION,
}

/// Displays Material dialog above the current contents of the app

class DialogWidget extends StatelessWidget {
  const DialogWidget({
    super.key,
    this.title,
    this.msg,
    this.actions,
    this.animationBuilder,
    this.customView = const SizedBox(),
    this.customViewPosition = CustomViewPosition.BEFORE_TITLE,
    this.titleStyle,
    this.msgStyle,
    this.titleAlign,
    this.msgAlign,
    this.dialogWidth,
    this.color,
  });

  /// [actions]Widgets to display a row of buttons after the [msg] widget.
  final List<Widget>? actions;

  /// [customView] a widget to display a custom widget instead of the animation view.
  final Widget customView;

  final CustomViewPosition customViewPosition;

  /// [title] your dialog title
  final String? title;

  /// [msg] your dialog description message
  final String? msg;

  /// [animationBuilder] lottie animations builder
  final LottieBuilder? animationBuilder;

  /// [titleStyle] dialog title text style
  final TextStyle? titleStyle;

  /// [animation] lottie animations path
  final TextStyle? msgStyle;

  /// [titleAlign] dialog title text alignment
  final TextAlign? titleAlign;

  /// [textAlign] dialog description text alignment
  final TextAlign? msgAlign;

  /// [color] dialog's backgorund color
  final Color? color;

  /// [dialogWidth] dialog's width compared to the screen width
  final double? dialogWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dialogWidth == null
          ? null
          : MediaQuery.of(context).size.width * dialogWidth!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          customViewPosition == CustomViewPosition.BEFORE_ANIMATION
              ? customView
              : const SizedBox(),
          if (animationBuilder != null)
            Container(
              padding: const EdgeInsets.only(top: 20),
              height: 200,
              width: double.infinity,
              child: animationBuilder,
            ),
          customViewPosition == CustomViewPosition.BEFORE_TITLE
              ? customView
              : const SizedBox(),
          title != null
              ? Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 20, top: 24.0),
                  child: Text(
                    title!,
                    style: titleStyle,
                    textAlign: titleAlign,
                  ),
                )
              : const SizedBox(
                  height: 4,
                ),
          customViewPosition == CustomViewPosition.BEFORE_MESSAGE
              ? customView
              : const SizedBox(),
          msg != null
              ? Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 16.0, bottom: 20),
                  child: Text(
                    msg!,
                    style: msgStyle,
                    textAlign: msgAlign,
                  ),
                )
              : const SizedBox(
                  height: 0,
                ),
          customViewPosition == CustomViewPosition.BEFORE_ACTION
              ? customView
              : const SizedBox(),
          actions?.isNotEmpty == true
              ? buttons(context, stretch: actions!.length > 1)
              : const SizedBox(
                  height: 20,
                ),
          customViewPosition == CustomViewPosition.AFTER_ACTION
              ? customView
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget buttons(BuildContext context, {bool stretch = true}) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 20, left: 20, top: 16.0, bottom: 20.0),
      child: stretch
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(actions!.length, (index) {
                // final TextDirection direction = Directionality.of(context);
                // double padding = index != 0 ? 8 : 0;
                double rightPadding = 10;
                double leftPadding = 10;
                // direction == TextDirection.rtl
                //     ? rightPadding = padding
                //     : leftPadding = padding;
                return Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: leftPadding, right: rightPadding),
                    child: actions![index],
                  ),
                );
              }),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: actions![0],
                ),
              ],
            ),
    );
  }
}
