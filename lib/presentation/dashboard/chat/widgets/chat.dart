import 'dart:math';

import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/dashboard/chat/chat_store.dart';
import 'package:boilerplate/presentation/dashboard/chat/models/chat_enum.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/schedule_message.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart' show PhotoViewComputedScale;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'chat_theme.dart';
import '../conditional/conditional.dart';
import '../models/util.dart';
import 'chat_list.dart';
import 'image_gallery.dart';
import 'input/input.dart';
import 'message/message.dart';
import 'message/text_message.dart';
import 'input/typing_indicator.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';

logg(String? message, [String? tag]) {
  debugPrint("CB-SDK: ${tag ?? "BEBAOBOY"}: $message");
}

/// Keep track of all the auto scroll indices by their respective message's id to allow animating to them.
final Map<String, int> chatMessageAutoScrollIndexById = {};

/// Entry widget, represents the complete chat. If you wrap it in [SafeArea] and
/// it should be full screen, set [SafeArea]'s `bottom` to `false`.
class Chat extends StatefulWidget {
  static const lightTheme = DefaultChatTheme();
  static const darkTheme = DarkChatTheme();
  static ChatTheme theme = const DefaultChatTheme();

  final Function(Emoji emoji, AbstractChatMessage message) performEmoji;

  /// Creates a chat widget.
  const Chat({
    required this.user,
    required this.performEmoji,
    super.key,
    this.audioMessageBuilder,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.bubbleRtlAlignment = BubbleRtlAlignment.right,
    this.customBottomWidget,
    this.customDateHeaderText,
    this.customMessageBuilder,
    this.customStatusBuilder,
    this.dateFormat,
    this.dateHeaderBuilder,
    this.dateHeaderThreshold = 300000,
    this.dateIsUtc = false,
    this.dateLocale,
    this.disableImageGallery,
    this.emojiEnlargementBehavior = EmojiEnlargementBehavior.multi,
    this.emptyState,
    this.fileMessageBuilder,
    this.groupMessagesThreshold = 300000,
    this.hideBackgroundOnEmojiMessages = true,
    this.imageGalleryOptions = const ImageGalleryOptions(
      maxScale: PhotoViewComputedScale.covered,
      minScale: PhotoViewComputedScale.contained,
    ),
    this.imageHeaders,
    this.imageMessageBuilder,
    this.imageProviderBuilder,
    this.inputOptions = const InputOptions(),
    this.isAttachmentUploading,
    this.isLastPage,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.listBottomWidget,
    required this.messages,
    this.nameBuilder,
    this.onAttachmentPressed,
    this.onFirstIconPressed,
    this.onAvatarTap,
    this.onBackgroundTap,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.onSendPressed,
    this.scrollController,
    this.scrollPhysics,
    this.scrollToUnreadOptions = const ScrollToUnreadOptions(),
    this.showUserAvatars = false,
    this.showUserNames = false,
    this.systemMessageBuilder,
    this.textMessageBuilder,
    this.textMessageOptions = const TextMessageOptions(),
    this.timeFormat,
    this.typingIndicatorOptions = const TypingIndicatorOptions(),
    this.usePreviewData = true,
    this.userAgent,
    this.useTopSafeAreaInset,
    this.videoMessageBuilder,
    this.slidableMessageBuilder,
    this.isLeftStatus = false,
    this.messageWidthRatio = 0.72,
    this.scheduleMessageBuilder,
    required this.doneLoadingCb,
  });

  final Function doneLoadingCb;

  /// See [MessageWidget.audioMessageBuilder].
  final Widget Function(AbstractAudioMessage, {required int messageWidth})?
      audioMessageBuilder;

  /// See [MessageWidget.avatarBuilder].
  final Widget Function(ChatUser author)? avatarBuilder;

