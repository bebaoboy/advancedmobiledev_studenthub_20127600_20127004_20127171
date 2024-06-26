import 'dart:async';
import 'dart:math';

import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/core/widgets/chat_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/chat/chat_store.dart';
import 'package:boilerplate/presentation/dashboard/chat/message_notifier.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat_emoji.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/input/typing_indicator.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/audio_message_widget.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/schedule_message.dart';
import 'package:boilerplate/presentation/dashboard/components/all_schedule_bottom_sheet.dart';
import 'package:boilerplate/presentation/dashboard/components/schedule_bottom_sheet.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/notification/notification.dart';
import 'package:collection/collection.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen(
      {super.key, required this.chatObject, this.isFirstInitiate = false});
  final WrapMessageList chatObject;
  final isFirstInitiate;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<ChatUser> typings = [];
  // List<AbstractChatMessage> _messages = [];

  late ChatUser _user;
  Timer? timer;
  late MessageNotifierProvider messageNotifier;
  String msg = "";

  final chatStore = getIt<ChatStore>();
  final userStore = getIt<UserStore>();
  late UserType _currentUserType;

  void _messageNotifierListener() {
    // if (messageNotifier.inbox.isEmpty) return;
    // final newMessage = messageNotifier.inbox.last;
    // if (newMessage.author.id == _user.id) {
    //   // _addMessage(newMessage);
    // }
  }

  @override
  void initState() {
    super.initState();
    print("init msg receive");
    _user = widget.chatObject.chatUser;

    _currentUserType = userStore.getCurrentType();
    var p = chatStore.messages.firstWhereOrNull(
      (element) =>
          element.project?.objectId == widget.chatObject.project?.objectId &&
          element.chatUser.id == widget.chatObject.chatUser.id,
    );
    if (p != null) {
      p.lastSeenTime = DateTime.now();
    }

    typings = [_user];
    me = ChatUser(
        id: userStore.user!.objectId!, firstName: userStore.user!.name);
    var msgnf = chatStore.getMessageNotifiers(widget.chatObject);
    assert(msgnf != null);
    messageNotifier = msgnf!;
    messageNotifier.addListener(_messageNotifierListener);
    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      Random r = Random();
      var num = r.nextInt(60);
      print(num);
        if (num <= 30) {
          typings = [_user];
      //     typings = [
      //       const ChatUser(id: "1", firstName: "Nam Hà", lastName: "Hồng")
      //     ];
      //   } else if (num > 7 && num < 15) {
      //     typings = [const ChatUser(id: "3", firstName: "Bảo", lastName: "Minh")];
      //   } else if (num > 15 && num <= 20) {
      //     typings.add(
      //         const ChatUser(id: "2", firstName: "Jonathan", lastName: "Nguyên"));
      //   } else if (num < 25) {
      //     typings
      //         .add(const ChatUser(id: "2", firstName: "Ngọc", lastName: "Thuỷ"));
        } else {
          typings.clear();
        }
      setState(() {});
    });

    initScreen();
  }

  initScreen() async {
    await chatStore.getMessageByProjectAndUsers(chatObject: widget.chatObject);

    if (widget.isFirstInitiate) {
      var text = "${userStore.user!.name} wants to chat with you";
      final textMessage = AbstractTextMessage(
        author: ChatUser(
            id: userStore.user!.objectId!, firstName: userStore.user!.name),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        status: Status.delivered,
        text: text,
      );

      chatStore.postMessage(
          content: text,
          projectId: widget.chatObject.project!.objectId!,
          receiverId: _user.id,
          senderId: userStore.user!.objectId!);

      messageNotifier.textSocketHandler.emit("SEND_MESSAGE", {
        "content": text,
        "projectId": widget.chatObject.project!.objectId!,
        "senderId": userStore.user!.objectId!,
        "receiverId": _user.id, // notification
        "messageFlag": 0
      });

      chatStore.insertMessage(widget.chatObject.chatUser,
          widget.chatObject.project!, textMessage, true,
          incoming: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    messageNotifier.removeListener(_messageNotifierListener);
  }

  void updateMessageReactions(MessageReaction reaction, String id,
      {bool remove = false, bool add = false}) {
    // log('[_updateCubeMessageReactions]');
    var msg = chatStore.currentProjectMessages
        .firstWhereOrNull((msg) => msg.id == reaction.messageId);

    if (msg == null) return;

    if (reaction.addReaction != null) {
      if (!(msg.reactions?.own.contains(reaction.addReaction) ?? false)) {
        msg.reactions!.own.add(reaction.addReaction!);

        msg.reactions!.total[reaction.addReaction!] =
            msg.reactions!.total[reaction.addReaction] == null
                ? 1
                : msg.reactions!.total[reaction.addReaction]! + 1;
      }
    }

    if (reaction.removeReaction != null) {
      if ((msg.reactions?.own.contains(reaction.removeReaction) ?? false)) {
        msg.reactions!.own.remove(reaction.removeReaction!);

        msg.reactions!.total[reaction.removeReaction!] =
            msg.reactions!.total[reaction.removeReaction] != null &&
                    msg.reactions!.total[reaction.removeReaction]! > 0
                ? msg.reactions!.total[reaction.removeReaction]! - 1
                : 0;
      }

      msg.reactions!.total.removeWhere((key, value) => value == 0);
    }
    setState(() {});
  }

  late ChatUser me;
  bool loading = true;
  int page = 1;
  int msgByPage = 10;

  @override
  Widget build(BuildContext context) {
    // print("build chat");
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: Observer(builder: (context) {
        return Chat(
          getSearchResult: (searchKeyword) {
            return chatStore.currentProjectMessages
                .where((element) => element.type == AbstractMessageType.text
                    ? (element as AbstractTextMessage)
                        .text
                        .toLowerCase()
                        .contains(searchKeyword.toLowerCase())
                    : element.type == AbstractMessageType.schedule
                        ? (element as ScheduleMessageType)
                            .metadata!["title"]
                            .toLowerCase()
                            .contains(searchKeyword.toLowerCase())
                        : false)
                .toList();
          },
          doneLoadingCb: () {
            if (loading) {
              loading = false;

              if (mounted) {
                Future.delayed(Duration.zero, () {
                  setState(() {});
                });
              }
            }
          },
          user: me,
          performEmoji: (Emoji emoji, AbstractChatMessage message) {
            if ((message.reactions?.own.isNotEmpty ?? false) &&
                (message.reactions?.own.contains(emoji.emoji) ?? false)) {
              updateMessageReactions(
                  MessageReaction("9", "", message.id,
                      removeReaction: emoji.emoji),
                  message.id,
                  remove: true);
              // removeMessageReaction(message.id!, emoji.emoji);
              // updateMessageReactions(CubeMessageReactions(
              //     id!, _cubeDialog.dialogId!, message.messageId!,
              //     removeReaction: emoji.emoji));
            } else {
              updateMessageReactions(
                  MessageReaction("9", "", message.id,
                      addReaction: emoji.emoji),
                  message.id,
                  add: true);
              // addMessageReaction(message.messageId!, emoji.emoji);
              // updateMessageReactions(CubeMessageReactions(
              //     id!, _cubeDialog.dialogId!, message.messageId!,
              //     addReaction: emoji.emoji));
            }
          },
          scrollPhysics: const ClampingScrollPhysics(),
          typingIndicatorOptions: TypingIndicatorOptions(typingUsers: typings),
          messages: chatStore.currentProjectMessages.slice(
              0,
              (page * msgByPage)
                  .clamp(0, chatStore.currentProjectMessages.length)),
          onAttachmentPressed: _handleAttachmentPressed,
          // onFirstIconPressed: () => showScheduleBottomSheet(context),
          onFirstIconPressed: () {
            showAllScheduleBottomSheet(context);
          },
          allMsg: chatStore.currentProjectMessages,
          scrollController: AutoScrollController(),
          onEndReached: () async {
            await Future.delayed(
                Duration(milliseconds: Random().nextInt(200) + 200));
            setState(() {
              page = page + 1;
            });
          },

          isLastPage:
              page == chatStore.currentProjectMessages.length ~/ msgByPage,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          audioMessageBuilder: (p0, {required messageWidth}) {
            return AudioMessageWidget(
              message: p0,
              name: p0.name,
              senderColor: Theme.of(context).colorScheme.primary,
              inActiveAudioSliderColor: Colors.amber,
              activeAudioSliderColor: Colors.red,
            );
          },
          scheduleMessageBuilder: (p0, {required messageWidth}) {
            var t = InterviewSchedule.fromJsonApi(p0.metadata!);

            return ScheduleMessage(
                user: widget.chatObject.chatUser,
                onMenuCallback: (scheduleFilter) async {
                  if (_currentUserType == UserType.company) {
                    showAdaptiveActionSheet(
                      title: Text(
                        "Interview ${Lang.get("option")}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      context: NavigationService.navigatorKey.currentContext!,
                      isDismissible: true,
                      barrierColor: Colors.black87,
                      actions: <BottomSheetAction>[
                        if (_currentUserType == UserType.company)
                          BottomSheetAction(
                            title: Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  Lang.get('reschedule'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal),
                                )),
                            onPressed: (context) async {
                              ////print(scheduleFilter);
                              await Future.delayed(
                                      const Duration(microseconds: 500))
                                  .then((value) {
                                showScheduleBottomSheet(
                                    _scaffoldKey.currentContext!,
                                    flt: scheduleFilter,
                                    id: p0.id);
                              });
                            },
                          ),
                        BottomSheetAction(
                          visibility: !t.isCancel,
                          title: Container(
                              alignment: Alignment.topLeft,
                              child: Text(Lang.get('cancel'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w100))),
                          onPressed: (context) {
                            int i = chatStore.currentProjectMessages
                                .indexWhere((element) => element.id == p0.id);
                            if (i != -1) {
                              chatStore.disableInterview(
                                  interviewId: chatStore
                                      .currentProjectMessages[i].metadata!["id"]
                                      .toString());
                              setState(() {
                                chatStore.currentProjectMessages[i] =
                                    ScheduleMessageType(
                                        messageWidth:
                                            (MediaQuery.of(context).size.width *
                                                    0.9)
                                                .round(),
                                        author: widget.chatObject.chatUser,
                                        id: chatStore
                                            .currentProjectMessages[i].id,
                                        type: AbstractMessageType.schedule,
                                        status: Status.delivered,
                                        createdAt: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        metadata: {
                                      ...chatStore
                                          .currentProjectMessages[i].metadata!,
                                      "isCancel": true,
                                    });

                                _sortMessages();
                              });
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
                scheduleFilter: t,
                message: ScheduleMessageType(
                    author: p0.author,
                    metadata: p0.metadata,
                    id: p0.id,
                    type: p0.type,
                    createdAt: p0.createdAt,
                    updatedAt: p0.updatedAt,
                    messageWidth:
                        (MediaQuery.of(context).size.width * 0.9).round()),
                messageWidth: MediaQuery.of(context).size.width * 0.9);
          },
          customMessageBuilder: (p0, {required messageWidth}) {
            // return ListenableBuilder(
            //   listenable: messageNotifier,
            //   builder: (BuildContext context, Widget? child) {
            //     return Text(
            //         (messageNotifier.inbox.firstOrNull as AbstractTextMessage)
            //             .text);
            //   },
            // );
            return Container();
          },
          // theme: const DefaultChatTheme(
          //   // seenIcon: Text(
          //   //   'read',
          //   //   style: TextStyle(
          //   //     fontSize: 10.0,
          //   //   ),
          //   // ),
          // ),
        );
      }),
    );
  }

  void _addMessage(AbstractChatMessage message) async {
    // chatStore.currentProjectMessages.insert(0, message);
    await chatStore.insertMessage(
        widget.chatObject.chatUser, widget.chatObject.project!, message, true,
        incoming: true);
    // chatStore.currentProjectMessages.insert(0, message);
    _sortMessages();
    if (mounted) {
      setState(() {});
    }
  }

  void _sortMessages() {
    chatStore.currentProjectMessages.sort((a, b) {
      if (a.createdAt == null) {
        return -1;
      } else if (b.createdAt == null) {
        return 1;
      }
      return (a.updatedAt ?? a.createdAt)!
                  .compareTo((b.updatedAt ?? b.createdAt)!) ==
              -1
          ? 1
          : (a.updatedAt ?? a.createdAt)!
                      .compareTo((b.updatedAt ?? b.createdAt)!) ==
                  1
              ? -1
              : 0;
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(Lang.get('photo')),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleAudioSelection();
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(Lang.get('audio')),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(Lang.get('file')),
                ),
              ),
              // TextButton(
              //   onPressed: () => Navigator.pop(context),
              //   child: const Align(
              //     alignment: AlignmentDirectional.centerStart,
              //     child: Text(Lang.get('cancel')),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = AbstractFileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        status: Status.delivered,
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleAudioSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      final message = AbstractAudioMessage(
        duration: Duration.zero,
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        status: Status.delivered,
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = AbstractImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: Status.delivered,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, AbstractChatMessage message) async {
    if (message is AbstractFileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index = chatStore.currentProjectMessages
              .indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (chatStore.currentProjectMessages[index] as AbstractFileMessage)
                  .copyWith(
            isLoading: true,
          );

          setState(() {
            chatStore.currentProjectMessages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index = chatStore.currentProjectMessages
              .indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (chatStore.currentProjectMessages[index] as AbstractFileMessage)
                  .copyWith(
            isLoading: null,
          );

          setState(() {
            chatStore.currentProjectMessages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    AbstractTextMessage message,
    PreviewData previewData,
  ) {
    final index = chatStore.currentProjectMessages
        .indexWhere((element) => element.id == message.id);
    final updatedMessage =
        (chatStore.currentProjectMessages[index] as AbstractTextMessage)
            .copyWith(
      previewData: previewData,
    );
    print("update");
    if (mounted) {
      setState(() {
        logg("loaded preview");
        chatStore.currentProjectMessages[index] = updatedMessage;
      });
    }
  }

  void _handleSendPressed(PartialText message) {
    if (message.text.isEmpty) return;
    final textMessage = AbstractTextMessage(
      author: ChatUser(
          id: userStore.user!.objectId!, firstName: userStore.user!.name),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      status: Status.delivered,
      text: message.text,
    );
    _addMessage(textMessage);

    if (userStore.user != null && userStore.user!.objectId != null) {
      var p = chatStore.messages.firstWhereOrNull(
        (element) =>
            element.chatUser.id == widget.chatObject.chatUser.id &&
            element.project?.objectId == widget.chatObject.project?.objectId,
      );
      p?.messages?.first = MessageObject(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          project: widget.chatObject.project,
          id: textMessage.id,
          content: textMessage.text,
          receiver: Profile(objectId: "-1", name: "null"),
          interviewSchedule: null,
          sender: Profile(
              objectId: userStore.user!.objectId, name: userStore.user!.name));
      p?.lastSeenTime = DateTime.now();
      if (chatStore.isFetching) {
        chatStore.pendingMessage.putIfAbsent(_user, () => message.text);
      } else {
        chatStore.postMessage(
            content: message.text.trim(),
            projectId: widget.chatObject.project!.objectId!,
            receiverId: _user.id,
            senderId: userStore.user!.objectId!);

        messageNotifier.textSocketHandler.emit("SEND_MESSAGE", {
          "content": message.text.trim(),
          "projectId": widget.chatObject.project!.objectId!,
          "senderId": userStore.user!.objectId!,
          "receiverId": _user.id, // notification
          "messageFlag": 0
        });
      }
    }
  }

  /// For file reading
  // void _loadMessages() async {
  //   /// default
  //   final response = await rootBundle.loadString('assets/messages.json');
  //   final jsonList = jsonDecode(response) as List;
  //   List<AbstractChatMessage> messages = [];
  //   for (var e in jsonList) {
  //     var r = AbstractChatMessage.fromJson(e as Map<String, dynamic>);
  //     if (!messages.contains(r)) {
  //       messages.add(r);
  //     } else {
  //       ///print("duplicated id: " + r.id);
  //     }
  //   }

  //   // setState(() {
  //   //   _messages = chatStore.currentProjectMessages;
  //   //   _sortMessages();
  //   // });
  // }

  Future<InterviewSchedule?> showScheduleBottomSheet(BuildContext context,
      {InterviewSchedule? flt, String? id}) async {
    return await Navigator.push<InterviewSchedule>(
      context,
      ModalSheetRoute(
          builder: (context) => ScheduleBottomSheet(
                filter: flt,
              )),
    ).then((value) {
      if (flt == null) {
        if (value != null) {
          value.meetingRoomCode =
              "code-${widget.chatObject.project!.objectId!}-${userStore.user!.objectId!}-${_user.id}-${const Uuid().v4()}";
          value.meetingRoomId =
              "id-${widget.chatObject.project!.objectId!}-${userStore.user!.objectId!}-${_user.id}-${const Uuid().v4()}";
          var ms = {
            "title": value.title.toTitleCase().trim(),
            "content": "Interview created!",
            "projectId": widget.chatObject.project!.objectId!,
            "senderId": userStore.user!.objectId!,
            "receiverId": _user.id, // notification
            "startTime": value.startDate.toUtc().toIso8601String(),
            "endTime": value.endDate.toUtc().toIso8601String(),
            // "disableFlag": value.isCancel ? 1 : 0,
            "meetingRoom": {
              "meeting_room_code": value.meetingRoomCode,
              "meeting_room_id": value.meetingRoomId,
            }
          };

          messageNotifier.textSocketHandler.emit("SCHEDULE_INTERVIEW", ms);
          chatStore.scheduleInterview(
            content: "Interview created",
            title: value.title.toTitleCase().trim(),
            projectId: int.parse(widget.chatObject.project!.objectId!),
            senderId: userStore.user!.objectId!,
            receiverId: _user.id,
            startTime: value.startDate,
            endTime: value.endDate,
            meetingId: value.meetingRoomId,
            meetingCode: value.meetingRoomCode,
          );

          _addMessage(ScheduleMessageType(
              messageWidth: (MediaQuery.of(context).size.width * 0.9).round(),
              author: widget.chatObject.chatUser,
              id: const Uuid().v4(),
              type: AbstractMessageType.schedule,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
              status: Status.delivered,
              metadata: {
                "title": value.title,
                "projectId": widget.chatObject.project!.objectId!,
                "senderId": userStore.user!.objectId!,
                "receiverId": _user.id, // notification
                "startTime": value.startDate,
                "endTime": value.endDate,
                // "disableFlag": value.isCancel ? 1 : 0,
                "meetingRoom": {
                  "meeting_room_code": value.meetingRoomCode,
                  "meeting_room_id": value.meetingRoomId,
                }
              }));

          _sendMeetingCode(value);

          Duration diff = DateTime.now().difference(value.startDate);
          NotificationHelper.scheduleNewNotification(
              diff.inMinutes, diff.inHours, diff.inDays);
        } else {
          Toastify.show(context, '', "Schedule interview fail",
              ToastificationType.error, () {});
        }

        return value;
      } else {
        if (value != null) {
//           value.meetingRoomCode = const Uuid().v1();
//           value.meetingRoomId = const Uuid().v4();
          int i = chatStore.currentProjectMessages
              .indexWhere((element) => element.id == id);
          if (i != -1) {
            setState(() {
              var ms = {
                "title": value.title.toTitleCase().trim(),
                "content": "Interview created!",
                "projectId": widget.chatObject.project!.objectId!,
                "senderId": userStore.user!.objectId!,
                "receiverId": _user.id, // notification
                "startTime": value.startDate.toUtc().toIso8601String(),
                "endTime": value.endDate.toUtc().toIso8601String(),
                "disableFlag": 0,
                "meetingRoom": {
                  "meeting_room_code": value.meetingRoomCode,
                  "meeting_room_id": value.meetingRoomId,
                },
                "interviewId": value.objectId,
                "updateAction": true,
              };
              print(ms);
              messageNotifier.textSocketHandler.emit("UPDATE_INTERVIEW", ms);
              chatStore.currentProjectMessages[i] = ScheduleMessageType(
                  messageWidth:
                      (MediaQuery.of(context).size.width * 0.9).round(),
                  author: widget.chatObject.chatUser,
                  id: id!,
                  type: AbstractMessageType.schedule,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  status: Status.delivered,
                  metadata: {
                    "id": value.objectId,
                    "title": value.title,
                    "projectId": widget.chatObject.project!.objectId!,
                    "endTime": value.endDate,
                    "startTime": value.startDate,
                    "isCancel": false,
                    "meetingRoom": {
                      "meeting_room_code": value.meetingRoomCode,
                      "meeting_room_id": value.meetingRoomId,
                    }
                  });
              _sortMessages();
            });

            chatStore.updateInterview(
              interview: value.objectId!,
              title: value.title,
              endTime: value.endDate,
              startTime: value.startDate,
            );
          }
        }
      }
      return null;
      ////print("cancel schedule");
    });
  }

  Future<InterviewSchedule?> showAllScheduleBottomSheet(BuildContext context,
      {InterviewSchedule? flt, String? id}) async {
    var l2 = chatStore.currentProjectMessages
        .where((element) =>
            element.type == AbstractMessageType.schedule &&
            element.metadata!["disableFlag"] == 0 &&
            (DateTime.tryParse(element.metadata!["endTime"] ?? "") ??
                    DateTime.now())
                .isBefore(DateTime.now()))
        .map(
          (e) => e as ScheduleMessageType,
        )
        .sorted(
          (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
        );
    var l = chatStore.currentProjectMessages
        .where((element) =>
            element.type == AbstractMessageType.schedule &&
            element.metadata!["disableFlag"] == 0 &&
            (DateTime.tryParse(element.metadata!["endTime"] ?? "") ??
                    DateTime.now())
                .isAfter(DateTime.now()))
        .map(
          (e) => e as ScheduleMessageType,
        )
        .sorted(
          (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
        );
    var l3 = chatStore.currentProjectMessages
        .where((element) =>
            element.type == AbstractMessageType.schedule &&
            element.metadata!["disableFlag"] == 1)
        .map(
          (e) => e as ScheduleMessageType,
        )
        .sorted(
          (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
        );

    return await Navigator.push<InterviewSchedule>(
      context,
      ModalSheetRoute(
          builder: (context) => AllScheduleBottomSheet(
              user: widget.chatObject.chatUser,
              scaffoldKey: _scaffoldKey,
              filter: [...l, ...l2, ...l3])),
    );
  }

  _sendMeetingCode(InterviewSchedule interviewSchedule) {
    chatStore.postMessage(
        content: '''Meeting: ${interviewSchedule.title}
Meeting: ${interviewSchedule.meetingRoomId}
Meeting code: ${interviewSchedule.meetingRoomCode.trim()}
          ''',
        projectId: widget.chatObject.project!.objectId!,
        receiverId: _user.id,
        senderId: userStore.user!.objectId!);
    messageNotifier.textSocketHandler.emit("SEND_MESSAGE", {
      "content": '''Meeting: ${interviewSchedule.title}
Meeting: ${interviewSchedule.meetingRoomId}
Meeting code: ${interviewSchedule.meetingRoomCode.trim()}
          ''',
      "projectId": widget.chatObject.project!.objectId!,
      "senderId": userStore.user!.objectId!,
      "receiverId": _user.id, // notification
      "messageFlag": 0
    });

    var e = <String, dynamic>{
      "id": const Uuid().v4(),
      'type': 'text',
      'text': '''Meeting: ${interviewSchedule.title}
Meeting: ${interviewSchedule.meetingRoomId}
Meeting code: ${interviewSchedule.meetingRoomCode.trim()}
          ''',
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "updatedAt": DateTime.now().millisecondsSinceEpoch,
      'status': 'seen',
      'interview': {},
      'author': {
        "firstName": userStore.user!.name,
        "id": userStore.user!.objectId,
      }
    };

    var m = AbstractChatMessage.fromJson(e);
    var p = chatStore.messages.firstWhereOrNull(
      (element) =>
          element.chatUser.id == widget.chatObject.chatUser.id &&
          element.project?.objectId == widget.chatObject.project?.objectId,
    );
    p?.messages?.first = MessageObject(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        project: widget.chatObject.project,
        id: e["id"],
        content: e["text"],
        receiver: Profile(objectId: "-1", name: "null"),
        interviewSchedule: null,
        sender: Profile(
            objectId: userStore.user!.objectId, name: userStore.user!.name));
    p?.lastSeenTime = DateTime.now();
    _addMessage(m);
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return ChatAppBar(
      isStudent: userStore.user?.type == UserType.student,
      title:
          "Project ${widget.chatObject.project?.objectId} - ${widget.chatObject.chatUser.firstName ?? "No name"} ${widget.chatObject.chatUser.lastName ?? ""} (${widget.chatObject.chatUser.id})",
      openScheduleDialog: () async {
        ////print("schedule dialog");
        await Future.delayed(const Duration(microseconds: 500)).then((value) {
          showScheduleBottomSheet(_scaffoldKey.currentContext!);
        });
      },
    );
  }
}
