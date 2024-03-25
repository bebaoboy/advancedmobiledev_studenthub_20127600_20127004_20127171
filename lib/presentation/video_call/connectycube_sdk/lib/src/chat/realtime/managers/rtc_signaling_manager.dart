import 'dart:async';

import 'package:boilerplate/core/widgets/xmpp/xmpp_stone.dart';

import '../utils/messages_utils.dart';
import '../../models/cube_error_packet.dart';
import 'messages_manager.dart';

class RTCSignalingManager extends MessagesManager {
  static final Map<Connection, RTCSignalingManager> _instances = {};

  late StreamController<MessageStanza> _signalingMessagesStreamController;

  Stream<MessageStanza> get signalingMessagesStream =>
      _signalingMessagesStreamController.stream;

  RTCSignalingManager._private(super.connection) {
    _signalingMessagesStreamController = StreamController.broadcast();
  }

  static getInstance(Connection connection) {
    RTCSignalingManager? manager = _instances[connection];
    if (manager == null) {
      manager = RTCSignalingManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  Future<void> sendSignalingMessage(MessageStanza signalingMessage) {
    Completer completer = Completer();

    try {
      connection.writeStanza(signalingMessage);
      completer.complete(null);
    } catch (error) {
      completer.completeError(error);
    }

    return completer.future;
  }

  @override
  bool acceptMessage(MessageStanza messageStanza) {
    if (MessageStanzaType.HEADLINE == messageStanza.type) {
      if (isCallNotification(messageStanza)) {
        _signalingMessagesStreamController.add(messageStanza);
        return true;
      }
    } else if (MessageStanzaType.ERROR == messageStanza.type) {
      if (isCallNotification(messageStanza)) {
        _signalingMessagesStreamController
            .addError(ErrorPacket.fromStanza(messageStanza.getChild('error')!));
        return true;
      }
    }

    return false;
  }

  @override
  void closeStreams() {
    _signalingMessagesStreamController.close();
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }
}
