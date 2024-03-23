import 'dart:async';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/src/chat/realtime/utils/messages_utils.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

import '../../../../connectycube_core.dart';

import 'base_managers.dart';
import '../../chat_connection_service.dart';

class GlobalMessagesManager extends Manager {
  static Map<Connection, GlobalMessagesManager> _instances = Map();

  late StreamSubscription<MessageStanza?> _stanzaSubscription;

  GlobalMessagesManager._private(Connection connection) : super(connection) {
    _stanzaSubscription = MessageHandler.getInstance(connection)
        .messagesStream
        .map((messageStanza) => unwrapCarbonMessage(messageStanza!))
        .where((messageStanza) {
      CubeChatConnection chatConnection = CubeChatConnection.instance;

      return !chatConnection.systemMessagesManager!
              .acceptMessage(messageStanza) &&
          !chatConnection.rtcSignalingManager!.acceptMessage(messageStanza) &&
          !chatConnection.typingStatusesManager!.acceptMessage(messageStanza) &&
          !chatConnection.messagesStatusesManager!
              .acceptMessage(messageStanza) &&
          !chatConnection.messagesReactionsManager!
              .acceptMessage(messageStanza) &&
          !chatConnection.chatMessagesManager!.acceptMessage(messageStanza);
    }).listen((messageStanza) {
      _onReceiveNewMessageStanza(messageStanza);
    });
  }

  static getInstance(Connection connection) {
    GlobalMessagesManager? manager = _instances[connection];
    if (manager == null) {
      manager = GlobalMessagesManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  void _onReceiveNewMessageStanza(MessageStanza? messageStanza) {
    log('receive new message', "GlobalMessagesManager");
  }

  @override
  void destroy() {
    _stanzaSubscription.cancel();
    _instances.remove(connection);
  }
}
