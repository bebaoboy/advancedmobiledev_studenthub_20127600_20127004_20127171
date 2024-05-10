import 'package:boilerplate/core/widgets/xmpp/xmpp_stone.dart';

abstract class Manager {
  final Connection _chatConnection;

  Manager(this._chatConnection);

  Connection get connection => _chatConnection;

  void destroy();
}

abstract class StreamedManager {
  void closeStreams();
}
