import 'dart:async';

import 'package:xmpp_stone/xmpp_stone.dart';

import '../../../../connectycube_core.dart';

import '../../models/cube_error_packet.dart';
import '../../models/cube_message.dart';
import 'chat_managers.dart' as chatManager;
import 'messages_manager.dart';

class ChatMessagesManager extends MessagesManager {
  static Map<Connection, ChatMessagesManager> _instances = Map();

  late StreamController<CubeMessage> _chatMessagesStreamController;

  Stream<CubeMessage> get chatMessagesStream =>
      _chatMessagesStreamController.stream;

  ChatMessagesManager._private(Connection connection) : super(connection) {
    _chatMessagesStreamController = StreamController.broadcast();
  }

  static getInstance(Connection connection) {
    ChatMessagesManager? manager = _instances[connection];
    if (manager == null) {
      manager = ChatMessagesManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  @override
  bool acceptMessage(MessageStanza messageStanza) {
    if (MessageStanzaType.CHAT == messageStanza.type) {
      log("Receive PRIVATE chat message ${messageStanza.id}");
      CubeMessage cubeMessage = CubeMessage.fromStanza(messageStanza);

      _markMsgDeliveredIfNeed(cubeMessage);

      _chatMessagesStreamController.add(cubeMessage);
      return true;
    } else if (MessageStanzaType.GROUPCHAT == messageStanza.type) {
      log("Receive GROUP chat message ${messageStanza.id}");
      CubeMessage cubeMessage = CubeMessage.fromStanza(messageStanza);

      _markMsgDeliveredIfNeed(cubeMessage);

      _chatMessagesStreamController.add(cubeMessage);
      return true;
    } else if (MessageStanzaType.ERROR == messageStanza.type) {
      _chatMessagesStreamController
          .addError(ErrorPacket.fromStanza(messageStanza.getChild('error')!));
      return true;
    }

    return false;
  }

  void _markMsgDeliveredIfNeed(CubeMessage cubeMessage) {
    if (cubeMessage.markable && CubeSettings.instance.autoMarkDelivered) {
      sendDeliveredStatus(cubeMessage);
    }
  }

  /// Informs the sender that message was read
  /// [cubeMessage] - the original message, it should contain next required fields:
  ///                 'senderId', 'messageId', 'dialogId'
  Future<void> sendReadStatus(CubeMessage cubeMessage) {
    return chatManager.sendReadStatus(connection, cubeMessage);
  }

  /// Informs the sender that message was delivered
  /// [cubeMessage] - the original message, it should contain next required fields:
  ///                 'senderId', 'messageId', 'dialogId'
  Future<void> sendDeliveredStatus(CubeMessage cubeMessage) {
    return chatManager.sendDeliveredStatus(connection, cubeMessage);
  }

  @override
  void closeStreams() {
    _chatMessagesStreamController.close();
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }
}
