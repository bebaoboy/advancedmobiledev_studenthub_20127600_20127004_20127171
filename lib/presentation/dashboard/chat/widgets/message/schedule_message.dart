import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../conditional/conditional.dart';
import '../../models/util.dart';

/// A class that represents image message widget. Supports different
/// aspect ratios, renders blurred image as a background which is visible
/// if the image is narrow, renders image in form of a file if aspect
/// ratio is very small or very big.

class ScheduleMessageType extends types.Message {
  double? width;
  double? height;

  ScheduleMessageType(
      {required super.author,
      required super.id,
      required super.type,
      this.width = 200,
      this.height = 100});

  @override
  types.Message copyWith(
      {types.User? author,
      int? createdAt,
      String? id,
      Map<String, dynamic>? metadata,
      String? remoteId,
      types.Message? repliedMessage,
      String? roomId,
      bool? showStatus,
      types.Status? status,
      int? updatedAt}) {
    return ScheduleMessageType(
        author: author ?? types.User(id: ""), id: id ?? "", type: type);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        author,
        createdAt,
        id,
        metadata,
        remoteId,
        repliedMessage,
        roomId,
        showStatus,
        status,
        updatedAt,
      ];

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

///
///
class ScheduleMessage extends StatefulWidget {
  /// Creates an image message widget based on [types.ScheduleMessage].
  const ScheduleMessage({
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

  /// [types.ScheduleMessage].
  final ScheduleMessageType message;

  /// Maximum message width.
  final int messageWidth;

  @override
  State<ScheduleMessage> createState() => _ScheduleMessageState();
}

/// [ScheduleMessage] widget state.
class _ScheduleMessageState extends State<ScheduleMessage> {
  ImageProvider? _image;
  Size _size = Size.zero;
  ImageStream? _stream;

  @override
  void initState() {
    super.initState();
    // _image = widget.imageProviderBuilder != null
    //     ? widget.imageProviderBuilder!(
    //         uri: widget.message.uri,
    //         imageHeaders: widget.imageHeaders,
    //         conditional: Conditional(),
    //       )
    //     : Conditional().getProvider(
    //         widget.message.uri,
    //         headers: widget.imageHeaders,
    //       );
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
    // if (_size.isEmpty) {
    //   _getImage();
    // }
  }

  @override
  void dispose() {
    // _stream?.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Chat.user;

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
                      // widget.message.name,
                      "NAME",
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
                        // formatBytes(widget.message.size.truncate())
                        "SIZE",
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
      return Container(
        height: 170,
        width: MediaQuery.of(context).size.width * 0.98,
        margin: EdgeInsetsDirectional.fromSTEB(
          0,
          Chat.theme.messageInsetsVertical,
          0,
          Chat.theme.messageInsetsVertical,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  fit: FlexFit.loose,
                  child: Row(
                    children: [
                      Text(
                        "Catch up meeting",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                        textWidthBasis: TextWidthBasis.longestLine,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "60 mins",
                        style: Chat.theme.sentMessageCaptionTextStyle.merge(
                            TextStyle(
                                color: Theme.of(context).colorScheme.primary)),
                      ),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  )),

              // Container(
              //   margin: const EdgeInsets.only(
              //     top: 4,
              //   ),
              //   child: Text(
              //     // formatBytes(widget.message.size.truncate()),
              //     "Size",
              //     style: user.id == widget.message.author.id
              //         ? Chat.theme.sentMessageCaptionTextStyle
              //         : Chat.theme.receivedMessageCaptionTextStyle,
              //   ),
              // ),
              Text(
                "Start time: Thursday 13/3/2024 15:00",
                style: TextStyle(color: Colors.black, fontSize: 10),
                textWidthBasis: TextWidthBasis.longestLine,
              ),
              Text(
                "End time: Thursday 13/3/2024 16:00",
                style: TextStyle(color: Colors.black, fontSize: 10),
                textWidthBasis: TextWidthBasis.longestLine,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    RoundedButtonWidget(
                      buttonText: "Join",
                      buttonTextSize: 12,
                      textColor: Theme.of(context).colorScheme.primary,
                      borderColor: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        print("hey");
                      },
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.expand_circle_down_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
