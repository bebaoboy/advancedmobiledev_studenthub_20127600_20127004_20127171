import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final IconData? icon;
  final String? hint;
  final String? errorText;
  final bool isObscure;
  final bool isIcon;
  final TextInputType? inputType;
  final TextEditingController? textController;
  final EdgeInsets padding;
  final Color hintColor;
  final Color iconColor;
  final FocusNode? focusNode;
  final ValueChanged? onFieldSubmitted;
  final ValueChanged? onChanged;
  final bool autoFocus;
  final TextInputAction? inputAction;
  final InputDecoration? inputDecoration;
  final bool? readOnly;
  final String? initialValue;
  final double? fontSize;
  final bool? canRequestFocus;
  final EdgeInsetsGeometry? iconMargin;
  final bool? enableInteractiveSelection;
  final bool? enabled;
  final Widget? label;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final InputBorder? border;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
        onTap: onTap,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        enabled: enabled,
        enableInteractiveSelection: enableInteractiveSelection,
        canRequestFocus: canRequestFocus ?? true,
        initialValue: initialValue,
        readOnly: readOnly ?? false,
        controller: textController,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        autofocus: autoFocus,
        textInputAction: inputAction,
        obscureText: isObscure,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: inputType,
        style: Theme.of(context).textTheme.bodyText1 == null
            ? TextStyle(fontSize: fontSize, overflow: TextOverflow.ellipsis)
                .merge(style)
            : Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontSize: fontSize, overflow: TextOverflow.ellipsis)
                .merge(style),
        magnifierConfiguration: TextMagnifierConfiguration.disabled,
        decoration: (inputDecoration ?? const InputDecoration()).copyWith(
          floatingLabelBehavior: initialValue == null ||
                  (initialValue != null && initialValue!.isEmpty)
              ? FloatingLabelBehavior.always
              : floatingLabelBehavior,
          label: label,
          hintText: hint,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: hintColor)
              .merge(hintStyle),
          errorText: errorText,
          errorStyle: inputDecoration != null
              ? inputDecoration!.errorStyle
              : const TextStyle(
                  fontSize: 12.0,
                ),
          counterText: '',
          border: inputDecoration != null ? inputDecoration!.border : border,
          // border: const OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.black)
          // ),
          icon: inputDecoration != null
              ? inputDecoration!.icon
              : isIcon
                  ? Container(
                      margin: iconMargin, child: Icon(icon, color: iconColor))
                  : null,
        ),
      ),
    );
  }

  const TextFieldWidget(
      {super.key,
      required this.icon,
      required this.errorText,
      required this.textController,
      this.inputType,
      this.hint,
      this.isObscure = false,
      this.isIcon = true,
      this.padding = const EdgeInsets.all(0),
      this.hintColor = Colors.grey,
      this.iconColor = Colors.grey,
      this.focusNode,
      this.onFieldSubmitted,
      this.onChanged,
      this.autoFocus = false,
      this.inputAction,
      this.inputDecoration,
      this.readOnly,
      this.initialValue,
      this.fontSize,
      this.canRequestFocus,
      this.iconMargin,
      this.enableInteractiveSelection,
      this.enabled,
      this.label,
      this.maxLength,
      this.minLines = 1,
      this.maxLines = 1,
      this.style,
      this.floatingLabelBehavior,
      this.hintStyle,
      this.border,
      this.textAlign = TextAlign.start,
      this.textAlignVertical,
      this.onTap});
}
