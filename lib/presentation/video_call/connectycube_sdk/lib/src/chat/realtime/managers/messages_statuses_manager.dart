import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:boilerplate/core/widgets/xmpp/xmpp_stone.dart';

import '../extentions.dart';
import 'messages_manager.dart';
import '../../models/message_status_model.dart';
import '../utils/jid_utils.dart';
import '../utils/messages_utils.dart';

class MessagesStatusesManager extends MessagesManager {
  static final Map<Connection, MessagesStatusesManager> _instances = {};

  late StreamController<CubeMessageStatus> _deliveredStreamController;
  late StreamController<CubeMessageStatus> _readStreamController;
  late StreamController<EditedMessageStatus> _editStreamController;
  late StreamController<CubeMessageStatus> _deleteStreamController;

  Stream<CubeMessageStatus> get deliveredStream =>
      _deliveredStreamController.stream;

  Stream<CubeMessageStatus> get readStream => _readStreamController.stream;

  Stream<EditedMessageStatus> get editedStream => _editStreamController.stream;

  Stream<CubeMessageStatus> get deletedStream => _deleteStreamController.stream;

  MessagesStatusesManager._private(super.connection) {
    _deliveredStreamController = StreamController.broadcast();
    _readStreamController = StreamController.broadcast();
    _editStreamController = StreamController.broadcast();
    _deleteStreamController = StreamController.broadcast();
  }

  static getInstance(Connection connection) {
    MessagesStatusesManager? manager = _instances[connection];
    if (manager == null) {
      manager = MessagesStatusesManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  @override
  bool acceptMessage(MessageStanza stanza) {
    XmppElement? stateElement = stanza.children.firstWhereOrNull((element) {
      var nameSpace = element.getAttribute("xmlns");
      if (nameSpace == null) return false;

      if (nameSpace.value == MessageMarkerElement.NAME_SPACE &&
              _isReadOrDeliveredStatus(stanza, element) ||
          nameSpace.value == EditMessageElement.NAME_SPACE &&
              _isEditedStatus(stanza, element) ||
          nameSpace.value == RemoveMessageElement.NAME_SPACE &&
              _isDeletedStatus(stanza, element)) {
        return true;
      }

      return false;
    });

    return stateElement != null;
  }

  bool _isReadOrDeliveredStatus(
      MessageStanza stanza, XmppElement stateElement) {
    MessageMarkerElement marker = MessageMarkerElement.fromStanza(stateElement);

    String? messageStatus = marker.name;

    if ('markable' == messageStatus) {
      return false;
    }

    String messageId = marker.getMessageId();
    String? dialogId = getDialogIdFromExtraParams(stanza);

    Jid? from = stanza.fromJid;

    if (from == null) return false;

    int userId = getUserIdFromJid(from);

    if ('received' == messageStatus) {
      _deliveredStreamController
          .add(CubeMessageStatus(userId, messageId, dialogId));
      return true;
    } else if ('displayed' == messageStatus) {
      _readStreamController.add(CubeMessageStatus(userId, messageId, dialogId));
      return true;
    }

    return false;
  }

  bool _isEditedStatus(MessageStanza stanza, XmppElement stateElement) {
    if (stateElement.name != EditMessageElement.ELEMENT_NAME) return false;

    EditMessageElement editedElement =
        EditMessageElement.fromStanza(stateElement);

    String messageId = editedElement.id;
    String? dialogId = getDialogIdFromExtraParams(stanza);

    Jid? from = stanza.fromJid;

    if (from == null) return false;

    int userId = -1;
    if (stanza.type == MessageStanzaType.CHAT) {
      userId = getUserIdFromJid(from);
    } else if (stanza.type == MessageStanzaType.GROUPCHAT) {
      userId = getUserIdFromGroupChatJid(from);
    }

    String updatedBody = stanza.body ?? '';

    _editStreamController
        .add(EditedMessageStatus(userId, messageId, dialogId, updatedBody));
    return true;
  }

  bool _isDeletedStatus(MessageStanza stanza, XmppElement stateElement) {
    if (stateElement.name != RemoveMessageElement.ELEMENT_NAME) return false;

    RemoveMessageElement removedElement =
        RemoveMessageElement.fromStanza(stateElement);

    String messageId = removedElement.id;
    String? dialogId = getDialogIdFromExtraParams(stanza);

    Jid? from = stanza.fromJid;

    if (from == null) return false;

    int userId = -1;
    if (stanza.type == MessageStanzaType.CHAT) {
      userId = getUserIdFromJid(from);
    } else if (stanza.type == MessageStanzaType.GROUPCHAT) {
      userId = getUserIdFromGroupChatJid(from);
    }

    _deleteStreamController.add(CubeMessageStatus(userId, messageId, dialogId));

    return true;
  }

  @override
  void closeStreams() {
    _deliveredStreamController.close();
    _readStreamController.close();
    _editStreamController.close();
    _deleteStreamController.close();
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }
}
