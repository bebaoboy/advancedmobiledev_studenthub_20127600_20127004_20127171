import 'package:flutter/material.dart';

class BorderTextField extends StatefulWidget {
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
  State<BorderTextField> createState() => _BorderTextFieldState();

  const BorderTextField(
      {super.key,
      this.icon,
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

class _BorderTextFieldState extends State<BorderTextField> {
  late bool obscureText;
  bool tapInside = false;
  @override
  void initState() {
    super.initState();
    obscureText = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: TextFormField(
        onTap: () {
          setState(() {
            tapInside = true;
          });
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        enabled: widget.enabled,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        canRequestFocus: widget.canRequestFocus ?? true,
        initialValue: widget.initialValue,
        readOnly: widget.readOnly ?? false,
        controller: widget.textController,
        focusNode: widget.focusNode,
        onFieldSubmitted: widget.onFieldSubmitted,
        onChanged: widget.onChanged,
        autofocus: widget.autoFocus,
        textInputAction: widget.inputAction,
        obscureText: obscureText,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            tapInside = false;
          });
        },
        keyboardType: widget.inputType,
        style: Theme.of(context).textTheme.bodyLarge == null
            ? TextStyle(
                    fontSize: widget.fontSize, overflow: TextOverflow.ellipsis)
                .merge(widget.style)
            : Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(
                    fontSize: widget.fontSize, overflow: TextOverflow.ellipsis)
                .merge(widget.style),
        magnifierConfiguration: TextMagnifierConfiguration.disabled,
        decoration: InputDecoration(
          floatingLabelBehavior: widget.floatingLabelBehavior ??
              (widget.initialValue == null ||
                      (widget.initialValue != null &&
                          widget.initialValue!.isEmpty)
                  ? FloatingLabelBehavior.never
                  : null),
          label: widget.label,
          hintText: widget.hint,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: widget.hintColor)
              .merge(widget.hintStyle),
          errorText: widget.errorText,
          errorStyle: widget.inputDecoration != null
              ? widget.inputDecoration!.errorStyle ??
                  const TextStyle(
                    fontSize: 12.0,
                  )
              : const TextStyle(
                  fontSize: 12.0,
                ),
          counterText: '',
          enabledBorder:
              const OutlineInputBorder(borderSide: BorderSide(width: 1)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Theme.of(context).focusColor,
          )),
          errorBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).focusColor, width: 2)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).focusColor, width: 2)),
          border: const OutlineInputBorder(borderSide: BorderSide(width: 3)),
          prefixIcon: widget.inputDecoration?.icon ??
              (widget.isIcon
                  ? Container(
                      margin: widget.iconMargin,
                      child: Icon(widget.icon, color: widget.iconColor))
                  : null),
          suffixIcon: widget.isObscure && tapInside
              ? IconButton(
                  icon: const Icon(Icons.remove_red_eye),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
