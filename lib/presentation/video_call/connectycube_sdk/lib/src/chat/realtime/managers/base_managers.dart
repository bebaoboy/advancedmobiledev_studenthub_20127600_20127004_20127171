import 'package:xmpp_stone/xmpp_stone.dart';

abstract class Manager {
  Connection _chatConnection;

  Manager(this._chatConnection);

  Connection get connection => _chatConnection;

  void destroy();
}

abstract class StreamedManager {
  void closeStreams();
}
