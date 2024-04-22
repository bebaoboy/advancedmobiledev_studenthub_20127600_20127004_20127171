import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';

import '../../conditional/conditional.dart';
import '../../models/util.dart';

/// A class that represents image message widget. Supports different
/// aspect ratios, renders blurred image as a background which is visible
/// if the image is narrow, renders image in form of a file if aspect
/// ratio is very small or very big.
class ImageMessage extends StatefulWidget {
  /// Creates an image message widget based on [AbstractImageMessage].
  const ImageMessage({
    super.key,
    this.imageHeaders,
    this.imageProviderBuilder,
    required this.message,
    required this.messageWidth,
  });

  /// See [Chat.imageHeaders].
  final Map<String, String>? imageHeaders;

  /// See [Chat.imageProviderBuilder].
  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// [AbstractImageMessage].
  final AbstractImageMessage message;

  /// Maximum message width.
  final int messageWidth;

  @override
  State<ImageMessage> createState() => _ImageMessageState();
}

/// [ImageMessage] widget state.
class _ImageMessageState extends State<ImageMessage> {
  ImageProvider? _image;
  Size _size = Size.zero;
  ImageStream? _stream;

  @override
  void initState() {
    super.initState();
    _image = widget.imageProviderBuilder != null
        ? widget.imageProviderBuilder!(
            uri: widget.message.uri,
            imageHeaders: widget.imageHeaders,
            conditional: Conditional(),
          )
        : Conditional().getProvider(
            widget.message.uri,
            headers: widget.imageHeaders,
          );
    _size = Size(widget.message.width ?? 0, widget.message.height ?? 0);
  }

  void _getImage() {
    final oldImageStream = _stream;
    _stream = _image?.resolve(createLocalImageConfiguration(context));
    if (_stream?.key == oldImageStream?.key) {
      return;
    }
    final listener = ImageStreamListener(_updateImage);
    oldImageStream?.removeListener(listener);
    _stream?.addListener(listener);
  }

  void _updateImage(ImageInfo info, bool _) {
    // ignore: avoid_print
    print("update image");
    setState(() {
      _size = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_size.isEmpty) {
      _getImage();
    }
  }

  @override
  void dispose() {
    _stream?.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const user = Chat.user;

    if (_size.aspectRatio == 0) {
      return Container(
        color: Chat.theme.secondaryColor,
        height: _size.height,
        width: _size.width,
      );
    } else if (_size.aspectRatio < 0.1 || _size.aspectRatio > 10) {
      return Container(
        color: user.id == widget.message.author.id
            ? Chat.theme.primaryColor
            : Chat.theme.secondaryColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              margin: EdgeInsetsDirectional.fromSTEB(
                Chat.theme.messageInsetsVertical,
                Chat.theme.messageInsetsVertical,
                16,
                Chat.theme.messageInsetsVertical,
              ),
              width: 64,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image(
                  fit: BoxFit.cover,
                  image: _image!,
                ),
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsetsDirectional.fromSTEB(
                  0,
                  Chat.theme.messageInsetsVertical,
                  Chat.theme.messageInsetsHorizontal,
                  Chat.theme.messageInsetsVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.name,
                      style: user.id == widget.message.author.id
                          ? Chat.theme.sentMessageBodyTextStyle
                          : Chat.theme.receivedMessageBodyTextStyle,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(
                        formatBytes(widget.message.size.truncate()),
                        style: user.id == widget.message.author.id
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
      );
    } else {
      return AspectRatio(
        aspectRatio: _size.aspectRatio > 0 ? _size.aspectRatio : 1,
        child: SizedBox(
          height: widget.messageWidth.toDouble(),
          width: 170,
          child: Image(
            fit: BoxFit.contain,
            image: _image!,
          ),
        ),
      );
    }
  }
}
