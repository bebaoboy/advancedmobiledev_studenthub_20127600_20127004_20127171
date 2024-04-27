import 'dart:async';
import 'dart:math';

import 'package:boilerplate/core/extensions/cap_extension.dart';
import 'package:boilerplate/core/widgets/chat_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/di/service_locator.dart';
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
import 'package:boilerplate/presentation/dashboard/components/schedule_bottom_sheet.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:collection/collection.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.chatObject});
  final WrapMessageList chatObject;

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
    final newMessage = messageNotifier.inbox.first;
    _addMessage(newMessage);
  }

  @override
  void initState() {
    super.initState();
    // print(widget.chatObject.messages);
    // filter = InterviewSchedule(
    // endDate: DateTime.now(), startDate: DateTime.now(), title: "");

    _user = widget.chatObject.chatUser;
    // Chat.user = ChatUser(
    //     id: userStore.user!.objectId!, firstName: userStore.user!.name);

    _currentUserType = userStore.getCurrentType();

    typings = [const ChatUser(id: "123", firstName: "Lam", lastName: "Quan")];
    // project id
    messageNotifier = MessageNotifierProvider(
        id: widget.chatObject.project!.objectId!, senderName: _user.firstName!);
    messageNotifier.addListener(_messageNotifierListener);
    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      Random r = Random();
      var num = r.nextInt(30);
      // print(num);
      if (num <= 7) {
        typings = [
          const ChatUser(id: "1", firstName: "Nam Hà", lastName: "Hồng")
        ];
      } else if (num > 7 && num < 15) {
        typings = [const ChatUser(id: "3", firstName: "Bảo", lastName: "Minh")];
      } else if (num > 15 && num <= 20) {
        typings.add(
            const ChatUser(id: "2", firstName: "Jonathan", lastName: "Nguyên"));
      } else if (num < 25) {
        typings
            .add(const ChatUser(id: "2", firstName: "Ngọc", lastName: "Thuỷ"));
      } else {
        typings.clear();
      }
      setState(() {});
    });
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

  @override
  Widget build(BuildContext context) {
    // print("build chat");
    return Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(context),
        body: Chat(
          user: ChatUser(id: userStore.user!.objectId!),
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
          messages: chatStore.currentProjectMessages,
          onAttachmentPressed: _handleAttachmentPressed,
          onFirstIconPressed: () => showScheduleBottomSheet(context),
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
            var t = InterviewSchedule.fromJson(p0.metadata!);
            // print(t);
            // print(messageWidth);
            // print(t.objectId);
            return ScheduleMessage(
                user: ChatUser(id: userStore.user!.objectId!),
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
                              setState(() {
                                chatStore.currentProjectMessages[i] =
                                    ScheduleMessageType(
                                        messageWidth:
                                            (MediaQuery.of(context).size.width *
                                                    0.9)
                                                .round(),
                                        author: widget.chatObject.chatUser,
                                        id: const Uuid().v4(),
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
                scheduleFilter: InterviewSchedule(
                    isCancel: t.isCancel,
                    endDate: t.endDate,
                    startDate: t.startDate,
                    title: t.title),
                message: ScheduleMessageType(
                    author: p0.author,
                    id: p0.id,
                    type: p0.type,
                    messageWidth:
                        (MediaQuery.of(context).size.width * 0.9).round()),
                messageWidth: MediaQuery.of(context).size.width * 0.9);
          },
          customMessageBuilder: (p0, {required messageWidth}) {
            return ListenableBuilder(
              listenable: messageNotifier,
              builder: (BuildContext context, Widget? child) {
                return Text(
                    (messageNotifier.inbox.firstOrNull as AbstractTextMessage)
                        .text);
              },
            );
          },
          // theme: const DefaultChatTheme(
          //   // seenIcon: Text(
          //   //   'read',
          //   //   style: TextStyle(
          //   //     fontSize: 10.0,
          //   //   ),
          //   // ),
          // ),
        ));
  }

  void _addMessage(AbstractChatMessage message) {
    chatStore.currentProjectMessages.insert(0, message);
    // chatStore.currentProjectMessages.insert(0, message);
    _sortMessages();
  }

  void _sortMessages() {
    chatStore.currentProjectMessages.sort((a, b) {
      if (a.createdAt == null) {
        return -1;
      } else if (b.createdAt == null) {
        return 1;
      }
      return a.createdAt!.compareTo(b.createdAt!) == -1
          ? 1
          : a.createdAt!.compareTo(b.createdAt!) == 1
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
    setState(() {
      logg("loaded preview");
      chatStore.currentProjectMessages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(PartialText message) {
    if (message.text.isEmpty) return;
    final textMessage = AbstractTextMessage(
      author: ChatUser(
          id: userStore.user!.objectId!, firstName: userStore.user!.name),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      status: Status.delivered,
      text: message.text,
    );
    if (userStore.user != null && userStore.user!.objectId != null) {
      if (chatStore.isFetching) {
        // ToDo: handle sending message if any in store after fetching
        chatStore.pendingMessage.putIfAbsent(_user, () => message.text);
      } else {
        // default for testing
        // messageNotifier.textSocketHandler.emit("SEND_MESSAGE", {
        //   "content": message.text.trim(),
        //   "projectId": 150,
        //   "senderId": userStore.user!.objectId,
        //   "receiverId": 94, // notification
        //   "messageFlag": 0 // default 0 for message, 1 for interview
        // });

        // ToDo: uncomment to send real message;
        messageNotifier.textSocketHandler.emit("SEND_MESSAGE", {
          "content": message.text.trim(),
          "projectId": widget.chatObject.project!.objectId!,
          "senderId": userStore.user!.objectId!,
          "receiverId": _user.id, // notification
          "messageFlag": 0
        });
      }
    }

    _addMessage(textMessage);
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
          // chatStore
          //     .scheduleInterview(
          //         startTime: value.startDate,
          //         endTime: value.endDate,
          //         title: value.title.trim().toTitleCase(),
          //         projectId: int.parse(widget.chatObject.project!.objectId!))
          //     .then((value1) {
          //   if (value1) {
          messageNotifier.textSocketHandler.emit("SCHEDULE_INTERVIEW", {
            "title": value.title,
            "projectId": widget.chatObject.project!.objectId!,
            "senderId": userStore.user!.objectId!,
            "receiverId": _user.id, // notification
            "startTime": value.startDate.toIso8601String(),
            "endTime": value.endDate.toIso8601String(),
            "meeting_room_code": const Uuid().v1(),
            "meeting_room_id": const Uuid().v4()
          });
          _addMessage(ScheduleMessageType(
              messageWidth: (MediaQuery.of(context).size.width * 0.9).round(),
              author: widget.chatObject.chatUser,
              id: const Uuid().v4(),
              type: AbstractMessageType.schedule,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              status: Status.delivered,
              metadata: value.toJson()));
        } else {
          Toastify.show(context, '', "Schedule interview fail",
              ToastificationType.error, () {});
        }
        // });

        ////print(filter);
        return value;
        // }
      } else {
        if (value != null) {
          int i = chatStore.currentProjectMessages
              .indexWhere((element) => element.id == id);
          if (i != -1) {
            setState(() {
              chatStore.currentProjectMessages[i] = ScheduleMessageType(
                  messageWidth:
                      (MediaQuery.of(context).size.width * 0.9).round(),
                  author: widget.chatObject.chatUser,
                  id: const Uuid().v4(),
                  type: AbstractMessageType.schedule,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  status: Status.delivered,
                  metadata: {
                    "title": value.title,
                    "endDate": value.endDate,
                    "startDate": value.startDate,
                    "isCancel": false,
                  });
              _sortMessages();
            });
          }
        }
      }
      return null;
      ////print("cancel schedule");
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return ChatAppBar(
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
