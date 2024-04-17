import 'dart:async';
import 'dart:math';

import 'package:boilerplate/core/widgets/chat_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/input/typing_indicator.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/audio_message_widget.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/schedule_message.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart'
    as types;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:boilerplate/core/widgets/menu_bottom_sheet.dart';

class ScheduleBottomSheet extends StatefulWidget {
  const ScheduleBottomSheet({super.key, required this.filter});
  final InterviewSchedule? filter;

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController title = TextEditingController();

  late final InterviewSchedule itv;

  @override
  void initState() {
    super.initState();
    itv = widget.filter ??
        InterviewSchedule(
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            title: "Null meeting");
    title.text = (itv.title).toString();
    startDate.text =
        (DateFormat("EEEE dd/MM/yyyy HH:MM").format(itv.startDate)).toString();
    endDate.text =
        (DateFormat("EEEE dd/MM/yyyy HH:MM").format(itv.endDate)).toString();
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableSheet(
      keyboardDismissBehavior: const SheetKeyboardDismissBehavior.onDragDown(
        isContentScrollAware: true,
      ),
      child: Container(
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SheetContentScaffold(
            appBar: AppBar(
              title: Text(Lang.get("schedule_interview")),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 44,
                    ),
                    TextField(
                      controller: title,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: Lang.get("nothing_here"),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: Lang.get("title"),
                      ),
                      onChanged: (value) {
                        itv.title = value;
                        // itv.endDate = int.tryParse(value) ?? 2;
                      },
                    ),
                    const Divider(height: 32),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: startDate,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: "None",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                                labelText: Lang.get('profile_project_start'),
                              ),
                              onChanged: (value) {
                                // itv.endDate = int.tryParse(value) ?? 2;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFieldWidget(
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showDateTimePicker(
                                          context: context,
                                          initialDate: itv.startDate,
                                          firstDate: itv.startDate,
                                          //DateTime.now() - not to allow to choose before today.
                                          lastDate: itv.startDate
                                              .add(const Duration(days: 1)));

                                  if (pickedDate != null) {
                                    ////print(pickedDate);
                                    setState(() {
                                      itv.startDate = pickedDate;
                                      startDate.text =
                                          (DateFormat("EEEE dd/MM/yyyy HH:MM")
                                                  .format(itv.startDate))
                                              .toString();
                                    });
                                  }
                                },
                                inputDecoration: const InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2)),
                                ),
                                isIcon: false,
                                label: Text(
                                  Lang.get('profile_project_start'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                enabled: true,
                                enableInteractiveSelection: false,
                                canRequestFocus: false,
                                readOnly: true,
                                fontSize: 15,
                                hint: "Tap",
                                inputType: TextInputType.emailAddress,
                                icon: null,
                                textController: null,
                                inputAction: TextInputAction.next,
                                autoFocus: false,
                                onChanged: (value) {
                                  //_projects[index].proficiency = value;

                                  // _formStore
                                  //     .setUserId(_userEmailController.text);
                                },
                                onFieldSubmitted: (value) {
                                  // FocusScope.of(context)
                                  //     .requestFocus(_passwordFocusNode);
                                },
                                errorText: null
                                // _formStore
                                //             .formErrorStore.userEmail ==
                                //         null
                                //     ? null
                                //     : AppLocalizations.of(context).get(
                                //         _formStore.formErrorStore.userEmail),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: endDate,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: "None",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                                labelText: Lang.get('profile_project_end'),
                              ),
                              onChanged: (value) {
                                // itv.endDate = int.tryParse(value) ?? 2;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFieldWidget(
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showDateTimePicker(
                                          context: context,
                                          initialDate: itv.endDate,
                                          firstDate: itv.endDate,
                                          //DateTime.now() - not to allow to choose before today.
                                          lastDate: itv.endDate
                                              .add(const Duration(days: 1)));

                                  if (pickedDate != null) {
                                    ////print(pickedDate);
                                    setState(() {
                                      itv.endDate = pickedDate;
                                      endDate.text =
                                          (DateFormat("EEEE dd/MM/yyyy HH:MM")
                                                  .format(itv.endDate))
                                              .toString();
                                    });
                                  }
                                },
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                inputDecoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2)),
                                ),
                                label: Text(
                                  Lang.get('profile_project_end'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                isIcon: false,
                                enabled: true,
                                enableInteractiveSelection: false,
                                canRequestFocus: false,
                                readOnly: true,
                                fontSize: 15,
                                inputType: TextInputType.emailAddress,
                                icon: null,
                                textController: null,
                                inputAction: TextInputAction.next,
                                autoFocus: false,
                                onChanged: (value) {
                                  //_projects[index].proficiency = value;

                                  // _formStore
                                  //     .setUserId(_userEmailController.text);
                                },
                                onFieldSubmitted: (value) {
                                  // FocusScope.of(context)
                                  //     .requestFocus(_passwordFocusNode);
                                },
                                errorText: null
                                // _formStore
                                //             .formErrorStore.userEmail ==
                                //         null
                                //     ? null
                                //     : AppLocalizations.of(context).get(
                                //         _formStore.formErrorStore.userEmail),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                    Text(itv.getDuration().toString()),
                  ],
                ),
              ),
            ),
            bottomBar: StickyBottomBarVisibility(
              child: BottomAppBar(
                height: 70,
                surfaceTintColor: Colors.white,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flexible(
                      //   fit: FlexFit.tight,
                      //   child: TextButton(
                      //     onPressed: () {
                      //       widget.onSheetDismissed();
                      //     },
                      //     child: const Text(Lang.get('Cancel'),
                      //   ),
                      // ),
                      // const SizedBox(width: 16),
                      RoundedButtonWidget(
                        buttonColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          itv.clear();
                        },
                        buttonText: Lang.get("cancel"),
                      ),
                      const SizedBox(width: 12),
                      RoundedButtonWidget(
                        buttonColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          Navigator.pop(context, itv);
                        },
                        buttonText: Lang.get("send"),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.title});
  final String title;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<types.Message> _messages = [];
  List<types.User> typings = [];
  final _user = const types.User(
    id: '1',
  );
  Timer? timer;
  @override
  void initState() {
    super.initState();
    // filter = InterviewSchedule(
    // endDate: DateTime.now(), startDate: DateTime.now(), title: "");
    _loadMessages();
    typings = [const types.User(id: "123", firstName: "Lam", lastName: "Quan")];
    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      Random r = Random();
      var num = r.nextInt(25);
      // print(num);
      if (num <= 7) {
        typings = [
          const types.User(id: "1", firstName: "Nam Hà", lastName: "Hồng Dăm")
        ];
      } else if (num > 7 && num < 15) {
        typings = [
          const types.User(id: "3", firstName: "Bảo", lastName: "Minh")
        ];
      } else if (num > 15 && num <= 20) {
        typings.add(const types.User(
            id: "2", firstName: "Jonnathan", lastName: "Nguyên"));
      } else {
        typings.add(
            const types.User(id: "2", firstName: "Ngọc", lastName: "Thuỷ"));
      }
      setState(() {});
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
      _sortMessages();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
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
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        status: types.Status.delivered,
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
      final message = types.AudioMessage(
        duration: Duration.zero,
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        status: types.Status.delivered,
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

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: types.Status.delivered,
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

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
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
              (_messages[index] as types.FileMessage).copyWith(
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
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );
    print("update");
    setState(() {
      logg("loaded preview");
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      status: types.Status.delivered,
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final jsonList = jsonDecode(response) as List;
    List<types.Message> messages = [];
    for (var e in jsonList) {
      var r = types.Message.fromJson(e as Map<String, dynamic>);
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
              author:
                  const types.User(id: "1", firstName: "Bao", lastName: "Doe,"),
              id: const Uuid().v4(),
              type: types.MessageType.schedule,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              status: types.Status.delivered,
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
                  author: const types.User(
                      id: "1", firstName: "Bao", lastName: "Doe,"),
                  id: const Uuid().v4(),
                  type: types.MessageType.schedule,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  status: types.Status.delivered,
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
                                author: const types.User(
                                    id: "1",
                                    firstName: "Bao",
                                    lastName: "Doe,"),
                                id: const Uuid().v4(),
                                type: types.MessageType.schedule,
                                status: types.Status.delivered,
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
          return const Center(
            child: Text(
              "custom nè",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
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

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return ChatAppBar(
      title: widget.title,
      openScheduleDialog: () async {
        ////print("schedule dialog");
        await Future.delayed(const Duration(microseconds: 500)).then((value) {
          showScheduleBottomSheet(_scaffoldKey.currentContext!);
        });
      },
    );
  }
}
