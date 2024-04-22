import 'dart:async';
import 'dart:math';

import 'package:boilerplate/core/widgets/chat_app_bar_widget.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/message_notifier.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/input/typing_indicator.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/audio_message_widget.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/schedule_message.dart';
import 'package:boilerplate/presentation/dashboard/components/schedule_bottom_sheet.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.chatUser});
  final ChatUser chatUser;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<AbstractChatMessage> _messages = [];
  List<ChatUser> typings = [];
  final _user = const ChatUser(
    id: '1',
  );
  Timer? timer;
  late MessageNotifierProvider messageNotifier;
  String msg = "";

  @override
  void initState() {
    super.initState();
    // filter = InterviewSchedule(
    // endDate: DateTime.now(), startDate: DateTime.now(), title: "");

    _loadMessages();
    typings = [const ChatUser(id: "123", firstName: "Lam", lastName: "Quan")];
    messageNotifier = MessageNotifierProvider(id: widget.chatUser.id);
    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      Random r = Random();
      var num = r.nextInt(30);
      // print(num);
      if (num <= 7) {
        typings = [
          const ChatUser(id: "1", firstName: "Nam Hà", lastName: "Hồng Dăm")
        ];
      } else if (num > 7 && num < 15) {
        typings = [const ChatUser(id: "3", firstName: "Bảo", lastName: "Minh")];
      } else if (num > 15 && num <= 20) {
        typings.add(const ChatUser(
            id: "2", firstName: "Jonnathan", lastName: "Nguyên"));
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
  }

  @override
  Widget build(BuildContext context) {
    // print("build chat");
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: Chat(
        scrollPhysics: const ClampingScrollPhysics(),
        typingIndicatorOptions: TypingIndicatorOptions(typingUsers: typings),
        messages: _messages,
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
              onMenuCallback: (scheduleFilter) async {
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
                    BottomSheetAction(
                      title: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            Lang.get('reschedule'),
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
                          )),
                      onPressed: (context) async {
                        ////print(scheduleFilter);
                        await Future.delayed(const Duration(microseconds: 500))
                            .then((value) {
                          showScheduleBottomSheet(_scaffoldKey.currentContext!,
                              flt: scheduleFilter, id: p0.id);
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
                        int i = _messages
                            .indexWhere((element) => element.id == p0.id);
                        if (i != -1) {
                          setState(() {
                            _messages[i] = ScheduleMessageType(
                                messageWidth:
                                    (MediaQuery.of(context).size.width * 0.9)
                                        .round(),
                                author: widget.chatUser,
                                id: const Uuid().v4(),
                                type: AbstractMessageType.schedule,
                                status: Status.delivered,
                                createdAt:
                                    DateTime.now().millisecondsSinceEpoch,
                                metadata: {
                                  ..._messages[i].metadata!,
                                  "isCancel": true,
                                });
                            _sortMessages();
                          });
                        }
                      },
                    ),
                  ],
                );
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
              return Text(msg);
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
      ),
    );
  }

  void _addMessage(AbstractChatMessage message) {
    setState(() {
      _messages.insert(0, message);
      _sortMessages();
    });
  }

  void _sortMessages() {
    _messages.sort((a, b) {
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
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as AbstractFileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
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
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as AbstractFileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    TextMessageAbstract message,
    PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as TextMessageAbstract).copyWith(
      previewData: previewData,
    );
    print("update");
    setState(() {
      logg("loaded preview");
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(PartialText message) {
    final textMessage = TextMessageAbstract(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      status: Status.delivered,
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final jsonList = jsonDecode(response) as List;
    List<AbstractChatMessage> messages = [];
    for (var e in jsonList) {
      var r = AbstractChatMessage.fromJson(e as Map<String, dynamic>);
      if (!messages.contains(r)) {
        messages.add(r);
      } else {
        ////print("duplicated id: " + r.id);
      }
    }

    setState(() {
      _messages = messages;
      _sortMessages();
    });
  }

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
          _addMessage(ScheduleMessageType(
              messageWidth: (MediaQuery.of(context).size.width * 0.9).round(),
              author: widget.chatUser,
              id: const Uuid().v4(),
              type: AbstractMessageType.schedule,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              status: Status.delivered,
              metadata: value.toJson()));
          ////print(filter);
          return value;
        }
      } else {
        if (value != null) {
          int i = _messages.indexWhere((element) => element.id == id);
          if (i != -1) {
            setState(() {
              _messages[i] = ScheduleMessageType(
                  messageWidth:
                      (MediaQuery.of(context).size.width * 0.9).round(),
                  author: widget.chatUser,
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
          "${widget.chatUser.firstName ?? "No name"} ${widget.chatUser.lastName ?? ""}",
      openScheduleDialog: () async {
        ////print("schedule dialog");
        await Future.delayed(const Duration(microseconds: 500)).then((value) {
          showScheduleBottomSheet(_scaffoldKey.currentContext!);
        });
      },
    );
  }
}