  /// See [MessageWidget.bubbleBuilder].
  final Widget Function(
    Widget child, {
    required AbstractChatMessage message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// See [MessageWidget.bubbleRtlAlignment].
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Allows you to replace the default Input widget e.g. if you want to create a channel view. If you're looking for the bottom widget added to the chat list, see [listBottomWidget] instead.
  final Widget? customBottomWidget;

  /// If [dateFormat], [dateLocale] and/or [timeFormat] is not enough to customize date headers in your case, use this to return an arbitrary string based on a [DateTime] of a particular message. Can be helpful to return "Today" if [DateTime] is today. IMPORTANT: this will replace all default date headers, so you must handle all cases yourself, like for example today, yesterday and before. Or you can just return the same date header for any message.
  final String Function(DateTime)? customDateHeaderText;

  /// See [MessageWidget.customMessageBuilder].
  final Widget Function(AbstractCustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// See [MessageWidget.customMessageBuilder].
  final Widget Function(ScheduleMessageType, {required int messageWidth})?
      scheduleMessageBuilder;

  /// See [MessageWidget.customStatusBuilder].
  final Widget Function(AbstractChatMessage message,
      {required BuildContext context})? customStatusBuilder;

  /// Allows you to customize the date format. IMPORTANT: only for the date, do not return time here. See [timeFormat] to customize the time format. [dateLocale] will be ignored if you use this, so if you want a localized date make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText] for more customization.
  final DateFormat? dateFormat;

  /// Custom date header builder gives ability to customize date header widget.
  final Widget Function(DateHeader)? dateHeaderBuilder;

  /// Time (in ms) between two messages when we will render a date header.
  /// Default value is 15 minutes, 900000 ms. When time between two messages
  /// is higher than this threshold, date header will be rendered. Also,
  /// not related to this value, date header will be rendered on every new day.
  final int dateHeaderThreshold;

  /// Use utc time to convert message milliseconds to date.
  final bool dateIsUtc;

  /// Locale will be passed to the `Intl` package. Make sure you initialized
  /// date formatting in your app before passing any locale here, otherwise
  /// an error will be thrown. Also see [customDateHeaderText], [dateFormat], [timeFormat].
  final String? dateLocale;

  /// Disable automatic image preview on tap.
  final bool? disableImageGallery;

  /// See [MessageWidget.emojiEnlargementBehavior].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Allows you to change what the user sees when there are no messages.
  /// `emptyChatPlaceholder` and `emptyChatPlaceholderTextStyle` are ignored
  /// in this case.
  final Widget? emptyState;

  /// See [MessageWidget.fileMessageBuilder].
  final Widget Function(AbstractFileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Time (in ms) between two messages when we will visually group them.
  /// Default value is 1 minute, 60000 ms. When time between two messages
  /// is lower than this threshold, they will be visually grouped.
  final int groupMessagesThreshold;

  /// See [MessageWidget.hideBackgroundOnEmojiMessages].
  final bool hideBackgroundOnEmojiMessages;

  /// See [ImageGallery.options].
  final ImageGalleryOptions imageGalleryOptions;

  /// Headers passed to all network images used in the chat.
  final Map<String, String>? imageHeaders;

  /// See [MessageWidget.imageMessageBuilder].
  final Widget Function(AbstractImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// This feature allows you to use a custom image provider.
  /// This is useful if you want to manage image loading yourself, or if you need to cache images.
  /// You can also use the `cached_network_image` feature, but when it comes to caching, you might want to decide on a per-message basis.
  /// Plus, by using this provider, you can choose whether or not to send specific headers based on the URL.
  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// See [Input.options].
  final InputOptions inputOptions;

  /// See [Input.isAttachmentUploading].
  final bool? isAttachmentUploading;

  /// See [ChatList.isLastPage].
  final bool? isLastPage;

  /// See [ChatList.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Localized copy. Extend [ChatL10n] class to create your own copy or use
  /// existing one, like the default [ChatL10nEn]. You can customize only
  /// certain properties, see more here [ChatL10nEn].
  static const ChatL10n l10n = ChatL10nEn();

  /// See [ChatList.bottomWidget]. For a custom chat input
  /// use [customBottomWidget] instead.
  final Widget? listBottomWidget;

  /// List of [AbstractChatMessage] to render in the chat widget.
  final List<AbstractChatMessage> messages;

  /// See [MessageWidget.nameBuilder].
  final Widget Function(ChatUser)? nameBuilder;

  /// See [Input.onAttachmentPressed].
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onFirstIconPressed;

  /// See [MessageWidget.onAvatarTap].
  final void Function(ChatUser)? onAvatarTap;

  /// Called when user taps on background.
  final VoidCallback? onBackgroundTap;

  /// See [ChatList.onEndReached].
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold].
  final double? onEndReachedThreshold;

  /// See [MessageWidget.onMessageDoubleTap].
  final void Function(BuildContext context, AbstractChatMessage)?
      onMessageDoubleTap;

  /// See [MessageWidget.onMessageLongPress].
  final void Function(BuildContext context, AbstractChatMessage)?
      onMessageLongPress;

  /// See [MessageWidget.onMessageStatusLongPress].
  final void Function(BuildContext context, AbstractChatMessage)?
      onMessageStatusLongPress;

  /// See [MessageWidget.onMessageStatusTap].
  final void Function(BuildContext context, AbstractChatMessage)?
      onMessageStatusTap;

  /// See [MessageWidget.onMessageTap].
  final void Function(BuildContext context, AbstractChatMessage)? onMessageTap;

  /// See [MessageWidget.onMessageVisibilityChanged].
  final void Function(AbstractChatMessage, bool visible)?
      onMessageVisibilityChanged;

  /// See [MessageWidget.onPreviewDataFetched].
  final void Function(AbstractTextMessage, PreviewData)? onPreviewDataFetched;

  /// See [Input.onSendPressed].
  final void Function(PartialText) onSendPressed;

  /// See [ChatList.scrollController].
  /// If provided, you cannot use the scroll to message functionality.
  final AutoScrollController? scrollController;

  /// See [ChatList.scrollPhysics].
  final ScrollPhysics? scrollPhysics;

  /// Controls if and how the chat should scroll to the newest unread message.
  final ScrollToUnreadOptions scrollToUnreadOptions;

  /// See [MessageWidget.showUserAvatars].
  final bool showUserAvatars;

  /// Show user names for received messages. Useful for a group chat. Will be
  /// shown only on text messages.
  final bool showUserNames;

  /// Builds a system message outside of any bubble.
  final Widget Function(AbstractSystemMessage)? systemMessageBuilder;

  /// See [MessageWidget.textMessageBuilder].
  final Widget Function(
    AbstractTextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [MessageWidget.textMessageOptions].
  final TextMessageOptions textMessageOptions;

  /// Chat theme. Extend [ChatTheme] class to create your own theme or use
  /// existing one, like the [DefaultChatTheme]. You can customize only certain
  /// properties, see more here [DefaultChatTheme].
  // final ChatTheme theme;

  /// Allows you to customize the time format. IMPORTANT: only for the time, do not return date here. See [dateFormat] to customize the date format. [dateLocale] will be ignored if you use this, so if you want a localized time make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText] for more customization.
  final DateFormat? timeFormat;

  /// Used to show typing users with indicator. See [TypingIndicatorOptions].
  final TypingIndicatorOptions typingIndicatorOptions;

  /// See [MessageWidget.usePreviewData].
  final bool usePreviewData;

  /// See [InheritedUser.user].
  final ChatUser user;

  /// See [MessageWidget.userAgent].
  final String? userAgent;

  /// See [ChatList.useTopSafeAreaInset].
  final bool? useTopSafeAreaInset;

  /// See [MessageWidget.videoMessageBuilder].
  final Widget Function(AbstractVideoMessage, {required int messageWidth})?
      videoMessageBuilder;

  /// See [MessageWidget.slidableMessageBuilder].
  final Widget Function(AbstractChatMessage, Widget msgWidget)?
      slidableMessageBuilder;

  /// See [MessageWidget.isLeftStatus].
  /// If true, status will be shown on the left side of the message.
  /// If false, status will be shown on the right side of the message.
  /// Default value is false.
  final bool isLeftStatus;

  /// Width ratio for message bubble.
  final double messageWidthRatio;

  @override
  State<Chat> createState() => ChatState();
}

/// [Chat] widget state.
class ChatState extends State<Chat> {
  /// Used to get the correct auto scroll index from [chatMessageAutoScrollIndexById].
  static const String _unreadHeaderId = 'unread_header_id';

  List<Object> _chatMessages = [];
  List<PreviewImage> _gallery = [];
  PageController? _galleryPageController;
  bool _hadScrolledToUnreadOnOpen = false;
  bool _isImageViewVisible = false;

  late final AutoScrollController _scrollController;
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final chatStore = getIt<ChatStore>();

  @override
  void initState() {
    super.initState();

    _scrollController = widget.scrollController ?? AutoScrollController();
    Chat.theme = _themeStore.darkMode ? Chat.darkTheme : Chat.lightTheme;
    didUpdateWidget(widget);
  }

  /// Scroll to the unread header.
  void scrollToUnreadHeader() {
    final unreadHeaderIndex = chatMessageAutoScrollIndexById[_unreadHeaderId];
    if (unreadHeaderIndex != null) {
      _scrollController.scrollToIndex(
        unreadHeaderIndex,
        duration: widget.scrollToUnreadOptions.scrollDuration,
      );
    }
  }

  /// Scroll to the message with the specified [id].
  void scrollToMessage(
    String id, {
    Duration? scrollDuration,
    bool withHighlight = false,
    Duration? highlightDuration,
  }) async {
    await _scrollController.scrollToIndex(
      chatMessageAutoScrollIndexById[id]!,
      duration: scrollDuration ?? scrollAnimationDuration,
      preferPosition: AutoScrollPosition.middle,
    );
    if (withHighlight) {
      await _scrollController.highlight(
        chatMessageAutoScrollIndexById[id]!,
        highlightDuration: highlightDuration ?? const Duration(seconds: 3),
      );
    }
  }

  /// Highlight the message with the specified [id].
  void highlightMessage(String id, {Duration? duration}) =>
      _scrollController.highlight(
        chatMessageAutoScrollIndexById[id]!,
        highlightDuration: duration ?? const Duration(seconds: 3),
      );

  Widget _emptyStateBuilder() =>
      widget.emptyState ??
      Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Text(
          Chat.l10n.emptyChatPlaceholder,
          style: Chat.theme.emptyChatPlaceholderTextStyle,
          textAlign: TextAlign.center,
        ),
      );

  /// Only scroll to first unread if there are messages and it is the first open.
  void _maybeScrollToFirstUnread() {
    if (widget.scrollToUnreadOptions.scrollOnOpen &&
        _chatMessages.isNotEmpty &&
        !_hadScrolledToUnreadOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await Future.delayed(widget.scrollToUnreadOptions.scrollDelay);
          scrollToUnreadHeader();
        }
      });
      _hadScrolledToUnreadOnOpen = true;
    }
  }

  /// We need the index for auto scrolling because it will scroll until it reaches an index higher or equal that what it is scrolling towards. Index will be null for removed messages. Can just set to -1 for auto scroll.
  Widget _messageBuilder(
    Object object,
    BoxConstraints constraints,
    int? index,
  ) {
    if (object is DateHeader) {
      return widget.dateHeaderBuilder?.call(object) ??
          Container(
            alignment: Alignment.center,
            margin: Chat.theme.dateDividerMargin,
            child: Text(
              object.text,
              style: Chat.theme.dateDividerTextStyle,
            ),
          );
    } else if (object is MessageSpacer) {
      return SizedBox(
        height: object.height,
      );
    } else if (object is UnreadHeaderData) {
      return AutoScrollTag(
        controller: _scrollController,
        index: index ?? -1,
        key: const Key('unread_header'),
        child: UnreadHeader(
          marginTop: object.marginTop,
        ),
      );
    } else {
      final map = object as Map<String, Object>;
      final message = map['message']! as AbstractChatMessage;

      final Widget messageWidget;

      if (message is AbstractSystemMessage) {
        messageWidget = widget.systemMessageBuilder?.call(message) ??
            SystemMessage(message: message.text);
      } else {
        final maxWidth = message.type == AbstractMessageType.schedule
            ? (constraints.maxWidth * 0.8).round()
            : MediaQuery.of(context).size.width * 0.7;
        final messageWidth =
            widget.showUserAvatars && message.author.id != widget.user.id
                ? min(constraints.maxWidth * widget.messageWidthRatio, maxWidth)
                    .floor()
                : min(
                    constraints.maxWidth * (widget.messageWidthRatio + 0.06),
                    maxWidth,
                  ).floor();
        final Widget msgWidget = MessageWidget(
          user: widget.user,
          performEmoji: widget.performEmoji,
          scheduleMessageBuilder: widget.scheduleMessageBuilder,
          audioMessageBuilder: widget.audioMessageBuilder,
          avatarBuilder: widget.avatarBuilder,
          bubbleBuilder: widget.bubbleBuilder,
          bubbleRtlAlignment: widget.bubbleRtlAlignment,
          customMessageBuilder: widget.customMessageBuilder,
          customStatusBuilder: widget.customStatusBuilder,
          emojiEnlargementBehavior: widget.emojiEnlargementBehavior,
          fileMessageBuilder: widget.fileMessageBuilder,
          hideBackgroundOnEmojiMessages: widget.hideBackgroundOnEmojiMessages,
          imageHeaders: widget.imageHeaders,
          imageMessageBuilder: widget.imageMessageBuilder,
          imageProviderBuilder: widget.imageProviderBuilder,
          message: message,
          messageWidth: messageWidth,
          nameBuilder: widget.nameBuilder,
          onAvatarTap: widget.onAvatarTap,
          onMessageDoubleTap: widget.onMessageDoubleTap,
          onMessageLongPress: widget.onMessageLongPress,
          onMessageStatusLongPress: widget.onMessageStatusLongPress,
          onMessageStatusTap: widget.onMessageStatusTap,
          onMessageTap: (context, tappedMessage) {
            if (tappedMessage is AbstractImageMessage &&
                widget.disableImageGallery != true) {
              _onImagePressed(tappedMessage);
            }

            widget.onMessageTap?.call(context, tappedMessage);
          },
          onMessageVisibilityChanged: widget.onMessageVisibilityChanged,
          onPreviewDataFetched: _onPreviewDataFetched,
          roundBorder: map['nextMessageInGroup'] == true,
          isLast: map['isLast'] == true,
          isFirst: map['isFirst'] == true,
          showAvatar: map['nextMessageInGroup'] == false &&
              message.type != AbstractMessageType.schedule,
          showName: map['showName'] == true,
          showStatus: map['showStatus'] == true &&
              message.type != AbstractMessageType.schedule,
          isLeftStatus: widget.isLeftStatus,
          showUserAvatars: widget.showUserAvatars &&
              message.type != AbstractMessageType.schedule,
          textMessageBuilder: widget.textMessageBuilder,
          textMessageOptions: widget.textMessageOptions,
          usePreviewData: widget.usePreviewData,
          userAgent: widget.userAgent,
          videoMessageBuilder: widget.videoMessageBuilder,
        );
        messageWidget = widget.slidableMessageBuilder == null
            ? msgWidget
            : widget.slidableMessageBuilder!(message, msgWidget);
      }

      return AutoScrollTag(
        controller: _scrollController,
        index: index ?? -1,
        key: Key('scroll-${message.id}'),
        highlightColor: Chat.theme.highlightMessageColor,
        child: messageWidget,
      );
    }
  }

  void _onCloseGalleryPressed() {
    setState(() {
      _isImageViewVisible = false;
    });
    _galleryPageController?.dispose();
    _galleryPageController = null;
  }

  void _onImagePressed(AbstractImageMessage message) {
    final initialPage = _gallery.indexWhere(
      (element) => element.id == message.id && element.uri == message.uri,
    );
    _galleryPageController = PageController(initialPage: initialPage);
    setState(() {
      _isImageViewVisible = true;
    });
  }

  void _onPreviewDataFetched(
    AbstractTextMessage message,
    PreviewData previewData,
  ) {
    widget.onPreviewDataFetched?.call(message, previewData);
  }

  /// Updates the [chatMessageAutoScrollIndexById] mapping with the latest messages.
  void _refreshAutoScrollMapping() {
    chatMessageAutoScrollIndexById.clear();
    var i = 0;
    for (final object in _chatMessages) {
      if (object is UnreadHeaderData) {
        chatMessageAutoScrollIndexById[_unreadHeaderId] = i;
      } else if (object is Map<String, Object>) {
        final message = object['message']! as AbstractChatMessage;
        chatMessageAutoScrollIndexById[message.id] = i;
      }
      i++;
    }
  }

  @override
  void didUpdateWidget(covariant Chat oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.isNotEmpty) {
      final result = calculateChatMessages(
        widget.messages,
        widget.user,
        customDateHeaderText: widget.customDateHeaderText,
        dateFormat: widget.dateFormat,
        dateHeaderThreshold: widget.dateHeaderThreshold,
        dateIsUtc: widget.dateIsUtc,
        dateLocale: widget.dateLocale,
        groupMessagesThreshold: widget.groupMessagesThreshold,
        lastReadMessageId: widget.scrollToUnreadOptions.lastReadMessageId,
        showUserNames: widget.showUserNames,
        timeFormat: widget.timeFormat,
      );

      _chatMessages = result[0] as List<Object>;
      _gallery = result[1] as List<PreviewImage>;

      _refreshAutoScrollMapping();
      _maybeScrollToFirstUnread();
    }
  }

