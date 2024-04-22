import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';

class MessageNotifierProvider with ChangeNotifier {
  late final IOWebSocketChannel _channel = IOWebSocketChannel.connect(
      Uri.parse("wss://api.studenthub.dev?project_id=$id"));
  late final BehaviorSubject<dynamic> _notifyStream = BehaviorSubject()
    ..addStream(_channel.stream);
  final String id;

  MessageNotifierProvider({required this.id}) : super() {
    _notifyStream.listen((value) {
      // print(value);
      addInbox(value);
    });
  }

  BehaviorSubject<dynamic> get notifyStream => _notifyStream;
  Sink<dynamic> get notifyMessageSink => _channel.sink;

  List<dynamic> inbox = [];

  void addInbox(dynamic message) {
    inbox.add(message);
    print(message);
    notifyListeners();
  }
}
