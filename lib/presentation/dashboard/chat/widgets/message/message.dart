import 'package:boilerplate/presentation/dashboard/chat/models/chat_enum.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:visibility_detector/visibility_detector.dart';

import '../../conditional/conditional.dart';
import '../../models/util.dart';

import 'file_message.dart';
import 'image_message.dart';
import 'text_message.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
// ignore: must_be_immutable
class Message extends StatefulWidget {
  /// Creates a particular message from any message type.
  Message({
    super.key,
    this.audioMessageBuilder,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.bubbleRtlAlignment,
    this.customMessageBuilder,
    this.customStatusBuilder,
    required this.emojiEnlargementBehavior,
    this.fileMessageBuilder,
    required this.hideBackgroundOnEmojiMessages,
    this.imageHeaders,
    this.imageMessageBuilder,
    this.imageProviderBuilder,
    required this.message,
    required this.messageWidth,
    this.nameBuilder,
    this.onAvatarTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.isLeftStatus,
    required this.showUserAvatars,
    this.textMessageBuilder,
    required this.textMessageOptions,
    required this.usePreviewData,
    this.userAgent,
    this.videoMessageBuilder,
  });

  /// Build an audio message inside predefined bubble.
  final Widget Function(types.AudioMessage, {required int messageWidth})?
      audioMessageBuilder;