  @override
  void dispose() {
    _galleryPageController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // logg("build chat", "BEBAOBOY");
    return Stack(
      children: [
        Container(
          color: Chat.theme.backgroundColor,
          child: Column(
            children: [
              Observer(builder: (context) {
                if (chatStore.isFetching) {
                  return const Flexible(
                    child: SizedBox.expand(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: LoadingScreenWidget(),
                      ),
                    ),
                  );
                } else {
                  widget.doneLoadingCb();
                  return Flexible(
                    child: widget.messages.isEmpty
                        ? SizedBox.expand(
                            child: _emptyStateBuilder(),
                          )
                        : GestureDetector(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              widget.onBackgroundTap?.call();
                            },
                            child: LayoutBuilder(builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
                              //print("rebuild");
                              return ChatList(
                                user: widget.user,
                                bottomWidget: widget.listBottomWidget,
                                bubbleRtlAlignment: widget.bubbleRtlAlignment!,
                                isLastPage: widget.isLastPage,
                                itemBuilder: (Object item, int? index) =>
                                    _messageBuilder(
                                  item,
                                  constraints,
                                  index,
                                ),
                                items: _chatMessages,
                                keyboardDismissBehavior:
                                    widget.keyboardDismissBehavior,
                                onEndReached: widget.onEndReached,
                                onEndReachedThreshold:
                                    widget.onEndReachedThreshold,
                                scrollController: _scrollController,
                                scrollPhysics: widget.scrollPhysics,
                                typingIndicatorOptions:
                                    widget.typingIndicatorOptions,
                                useTopSafeAreaInset:
                                    widget.useTopSafeAreaInset ?? isMobile,
                              );
                            }),
                          ),
                  );
                }
              }),
              widget.customBottomWidget ??
                  Input(
                    isAttachmentUploading: widget.isAttachmentUploading,
                    onAttachmentPressed: widget.onAttachmentPressed,
                    onFirstIconPressed: widget.onFirstIconPressed,
                    onSendPressed: widget.onSendPressed,
                    options: widget.inputOptions,
                    scrollController: _scrollController,
                  ),
            ],
          ),
        ),
        if (_isImageViewVisible)
          ImageGallery(
            imageHeaders: widget.imageHeaders,
            imageProviderBuilder: widget.imageProviderBuilder,
            images: _gallery,
            pageController: _galleryPageController!,
            onClosePressed: _onCloseGalleryPressed,
            options: widget.imageGalleryOptions,
          ),
      ],
    );
  }
}

