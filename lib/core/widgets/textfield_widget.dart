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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
        enabled: enabled,
        enableInteractiveSelection: enableInteractiveSelection,
        canRequestFocus: canRequestFocus ?? true,
        initialValue: initialValue ?? null,
        readOnly: readOnly ?? false,
        controller: textController,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        autofocus: autoFocus,
        textInputAction: inputAction,
        obscureText: this.isObscure,
        maxLength: 250,
        keyboardType: this.inputType,
        style: Theme.of(context).textTheme.bodyText1 == null
            ? TextStyle(fontSize: fontSize, overflow: TextOverflow.ellipsis)
            : Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontSize: fontSize, overflow: TextOverflow.ellipsis),
        magnifierConfiguration: TextMagnifierConfiguration.disabled,
        decoration: (inputDecoration ?? const InputDecoration()).copyWith(
          label: label,
          hintText: this.hint,
          hintStyle:
              Theme.of(context).textTheme.bodyText1!.copyWith(color: hintColor),
          errorText: errorText,
          errorStyle: TextStyle(
            fontSize: 12.0,
          ),
          counterText: '',
          // border: const OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.black)
          // ),
          icon: Container(
              margin: iconMargin,
              child: this.isIcon ? Icon(this.icon, color: iconColor) : null),
        ),
      ),
    );
  }

  const TextFieldWidget(
      {Key? key,
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
      this.label})
      : super(key: key);
}
