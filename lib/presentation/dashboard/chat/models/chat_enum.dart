enum BubbleRtlAlignment {
  left,
  right,
}

/// Used to control the enlargement behavior of the emojis in the
/// [TextMessage].
enum EmojiEnlargementBehavior {
  /// The emojis will be enlarged only if the [TextMessage] consists of
  /// one or more emojis.
  multi,

  /// Never enlarge emojis.
  never,

  /// The emoji will be enlarged only if the [TextMessage] consists of
  /// a single emoji.
  single,
}

/// Used to set [Input] clear mode when message is sent.
enum InputClearMode {
  /// Always clear [Input] regardless if message is sent or not.
  always,

  /// Never clear [Input]. You should do it manually, depending on your use case.
  /// To clear the input manually, use [Input.options.textEditingController] (see
  /// docs how to use it properly, but TL;DR set it to [InputTextFieldController]
  /// imported from the library, to not lose any functionalily).
  never,
}

/// Used to toggle the visibility behavior of the [SendButton] based on the
/// [TextField] state inside the [Input] widget.
enum SendButtonVisibilityMode {
  /// Always show the [SendButton] regardless of the [TextField] state.
  always,

  /// The [SendButton] will only appear when the [TextField] is not empty.
  editing,

  /// Always hide the [SendButton] regardless of the [TextField] state.
  hidden,
}

/// Used to toggle the display of avatars, names or both on [TypingIndicator].
enum TypingIndicatorMode {
  /// Show avatars of typing users.
  avatar,

  /// Show both avatars and names for typing users.
  both,

  /// Show names of typing users.
  name,
}