  /// This is to allow custom user avatar builder
  /// By using this we can fetch newest user info based on id.
  final Widget Function(types.User author)? avatarBuilder;

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author).
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Determine the alignment of the bubble for RTL languages. Has no effect
  /// for the LTR languages.
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Build a custom message inside predefined bubble.
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Build a custom status widgets.
  final Widget Function(types.Message message, {required BuildContext context})?
      customStatusBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble.
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  /// See [Chat.imageHeaders].
  final Map<String, String>? imageHeaders;

  /// Build an image message inside predefined bubble.
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// See [Chat.imageProviderBuilder].
  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// Any message type.
  types.Message message;

  /// Maximum message width.
  final int messageWidth;

  /// See [TextMessage.nameBuilder].
  final Widget Function(types.User)? nameBuilder;

  /// See [UserAvatar.onAvatarTap].
  final void Function(types.User)? onAvatarTap;

  /// Called when user double taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// Called when user makes a long press on any message.
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// Called when user makes a long press on status icon in any message.
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// Called when user taps on status icon in any message.
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// Called when user taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// Called when the message's visibility changes.
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [TextMessage.onPreviewDataFetched].
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName].
  final bool showName;

  /// Show message's status.
  final bool showStatus;

  /// This is used to determine if the status icon should be on the left or
  /// right side of the message.
  /// This is only used when [showStatus] is true.
  /// Defaults to false.
  final bool isLeftStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [TextMessage.options].
  final TextMessageOptions textMessageOptions;

  /// See [TextMessage.usePreviewData].
  final bool usePreviewData;

  /// See [TextMessage.userAgent].
  final String? userAgent;

  /// Build an audio message inside predefined bubble.
  final Widget Function(types.VideoMessage, {required int messageWidth})?
      videoMessageBuilder;

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  bool dateVisibility = false;
  String dateString = "";

  @override
  void initState() {
    super.initState();
    dateString = getVerboseDateTimeRepresentation(
      DateTime.fromMillisecondsSinceEpoch(
        widget.message.createdAt!,
      ),
    );
  }

  Widget _avatarBuilder() => widget.showAvatar
      ? widget.avatarBuilder?.call(widget.message.author) ??
          UserAvatar(
            author: widget.message.author,
            bubbleRtlAlignment: widget.bubbleRtlAlignment,
            imageHeaders: widget.imageHeaders,
            onAvatarTap: widget.onAvatarTap,
          )
      : const SizedBox(width: 40);

  Widget _bubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    bool currentUserIsAuthor,
    bool enlargeEmojis,
  ) {
    final defaultMessage = (enlargeEmojis &&
            widget.hideBackgroundOnEmojiMessages)
        ? _messageBuilder()
        : Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: (widget.message.type != types.MessageType.custom) ? null : Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
              color: !currentUserIsAuthor ||
                      widget.message.type == types.MessageType.image
                  ? (dateVisibility
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                      : Chat.theme.secondaryColor)
                  :  (widget.message.type != types.MessageType.custom && widget.message.type != types.MessageType.audio) ? Theme.of(context).colorScheme.primary : Chat.theme.secondaryColor,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: _messageBuilder(),
            ),
          );
    return widget.bubbleBuilder != null
        ? widget.bubbleBuilder!(
            _messageBuilder(),
            message: widget.message,
            nextMessageInGroup: widget.roundBorder,
          )
        : defaultMessage;
  }

  Widget _messageBuilder() {
    switch (widget.message.type) {
      case types.MessageType.audio:
        final audioMessage = widget.message as types.AudioMessage;
        return widget.audioMessageBuilder != null
            ? widget.audioMessageBuilder!(audioMessage,
                messageWidth: widget.messageWidth)
            : const SizedBox();
      case types.MessageType.custom:
        final customMessage = widget.message as types.CustomMessage;
        return widget.customMessageBuilder != null
            ? widget.customMessageBuilder!(customMessage,
                messageWidth: widget.messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = widget.message as types.FileMessage;
        return widget.fileMessageBuilder != null
            ? widget.fileMessageBuilder!(fileMessage,
                messageWidth: widget.messageWidth)
            : FileMessage(message: fileMessage);
      case types.MessageType.image:
        final imageMessage = widget.message as types.ImageMessage;
        return widget.imageMessageBuilder != null
            ? widget.imageMessageBuilder!(imageMessage,
                messageWidth: widget.messageWidth)
            : ImageMessage(
                imageHeaders: widget.imageHeaders,
                imageProviderBuilder: widget.imageProviderBuilder,
                message: imageMessage,
                messageWidth: widget.messageWidth,
              );
      case types.MessageType.text:
        final textMessage = widget.message as types.TextMessage;
        return widget.textMessageBuilder != null
            ? widget.textMessageBuilder!(
                textMessage,
                messageWidth: widget.messageWidth,
                showName: widget.showName,
              )
            : TextMessage(
                emojiEnlargementBehavior: widget.emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages:
                    widget.hideBackgroundOnEmojiMessages,
                message: textMessage,
                nameBuilder: widget.nameBuilder,
                onPreviewDataFetched: widget.onPreviewDataFetched,
                options: widget.textMessageOptions,
                showName: widget.showName,
                usePreviewData: widget.usePreviewData,
                userAgent: widget.userAgent,
                onTapCallback: () {
                  setState(() {
                    dateVisibility = !dateVisibility;
                  });
                },
              );
      case types.MessageType.video:
        final videoMessage = widget.message as types.VideoMessage;
        return widget.videoMessageBuilder != null
            ? widget.videoMessageBuilder!(videoMessage,
                messageWidth: widget.messageWidth)
            : const SizedBox();
      default:
        return const SizedBox();
    }
  }

  Widget _statusIcon(
    BuildContext context,
  ) {
    if (!widget.showStatus) return const SizedBox.shrink();

    return Padding(
      padding: Chat.theme.statusIconPadding,
      child: GestureDetector(
        onLongPress: () =>
            widget.onMessageStatusLongPress?.call(context, widget.message),
        onTap: () => widget.onMessageStatusTap?.call(context, widget.message),
        child: widget.customStatusBuilder != null
            ? widget.customStatusBuilder!(widget.message, context: context)
            : MessageStatus(status: widget.message.status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final user = Chat.user;
    final currentUserIsAuthor = user.id == widget.message.author.id;
    final enlargeEmojis =
        widget.emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            widget.message is types.TextMessage &&
            isConsistsOfEmojis(
              widget.emojiEnlargementBehavior,
              widget.message as types.TextMessage,
            );
    final messageBorderRadius = Chat.theme.messageBorderRadius;
    final borderRadius = widget.bubbleRtlAlignment == BubbleRtlAlignment.left
        ? BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(
              !currentUserIsAuthor || widget.roundBorder
                  ? messageBorderRadius
                  : 0,
            ),
            bottomStart: Radius.circular(
              currentUserIsAuthor || widget.roundBorder
                  ? messageBorderRadius
                  : 0,
            ),
            topEnd: Radius.circular(messageBorderRadius),
            topStart: Radius.circular(messageBorderRadius),
          )
        : BorderRadius.only(
            bottomLeft: Radius.circular(
              currentUserIsAuthor || widget.roundBorder
                  ? messageBorderRadius
                  : 0,
            ),
            bottomRight: Radius.circular(
              !currentUserIsAuthor || widget.roundBorder
                  ? messageBorderRadius
                  : 0,
            ),
            topLeft: Radius.circular(messageBorderRadius),
            topRight: Radius.circular(messageBorderRadius),
          );

    return Container(
      alignment: widget.bubbleRtlAlignment == BubbleRtlAlignment.left
          ? currentUserIsAuthor
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart
          : currentUserIsAuthor
              ? Alignment.centerRight
              : Alignment.centerLeft,
      margin: widget.bubbleRtlAlignment == BubbleRtlAlignment.left
          ? EdgeInsetsDirectional.only(
              bottom: 4,
              end: isMobile ? query.padding.right : 0,
              start: 20 + (isMobile ? query.padding.left : 0),
            )
          : EdgeInsets.only(
              bottom: 4,
              left: 20 + (isMobile ? query.padding.left : 0),
              right: isMobile ? query.padding.right : 0,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        textDirection: widget.bubbleRtlAlignment == BubbleRtlAlignment.left
            ? null
            : TextDirection.ltr,
        children: [
          if (!currentUserIsAuthor && widget.showUserAvatars) _avatarBuilder(),
          if (currentUserIsAuthor && widget.isLeftStatus) _statusIcon(context),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.messageWidth.toDouble(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onDoubleTap: () =>
                      widget.onMessageDoubleTap?.call(context, widget.message),
                  onLongPress: () =>
                      widget.onMessageLongPress?.call(context, widget.message),
                  onTap: () {
                    widget.onMessageTap?.call(context, widget.message);
                    setState(() {
                      dateVisibility = !dateVisibility;
                    });
                  },
                  child: widget.onMessageVisibilityChanged != null
                      ? VisibilityDetector(
                          key: Key(widget.message.id),
                          onVisibilityChanged: (visibilityInfo) =>
                              widget.onMessageVisibilityChanged!(
                            widget.message,
                            visibilityInfo.visibleFraction > 0.1,
                          ),
                          child: _bubbleBuilder(
                            context,
                            borderRadius.resolve(Directionality.of(context)),
                            currentUserIsAuthor,
                            enlargeEmojis,
                          ),
                        )
                      : _bubbleBuilder(
                          context,
                          borderRadius.resolve(Directionality.of(context)),
                          currentUserIsAuthor,
                          enlargeEmojis,
                        ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: dateVisibility ? 40 : 0,
                  child: Text(
                    dateString,
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          ),
          if (currentUserIsAuthor && !widget.isLeftStatus) _statusIcon(context),
        ],
      ),
    );
  }
}

/// A class that represents a message status.
class MessageStatus extends StatelessWidget {
  /// Creates a message status widget.
  const MessageStatus({
    super.key,
    required this.status,
  });

  /// Status of the message.
  final types.Status? status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case types.Status.delivered:
      case types.Status.sent:
        return Chat.theme.deliveredIcon != null
            ? Chat.theme.deliveredIcon!
            : Icon(
                Icons.done_all,
                color: Chat.theme.primaryColor,
              );
      case types.Status.error:
        return Chat.theme.errorIcon != null
            ? Chat.theme.errorIcon!
            : Icon(
                Icons.error,
                color: Chat.theme.errorColor,
              );
      case types.Status.seen:
        return Chat.theme.seenIcon != null
            ? Chat.theme.seenIcon!
            : Icon(
                Icons.done_all,
                color: Chat.theme.primaryColor,
              );
      case types.Status.sending:
        return Chat.theme.sendingIcon != null
            ? Chat.theme.sendingIcon!
            : Center(
                child: SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Chat.theme.primaryColor,
                    ),
                  ),
                ),
              );
      default:
        return const SizedBox(width: 8);
    }
  }
}

