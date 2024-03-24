import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:xmpp_stone/xmpp_stone.dart';

import '../../models/message_reaction_model.dart';
import '../extentions.dart';
import 'messages_manager.dart';
import '../utils/messages_utils.dart';

class MessagesReactionsManager extends MessagesManager {
  static Map<Connection, MessagesReactionsManager> _instances = Map();

  late StreamController<MessageReaction> _reactionsStreamController;

  Stream<MessageReaction> get reactionsStream =>
      _reactionsStreamController.stream;

  MessagesReactionsManager._private(Connection connection) : super(connection) {
    _reactionsStreamController = StreamController.broadcast();
  }

  static getInstance(Connection connection) {
    MessagesReactionsManager? manager = _instances[connection];
    if (manager == null) {
      manager = MessagesReactionsManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  @override
  bool acceptMessage(MessageStanza stanza) {
    XmppElement? stateElement = stanza.children.firstWhereOrNull((child) {
      if (child.name == ReactionsElement.ELEMENT_NAME) {
        var reactionElement = ReactionsElement.fromStanza(child);
        var dialogId = getDialogIdFromExtraParams(stanza);

        var reaction = MessageReaction(
            reactionElement.userId, dialogId ?? '', reactionElement.messageId,
            addReaction: reactionElement.addReaction,
            removeReaction: reactionElement.removeReaction);

        _reactionsStreamController.add(reaction);
        return true;
      }

      return false;
    });

    return stateElement != null;
  }

  @override
  void closeStreams() {
    _reactionsStreamController.close();
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }
}
