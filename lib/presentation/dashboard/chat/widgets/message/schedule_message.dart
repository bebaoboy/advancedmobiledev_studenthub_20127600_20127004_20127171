// ignore_for_file: unused_element

import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
import 'package:boilerplate/presentation/video_call/managers/call_manager.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:intl/intl.dart';

import '../../conditional/conditional.dart';

/// A class that represents image message widget. Supports different
/// aspect ratios, renders blurred image as a background which is visible
/// if the image is narrow, renders image in form of a file if aspect
/// ratio is very small or very big.

// ignore: must_be_immutable
class ScheduleMessageType extends AbstractChatMessage {
  double? width;
  double? height;
  int messageWidth;

  ScheduleMessageType({
    required super.author,
    super.createdAt,
    required super.id,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    super.updatedAt,
    this.width = 200,
    this.height = 100,
    required super.type,
    required this.messageWidth,
  });

  @override
  AbstractChatMessage copyWith(
      {ChatUser? author,
      int? createdAt,
      String? id,
      Map<String, dynamic>? metadata,
      String? remoteId,
      AbstractChatMessage? repliedMessage,
      String? roomId,
      bool? showStatus,
      Status? status,
      int? updatedAt,
      List<MessageReaction>? reactions}) {
    return ScheduleMessageType(
        author: author ?? const ChatUser(id: ""),
        id: id ?? "",
        type: type,
        messageWidth: messageWidth);
  }

  @override
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
    return {
      "author": author,
      "createdAt": createdAt,
      "id": id,
      "metadata": metadata,
      "remoteId": remoteId,
      "repliedMessage": repliedMessage,
      "roomId": roomId,
      "showStatus": showStatus,
      "status": status,
      "updatedAt": updatedAt,
    };
  }

  static AbstractChatMessage fromJson(Map<String, dynamic> json) {
    return ScheduleMessageType(
      messageWidth: 1,
      author: const ChatUser(id: "1", firstName: "Bao", lastName: "Doe,"),
      type: AbstractMessageType.schedule,
      status: Status.delivered,
      createdAt: json['createdAt'] as int?,
      id: json['id'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      remoteId: json['remoteId'] as String?,
      repliedMessage: json['repliedMessage'] == null
          ? null
          : AbstractChatMessage.fromJson(
              json['repliedMessage'] as Map<String, dynamic>),
      roomId: json['roomId'] as String?,
      showStatus: json['showStatus'] as bool?,
      updatedAt: json['updatedAt'] as int?,
    );
  }
}

///
///
class ScheduleMessage extends StatefulWidget {
  /// Creates an image message widget based on [ScheduleMessage].
  const ScheduleMessage({
    super.key,
    this.imageHeaders,
    this.imageProviderBuilder,
    required this.message,
    required this.messageWidth,
    required this.onMenuCallback,
    required this.scheduleFilter,
    required this.user,
  });

  final Function(InterviewSchedule) onMenuCallback;
  final InterviewSchedule scheduleFilter;

  /// See [Chat.imageHeaders].
  final Map<String, String>? imageHeaders;

  /// See [Chat.imageProviderBuilder].
  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// [ScheduleMessage].
  final ScheduleMessageType message;

  /// Maximum message width.
  final double messageWidth;
  final ChatUser user;

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
    print("add schl image");
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

  var userStore = getIt<UserStore>();

  @override
  Widget build(BuildContext context) {
    var user = userStore.user!;

    if (_size.aspectRatio == 0) {
      return Container(
        color: Chat.theme.secondaryColor,
        height: _size.height,
        width: _size.width,
      );
    } else if (_size.aspectRatio < 0.1 || _size.aspectRatio > 10) {
      return Container(
        color: user.objectId == widget.message.author.id
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
                      style: user.objectId == widget.message.author.id
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
                        style: user.objectId == widget.message.author.id
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
        width: MediaQuery.of(context).size.width * 0.98,
        margin: EdgeInsetsDirectional.fromSTEB(
          0,
          Chat.theme.messageInsetsVertical,
          0,
          Chat.theme.messageInsetsVertical,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LimitedBox(
                  maxHeight: 30,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LimitedBox(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                        child: AutoSizeText(
                          widget.scheduleFilter.title.toTitleCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          minFontSize: 7,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: AutoSizeText(
                            widget.scheduleFilter.getDuration(),
                            minFontSize: 5,
                            maxLines: 1,
                            maxFontSize: 12,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
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
              const SizedBox(
                height: 10,
              ),

              AutoSizeText(
                "${Lang.get("profile_project_start")}: ${DateFormat("EEEE dd/MM/yyyy HH:mm").format(widget.scheduleFilter.startDate.toLocal())}",
                // style: const TextStyle(color: Colors.black),
                maxLines: 1,
                minFontSize: 5,
                // textWidthBasis: TextWidthBasis.longestLine,
              ),
              const SizedBox(
                height: 10,
              ),
              AutoSizeText(
                "${Lang.get("profile_project_end")}: ${DateFormat("EEEE dd/MM/yyyy HH:mm").format(widget.scheduleFilter.endDate.toLocal())}",
                // style: const TextStyle(color: Colors.black),
                maxLines: 1,
                minFontSize: 5,
                // textWidthBasis: TextWidthBasis.longestLine,
              ),
              // const SizedBox(
              //   height: 10,
              // ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (userStore.getCurrentType() == UserType.company)
                      if (!widget.scheduleFilter.endDate
                          .isBefore(DateTime.now()))
                        IconButton(
                          onPressed: () {
                            widget.onMenuCallback(widget.scheduleFilter);
                          },
                          icon: Icon(
                            Icons.expand_circle_down_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    !widget.scheduleFilter.isCancel &&
                            !DateTime.now()
                                .isAfter(widget.scheduleFilter.endDate)
                        ? RoundedButtonWidget(
                            buttonText: !widget.scheduleFilter.startDate
                                    .isBefore(DateTime.now())

                                ? "Join Early"
                                : Lang.get("Join"),
                            buttonTextSize: 12,
                            textColor: Theme.of(context).colorScheme.primary,
                            borderColor: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              //print("hey");

                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => SelectOpponentsScreen(
                              //         CubeSessionManager
                              //             .instance.activeSession!.user!,
                              //         users: users
                              //             .where((user) =>
                              //                 user.id !=
                              //                 CubeSessionManager.instance
                              //                     .activeSession!.user!.id)
                              //             .toList())));

                              // ToDo: pass in right id for call
                              CallManager.instance.startPreviewMeeting(
                                  NavigationService.navigatorKey.currentContext!,
                                  CallType.VIDEO_CALL,
                                  {int.parse(widget.user.id)},
                                  widget.scheduleFilter);
                              // Navigator.of(context).push(MaterialPageRoute2(
                              //     routeName:
                              //         "${Routes.previewMeeting}/${CubeSessionManager.instance.activeSession!.user!.id}",
                              //     arguments: users));
                            },
                          )
                        : Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(widget.scheduleFilter.isCancel ? "Meeting Canceled" :
                                widget.scheduleFilter.endDate
                                        .isBefore(DateTime.now())

                                    ? "Meeting ended"
                                    : "Meeting Canceled!",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
