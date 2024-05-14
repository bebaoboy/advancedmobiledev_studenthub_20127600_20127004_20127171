import 'package:boilerplate/presentation/dashboard/chat/models/chat_enum.dart';
import 'package:boilerplate/presentation/dashboard/chat/models/util.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_link_previewer.dart'
    show regexEmail, regexLink;
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:url_launcher/url_launcher.dart';

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget.
  const Input({
    super.key,
    this.isAttachmentUploading,
    this.onFirstIconPressed,
    this.onAttachmentPressed,
    required this.onSendPressed,
    this.options = const InputOptions(),
    required this.scrollController,
    required this.safeAreaInsets,
  });

  final EdgeInsets safeAreaInsets;

  final AutoScrollController scrollController;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// See [AttachmentButton.onPressed].
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onFirstIconPressed;

  /// Will be called on [SendButton] tap. Has [PartialText] which can
  /// be transformed to [AbstractTextMessage] and added to the messages list.
  final void Function(PartialText) onSendPressed;

  /// Customisation options for the [Input].
  final InputOptions options;

  @override
  State<Input> createState() => _InputState();
}

/// [Input] widget state.
class _InputState extends State<Input> {
  late final _inputFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.physicalKeysPressed.any(
            (el) => <PhysicalKeyboardKey>{
              PhysicalKeyboardKey.shiftLeft,
              PhysicalKeyboardKey.shiftRight,
            }.contains(el),
          )) {
        if (kIsWeb && _textController.value.isComposingRangeValid) {
          return KeyEventResult.ignored;
        }
        if (event is KeyDownEvent) {
          _handleSendPressed();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );
  double visibility = 0;
  bool _sendButtonVisible = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final buttonPadding = Chat.theme.inputPadding.copyWith(left: 16, right: 16);
    visibility = buttonPadding.bottom + buttonPadding.top + 24;

    _textController =
        widget.options.textEditingController ?? InputTextFieldController();
    widget.scrollController.addListener(
      () {
        // final buttonPadding =
        //     Chat.theme.inputPadding.copyWith(left: 16, right: 16);
        if (widget.scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (visibility != 0) {
            // if (mounted) {
            //   setState(() {
            //     visibility = 0;
            //   });
            // }
          }
        }
        if (widget.scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          // if (visibility == 0) {
          //   setState(() {
          //     visibility = buttonPadding.bottom + buttonPadding.top + 24;
          //   });
          // }
        }
      },
    );
    _handleSendButtonVisibilityModeChange();
  }

  void _handleSendButtonVisibilityModeChange() {
    _textController.removeListener(_handleTextControllerChange);
    if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.hidden) {
      _sendButtonVisible = false;
    } else if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
  }

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      final partialText = PartialText(text: trimmedText);
      widget.onSendPressed(partialText);

      if (widget.options.inputClearMode == InputClearMode.always) {
        _textController.clear();
      }
    }
  }

  void _handleTextControllerChange() {
    if (_textController.value.isComposingRangeValid) {
      return;
    }
    if (_textController.text.trim() != '') {
      setState(() {
        _sendButtonVisible = _textController.text.trim() != '';
      });
    }
  }

  Widget _inputBuilder() {
    final buttonPadding = Chat.theme.inputPadding.copyWith(left: 16, right: 16);
    // print(buttonPadding);

    final textPadding = Chat.theme.inputPadding.copyWith(left: 0, right: 0).add(
          EdgeInsets.fromLTRB(
            widget.onAttachmentPressed != null ? 0 : 24,
            0,
            _sendButtonVisible ? 0 : 24,
            0,
          ),
        );

    return Focus(
      autofocus: !widget.options.autofocus,
      child: Padding(
        padding: Chat.theme.inputMargin,
        child: Material(
          borderRadius: Chat.theme.inputBorderRadius,
          color: Theme.of(context).colorScheme.primary,
          surfaceTintColor: Chat.theme.inputSurfaceTintColor,
          elevation: Chat.theme.inputElevation,
          child: Container(
            decoration: Chat.theme.inputContainerDecoration,
            padding: widget.safeAreaInsets,
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                CalendarButton(
                  onPressed: widget.onFirstIconPressed,
                  padding: buttonPadding,
                ),
                if (widget.onAttachmentPressed != null)
                  AttachmentButton(
                    isLoading: widget.isAttachmentUploading ?? false,
                    onPressed: widget.onAttachmentPressed,
                    padding: buttonPadding,
                  ),
                Expanded(
                  child: Padding(
                    padding: isMobile &&
                            MediaQuery.of(context).orientation ==
                                Orientation.landscape
                        ? EdgeInsets.zero
                        : textPadding,
                    child: TextField(
                      enabled: widget.options.enabled,
                      autocorrect: widget.options.autocorrect,
                      autofocus: widget.options.autofocus,
                      enableSuggestions: widget.options.enableSuggestions,
                      controller: _textController,
                      cursorColor: Chat.theme.inputTextCursorColor,
                      decoration: Chat.theme.inputTextDecoration.copyWith(
                        hintStyle: Chat.theme.inputTextStyle.copyWith(
                          color: Chat.theme.inputTextColor.withOpacity(0.5),
                        ),
                        hintText: Chat.l10n.inputPlaceholder,
                      ),
                      focusNode: _inputFocusNode,
                      keyboardType: widget.options.keyboardType,
                      maxLines: isMobile &&
                              MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                          ? 1
                          : 5,
                      minLines: 1,
                      onChanged: widget.options.onTextChanged,
                      onTap: widget.options.onTextFieldTap,
                      style: Chat.theme.inputTextStyle.copyWith(
                        color: Chat.theme.inputTextColor,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: buttonPadding.bottom + buttonPadding.top + 24,
                  ),
                  child: Visibility(
                    visible: _sendButtonVisible,
                    child: SendButton(
                      onPressed: _handleSendPressed,
                      padding: buttonPadding,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.sendButtonVisibilityMode !=
        oldWidget.options.sendButtonVisibilityMode) {
      _handleSendButtonVisibilityModeChange();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _inputFocusNode.requestFocus(),
        child: _inputBuilder(),
      );
}

@immutable
class InputOptions {
  const InputOptions({
    this.inputClearMode = InputClearMode.always,
    this.keyboardType = TextInputType.multiline,
    this.onTextChanged,
    this.onTextFieldTap,
    this.sendButtonVisibilityMode = SendButtonVisibilityMode.editing,
    this.textEditingController,
    this.autocorrect = true,
    this.autofocus = false,
    this.enableSuggestions = true,
    this.enabled = true,
  });

  /// Controls the [Input] clear behavior. Defaults to [InputClearMode.always].
  final InputClearMode inputClearMode;

  /// Controls the [Input] keyboard type. Defaults to [TextInputType.multiline].
  final TextInputType keyboardType;

  /// Will be called whenever the text inside [TextField] changes.
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap.
  final VoidCallback? onTextFieldTap;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  /// Custom [TextEditingController]. If not provided, defaults to the
  /// [InputTextFieldController], which extends [TextEditingController] and has
  /// additional fatures like markdown support. If you want to keep additional
  /// features but still need some methods from the default [TextEditingController],
  /// you can create your own [InputTextFieldController] (imported from this lib)
  /// and pass it here.
  final TextEditingController? textEditingController;

  /// Controls the [TextInput] autocorrect behavior. Defaults to [true].
  final bool autocorrect;

  /// Whether [TextInput] should have focus. Defaults to [false].
  final bool autofocus;

  /// Controls the [TextInput] enableSuggestions behavior. Defaults to [true].
  final bool enableSuggestions;

  /// Controls the [TextInput] enabled behavior. Defaults to [true].
  final bool enabled;
}

MatchText mailToMatcher({
  final TextStyle? style,
  required final Function onTap,
}) =>
    MatchText(
      onTap: (mail) async {
        final url = Uri(scheme: 'mailto', path: mail);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
        onTap();
      },
      pattern: regexEmail,
      style: style,
    );

MatchText urlMatcher({
  final TextStyle? style,
  final Function(String url)? onLinkPressed,
  required final Function onTap,
}) =>
    MatchText(
      onTap: (urlText) async {
        final protocolIdentifierRegex = RegExp(
          r'^((http|ftp|https):\/\/)',
          caseSensitive: false,
        );
        if (!urlText.startsWith(protocolIdentifierRegex)) {
          urlText = 'https://$urlText';
        }
        if (onLinkPressed != null) {
          onLinkPressed(urlText);
        } else {
          final url = Uri.tryParse(urlText);
          if (url != null && await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            );
          }
        }
        onTap();
      },
      pattern: regexLink,
      style: style,
    );

MatchText _patternStyleMatcher({
  required final PatternStyle patternStyle,
  final TextStyle? style,
  required final Function(String?) onTap,
}) =>
    MatchText(
      pattern: patternStyle.pattern,
      style: style,
      renderText: ({required String str, required String pattern}) => {
        'display': str.replaceAll(
          patternStyle.from,
          patternStyle.replace,
        ),
      },
      onTap: onTap,
    );

MatchText boldMatcher({
  final TextStyle? style,
  required final Function onTap,
}) =>
    _patternStyleMatcher(
      patternStyle: PatternStyle.bold,
      style: style,
      onTap: (p0) {
        onTap();
      },
    );

MatchText italicMatcher({
  final TextStyle? style,
  required final Function onTap,
}) =>
    _patternStyleMatcher(
      patternStyle: PatternStyle.italic,
      style: style,
      onTap: (p0) {
        onTap();
      },
    );

MatchText lineThroughMatcher({
  final TextStyle? style,
  required final Function onTap,
}) =>
    _patternStyleMatcher(
      patternStyle: PatternStyle.lineThrough,
      style: style,
      onTap: (p0) {
        onTap();
      },
    );

MatchText codeMatcher({
  final TextStyle? style,
  required final Function onTap,
}) =>
    _patternStyleMatcher(
      patternStyle: PatternStyle.code,
      style: style,
      onTap: (p0) {
        onTap();
      },
    );

class PatternStyle {
  PatternStyle(this.from, this.regExp, this.replace, this.textStyle);

  final Pattern from;
  final RegExp regExp;
  final String replace;
  final TextStyle textStyle;

  String get pattern => regExp.pattern;

  static PatternStyle get bold => PatternStyle(
        '*',
        RegExp('\\*[^\\*]+\\*'),
        '',
        const TextStyle(fontWeight: FontWeight.bold),
      );

  static PatternStyle get code => PatternStyle(
        '`',
        RegExp('`[^`]+`'),
        '',
        TextStyle(
          fontFamily: defaultTargetPlatform == TargetPlatform.iOS
              ? 'Courier'
              : 'monospace',
        ),
      );

  static PatternStyle get italic => PatternStyle(
        '_',
        RegExp('_[^_]+_'),
        '',
        const TextStyle(fontStyle: FontStyle.italic),
      );

  static PatternStyle get lineThrough => PatternStyle(
        '~',
        RegExp('~[^~]+~'),
        '',
        const TextStyle(decoration: TextDecoration.lineThrough),
      );
}

/// Controller for the [TextField] on [Input] widget
/// To highlighting the matches for pattern.
class InputTextFieldController extends TextEditingController {
  /// A map of style to apply to the text pattern.
  final List<PatternStyle> _listPatternStyle = [
    PatternStyle.bold,
    PatternStyle.italic,
    PatternStyle.lineThrough,
    PatternStyle.code,
  ];

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final children = <TextSpan>[];

    text.splitMapJoin(
      RegExp(_listPatternStyle.map((it) => it.regExp.pattern).join('|')),
      onMatch: (match) {
        final text = match[0]!;
        final style = _listPatternStyle
            .firstWhere((element) => element.regExp.hasMatch(text))
            .textStyle;

        final span = TextSpan(text: match.group(0), style: style);
        children.add(span);
        return span.toPlainText();
      },
      onNonMatch: (text) {
        final span = TextSpan(text: text, style: style);
        children.add(span);
        return span.toPlainText();
      },
    );

    return TextSpan(style: style, children: children);
  }
}

/// A class that represents send button widget.
class CalendarButton extends StatelessWidget {
  /// Creates send button widget.
  const CalendarButton({
    super.key,
    required this.onPressed,
    this.padding = EdgeInsets.zero,
  });

  /// Callback for send button tap event.
  final VoidCallback? onPressed;

  /// Padding around the button.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        margin: Chat.theme.sendButtonMargin ??
            const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
        child: Semantics(
          label: Chat.l10n.sendButtonAccessibilityLabel,
          child: IconButton(
            iconSize: 25,
            // constraints: const BoxConstraints(
            //   minHeight: 24,
            //   minWidth: 24,
            // ),
            constraints:
                const BoxConstraints(), // override default min size of 48px
            icon: Chat.theme.sendButtonIcon ??
                Icon(
                  Icons.calendar_month,
                  color: Chat.theme.inputTextColor,
                ),
            style: const ButtonStyle(
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap, // the '2023' part
            ),
            onPressed: onPressed,
            splashRadius: 24,
            tooltip: Chat.l10n.sendButtonAccessibilityLabel,
          ),
        ),
      );
}

/// A class that represents send button widget.
class SendButton extends StatelessWidget {
  /// Creates send button widget.
  const SendButton({
    super.key,
    required this.onPressed,
    this.padding = EdgeInsets.zero,
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  /// Padding around the button.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        margin: Chat.theme.sendButtonMargin ??
            const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
        child: Semantics(
          label: Chat.l10n.sendButtonAccessibilityLabel,
          child: IconButton(
            constraints: const BoxConstraints(
              minHeight: 24,
              minWidth: 24,
            ),
            icon: Chat.theme.sendButtonIcon ??
                Icon(
                  Icons.send,
                  color: Chat.theme.inputTextColor,
                ),
            onPressed: onPressed,
            padding: padding,
            splashRadius: 24,
            tooltip: Chat.l10n.sendButtonAccessibilityLabel,
          ),
        ),
      );
}

/// A class that represents attachment button widget.
class AttachmentButton extends StatelessWidget {
  /// Creates attachment button widget.
  const AttachmentButton({
    super.key,
    this.isLoading = false,
    this.onPressed,
    this.padding = EdgeInsets.zero,
  });

  /// Show a loading indicator instead of the button.
  final bool isLoading;

  /// Callback for attachment button tap event.
  final VoidCallback? onPressed;

  /// Padding around the button.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        margin: Chat.theme.attachmentButtonMargin ??
            const EdgeInsetsDirectional.fromSTEB(
              0,
              0,
              0,
              0,
            ),
        child: IconButton(
          iconSize: 25,
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
          ),
          constraints: const BoxConstraints(),
          icon: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Chat.theme.inputTextColor,
                    ),
                  ),
                )
              : Chat.theme.attachmentButtonIcon ??
                  Icon(
                    Icons.attach_file_rounded,
                    color: Chat.theme.inputTextColor,
                  ),
          onPressed: isLoading ? null : onPressed,
          splashRadius: 24,
          tooltip: Chat.l10n.attachmentButtonAccessibilityLabel,
        ),
      );
}
