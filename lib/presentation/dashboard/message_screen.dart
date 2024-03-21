import 'package:boilerplate/core/widgets/chat_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/chat.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/input/typing_indicator.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/schedule_message.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class ScheduleFilter {
  String title;
  DateTime endDate;
  DateTime startDate;

  ScheduleFilter(
      {required this.endDate, required this.startDate, required this.title});

  clear() {
    endDate = DateTime.now();
    startDate = DateTime.now();
    title = "";
  }

  getDuration() {
    return endDate.difference(startDate).inMinutes.toString();
  }

  @override
  String toString() {
    return ("\n${title.toString()}") +
        ("\n${endDate.toString()}") +
        ("\n ${startDate.toString()}");
  }
}

class ScheduleBottomSheet extends StatefulWidget {
  const ScheduleBottomSheet({required this.filter});
  final ScheduleFilter filter;

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController title = TextEditingController();

  @override
  void initState() {
    super.initState();
    title.text = (widget.filter.title).toString();
    startDate.text =
        (DateFormat("EEEE dd/MM/yyyy HH:MM").format(widget.filter.endDate))
            .toString();
    endDate.text =
        (DateFormat("EEEE dd/MM/yyyy HH:MM").format(widget.filter.startDate))
            .toString();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableSheet(
      keyboardDismissBehavior: const SheetKeyboardDismissBehavior.onDragDown(
        isContentScrollAware: true,
      ),
      child: Container(
        decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),clipBehavior: Clip.antiAlias,
        child: SheetContentScaffold(
            appBar: AppBar(
              title: const Text("Filter by"),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: title,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "None",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: "Title",
                      ),
                      onChanged: (value) {
                        // widget.filter.endDate = int.tryParse(value) ?? 2;
                      },
                    ),
                    const Divider(height: 32),
                    TextField(
                      controller: startDate,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "None",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: "Start",
                      ),
                      onChanged: (value) {
                        // widget.filter.endDate = int.tryParse(value) ?? 2;
                      },
                    ),
                    const Divider(height: 32),
                    TextField(
                      controller: endDate,
                      decoration: InputDecoration(
                        hintText: "None",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        labelText: "End",
                      ),
                      onChanged: (value) {
                        // widget.filter.startDate = int.tryParse(value) ?? 0;
                      },
                    ),
                    const Divider(height: 32),
                    Text(widget.filter.getDuration().toString()),
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
                      //     child: const Text('Cancel'),
                      //   ),
                      // ),
                      // const SizedBox(width: 16),
                      RoundedButtonWidget(
                        buttonColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          widget.filter.clear();
                        },
                        buttonText: "Cancel",
                      ),
                      const SizedBox(width: 12),
                      RoundedButtonWidget(
                        buttonColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          Navigator.pop(context, widget.filter);
                        },
                        buttonText: "Send Invite",
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
  final _user = const types.User(
    id: '1',
  );
  late ScheduleFilter filter;

  @override
  void initState() {
    super.initState();
    filter = ScheduleFilter(
        endDate: DateTime.now(), startDate: DateTime.now(), title: "");
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
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
        } catch (e) {
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

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final jsonList = jsonDecode(response) as List;
    List<types.Message> messages = [];
    jsonList.forEach((e) {
      var r = types.Message.fromJson(e as Map<String, dynamic>);
      if (!messages.contains(r)) {
        messages.add(r);
      } else {
        print("duplicated id: " + r.id);
      }
    });

    setState(() {
      _messages = messages;
    });
  }

  Future<ScheduleFilter?> showScheduleBottomSheet(BuildContext context,
      {ScheduleFilter? flt}) async {
    return await Navigator.push(
      context,
      ModalSheetRoute(
        builder: (context) => ScheduleBottomSheet(
          filter: flt ?? filter,
        ),
      ),
    ).then((value) {
      if (value != null) {
        _addMessage(types.CustomMessage(
            author: types.User(id: "1", firstName: "Bao", lastName: "Doe,"),
            id: const Uuid().v4(),
            type: types.MessageType.custom,
            createdAt: DateTime.now().millisecondsSinceEpoch));
        print(filter);
        return value;
      }
      print("cancel schedule");
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: Chat(
        typingIndicatorOptions: TypingIndicatorOptions(typingUsers: [
          types.User(id: "123", firstName: "Lam", lastName: "Quan")
        ]),
        messages: _messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        customMessageBuilder: (p0, {required messageWidth}) {
          //print(p0.metadata!["type"]);
          return ScheduleMessage(
              onMenuCallback: (scheduleFilter) async {
                print(scheduleFilter);
                await Future.delayed(Duration(microseconds: 500)).then((value) {
                  showScheduleBottomSheet(_scaffoldKey.currentContext!, flt: scheduleFilter);
                });
              },
              scheduleFilter: ScheduleFilter(
                  endDate: DateTime.now(),
                  startDate: DateTime.now(),
                  title: "New Meeting"),
              message: ScheduleMessageType(
                  author: p0.author, id: p0.id, type: p0.type),
              messageWidth: messageWidth);
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
        print("schedule dialog");
        await Future.delayed(Duration(microseconds: 500)).then((value) {
          showScheduleBottomSheet(_scaffoldKey.currentContext!);
        });
      },
    );
  }
}