/// Renders user's avatar or initials next to a message.
class UserAvatar extends StatelessWidget {
  /// Creates user avatar.
  const UserAvatar({
    super.key,
    required this.author,
    this.bubbleRtlAlignment,
    this.imageHeaders,
    this.onAvatarTap,
  });

  /// Author to show image and name initials from.
  final types.User author;

  /// See [Message.bubbleRtlAlignment].
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// See [Chat.imageHeaders].
  final Map<String, String>? imageHeaders;

  /// Called when user taps on an avatar.
  final void Function(types.User)? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final color = getUserAvatarNameColor(
      author,
      Chat.theme.userAvatarNameColors,
    );
    final hasImage = author.imageUrl != null;
    final initials = getUserInitials(author);

    return Container(
      margin: bubbleRtlAlignment == BubbleRtlAlignment.left
          ? const EdgeInsetsDirectional.only(end: 8)
          : const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onAvatarTap?.call(author),
        child: CircleAvatar(
          backgroundColor:
              hasImage ? Chat.theme.userAvatarImageBackgroundColor : color,
          backgroundImage: hasImage
              ? NetworkImage(author.imageUrl!, headers: imageHeaders)
              : null,
          radius: 16,
          child: !hasImage
              ? Text(
                  initials,
                  style: Chat.theme.userAvatarTextStyle,
                )
              : null,
        ),
      ),
    );
  }
}
