import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart'
    as types;

import '../../models/util.dart';

/// A class that represents file message widget.
class FileMessage extends StatelessWidget {
  /// Creates a file message widget based on a [types.FileMessage].
  const FileMessage({
    super.key,
    required this.message,
  });

  /// [types.FileMessage].
  final types.FileMessage message;

  @override
  Widget build(BuildContext context) {
    const user = Chat.user;
    final color = user.id == message.author.id
        ? Chat.theme.sentMessageDocumentIconColor
        : Chat.theme.receivedMessageDocumentIconColor;

    return Semantics(
      label: Chat.l10n.fileButtonAccessibilityLabel,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          Chat.theme.messageInsetsVertical,
          Chat.theme.messageInsetsVertical,
          Chat.theme.messageInsetsHorizontal,
          Chat.theme.messageInsetsVertical,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(21),
              ),
              height: 42,
              width: 42,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (message.isLoading ?? false)
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        color: color,
                        strokeWidth: 2,
                      ),
                    ),
                  Chat.theme.documentIcon != null
                      ? Chat.theme.documentIcon!
                      : Icon(
                          Icons.document_scanner,
                          color: color,
                        ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsetsDirectional.only(
                  start: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.name,
                      style: user.id == message.author.id
                          ? Chat.theme.sentMessageBodyTextStyle
                          : Chat.theme.receivedMessageBodyTextStyle,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(
                        formatBytes(message.size.truncate()),
                        style: user.id == message.author.id
                            ? Chat.theme.sentMessageCaptionTextStyle
                            : Chat.theme.receivedMessageCaptionTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
