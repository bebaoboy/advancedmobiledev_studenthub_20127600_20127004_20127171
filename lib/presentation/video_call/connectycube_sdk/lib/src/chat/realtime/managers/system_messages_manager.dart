import 'dart:async';

import 'package:xmpp_stone/xmpp_stone.dart';

import '../../../../connectycube_core.dart';

import '../extentions.dart';
import '../utils/messages_utils.dart';
import '../../models/cube_error_packet.dart';
import '../../models/cube_message.dart';
import 'messages_manager.dart';
import '../utils/chat_constants.dart';
import '../utils/jid_utils.dart';

class SystemMessagesManager extends MessagesManager {
  static Map<Connection, SystemMessagesManager> _instances = Map();

  late StreamController<CubeMessage> _systemMessagesStreamController;

  Stream<CubeMessage> get systemMessagesStream =>
      _systemMessagesStreamController.stream;

  SystemMessagesManager._private(Connection connection) : super(connection) {
    _systemMessagesStreamController = StreamController.broadcast();
  }

  static getInstance(Connection connection) {
    SystemMessagesManager? manager = _instances[connection];
    if (manager == null) {
      manager = SystemMessagesManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  Future<void> sendSystemMessage(CubeMessage systemMessage) {
    Completer completer = Completer();

    if (systemMessage.recipientId == null || systemMessage.recipientId == 0) {
      completer.completeError(IllegalArgumentException(
          "'recipientId' can't be null or 0 for system message"));
      return completer.future;
    }

    systemMessage.properties[MODULE_IDENTIFIER] = MODULE_SYSTEM_NOTIFICATIONS;

    CubeMessageStanza messageStanza =
        systemMessage.toStanza(MessageStanzaType.HEADLINE);
    messageStanza.toJid =
        Jid.fromFullJid(getJidForUser(systemMessage.recipientId!));

    connection.writeStanza(messageStanza);
    completer.complete(null);

    return completer.future;
  }

  @override
  bool acceptMessage(MessageStanza messageStanza) {
    if (MessageStanzaType.HEADLINE == messageStanza.type) {
      if (isSystemNotification(messageStanza)) {
        _systemMessagesStreamController
            .add(CubeMessage.fromStanza(messageStanza));
        return true;
      }
    } else if (MessageStanzaType.ERROR == messageStanza.type) {
      if (isSystemNotification(messageStanza)) {
        _systemMessagesStreamController
            .addError(ErrorPacket.fromStanza(messageStanza.getChild('error')!));
        return true;
      }
    }

    return false;
  }

  @override
  void closeStreams() {
    _systemMessagesStreamController.close();
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }
}
