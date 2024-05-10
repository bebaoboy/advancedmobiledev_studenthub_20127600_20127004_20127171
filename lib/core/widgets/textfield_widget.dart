import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
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
  State<TextFieldWidget> createState() => _TextFieldWidgetState();

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

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late bool obscureText;
  bool tapInside = true;
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
            // tapInside = false;
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
          errorStyle: widget.inputDecoration?.errorStyle ??
              const TextStyle(
                fontSize: 12.0,
              ),

          counterText: '',
          border: widget.inputDecoration?.border,
          disabledBorder: widget.inputDecoration?.disabledBorder,
          enabledBorder: widget.inputDecoration?.enabledBorder,
          focusedBorder: (widget.inputDecoration?.focusedBorder)?.copyWith(
              borderSide: BorderSide(color: Theme.of(context).focusColor)),
          errorBorder: (widget.inputDecoration?.errorBorder),
          focusedErrorBorder: (widget.inputDecoration?.focusedErrorBorder)
              ?.copyWith(
                  borderSide: BorderSide(color: Theme.of(context).focusColor)),
          // border: const OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.black)
          // ),
          icon: widget.inputDecoration?.icon ??
              (widget.isIcon
                  ? Container(
                      margin: widget.iconMargin,
                      child: Icon(widget.icon, color: widget.iconColor))
                  : null),

          suffixIcon: widget.isObscure && tapInside
              ? IconButton(
                  icon: obscureText ? const Icon(Icons.remove_red_eye) : const Icon(Icons.remove_red_eye_outlined),
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