/// Base chat l10n containing all required properties to provide localized copy.
/// Extend this class if you want to create a custom l10n.
@immutable
abstract class ChatL10n {
  /// Creates a new chat l10n based on provided copy.
  const ChatL10n({
    required this.attachmentButtonAccessibilityLabel,
    required this.emptyChatPlaceholder,
    required this.fileButtonAccessibilityLabel,
    required this.inputPlaceholder,
    required this.sendButtonAccessibilityLabel,
    required this.unreadMessagesLabel,
  });

  /// Accessibility label (hint) for the attachment button.
  final String attachmentButtonAccessibilityLabel;

  /// Placeholder when there are no messages.
  final String emptyChatPlaceholder;

  /// Accessibility label (hint) for the tap action on file message.
  final String fileButtonAccessibilityLabel;

  /// Placeholder for the text field.
  final String inputPlaceholder;

  /// Accessibility label (hint) for the send button.
  final String sendButtonAccessibilityLabel;

  /// Label for the unread messages header.
  final String unreadMessagesLabel;
}

/// English l10n which extends [ChatL10n].
@immutable
class ChatL10nEn extends ChatL10n {
  /// Creates English l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n].
  const ChatL10nEn({
    super.attachmentButtonAccessibilityLabel = 'Send media',
    super.emptyChatPlaceholder = 'No messages here yet',
    super.fileButtonAccessibilityLabel = 'File',
    super.inputPlaceholder = 'Message',
    super.sendButtonAccessibilityLabel = 'Send',
    super.unreadMessagesLabel = 'Unread messages',
  });
}
