import 'dart:async';

import 'package:xmpp_stone/xmpp_stone.dart';

import '../../../../connectycube_core.dart';

import 'base_managers.dart';
import '../utils/jid_utils.dart';
import '../../chat_connection_service.dart';
import '../../models/cube_error_packet.dart';
import '../../models/cube_message.dart';
import '../extentions.dart';

class PrivateChatManager extends BaseChatManager<PrivateChat>
    implements StreamedManager {
  static Map<Connection, PrivateChatManager> _instances = Map();
  static Map<int, PrivateChat> _chatsMap = Map();

  StreamController<PrivateChat> _chatListStreamController =
      StreamController.broadcast();

  Stream<PrivateChat> get chatListStream => _chatListStreamController.stream;

  late ChatManager _chatManager;

  PrivateChatManager._private(Connection connection)
      : super._private(connection) {
    _chatManager = ChatManager.getInstance(connection);
    _chatManager.chats.forEach((chat) {
      _chatsMap[getUserIdFromJid(chat.jid)] = PrivateChat.fromChat(chat, this);
    });
    _chatManager.chatListStream.listen((chats) {
      chats.where((chat) {
        return !_chatsMap.containsKey(chat.jid);
      }).forEach((chat) {
        _chatsMap[getUserIdFromJid(chat.jid)] =
            PrivateChat.fromChat(chat, this);
      });
    });
  }

  static PrivateChatManager getInstance(Connection connection) {
    PrivateChatManager? manager = _instances[connection];
    if (manager == null) {
      manager = PrivateChatManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  void processIncomingPacket(MessageStanza event) {
    log("processIncomingPacket $event");

    Jid? senderJid = event.fromJid;
    if (senderJid != null) {
      int userId = getUserIdFromJid(senderJid);
      getChat(userId).processIncomingMessage(event);
    }
  }

  @override
  Future<CubeMessage> sendMessageInternal(
      CubeMessage message, PrivateChat chat) {
    Completer<CubeMessage> completer = Completer();

    CubeMessageStanza stanza = message.toStanza(MessageStanzaType.CHAT);
    stanza.toJid = Jid.fromFullJid(getJidForUser(chat._participantId));

    connection.writeStanza(stanza);

    completer.complete(message);

    return completer.future;
  }

  void sendChatState(ChatState state, int userId) {
    Jid toJid = Jid.fromFullJid(getJidForUser(userId));
    _sendChatState(state, MessageStanzaType.CHAT, toJid);
  }

  PrivateChat getChat(int participantId) {
    if (_chatsMap.containsKey(participantId)) {
      return _chatsMap[participantId]!;
    } else {
      return createChat(participantId);
    }
  }

  PrivateChat createChat(int participantId) {
    Chat chat =
        _chatManager.getChat(Jid.fromFullJid(getJidForUser(participantId)));
    PrivateChat cubeChat = PrivateChat.fromChat(chat, this);

    return cubeChat;
  }

  void chatListUpdated(List<Chat> newChatsList) {
    for (Chat chat in newChatsList) {
      int userId = getUserIdFromJid(chat.jid);
      if (!_chatsMap.containsKey(userId)) {
        PrivateChat cubeChat = PrivateChat.fromChat(chat, this);
        _chatsMap[userId] = cubeChat;
        _chatListStreamController.add(cubeChat);
        chat.newMessageStream
            .listen((event) => processIncomingPacket(event.messageStanza));
      }
    }
  }

  @override
  void closeStreams() {
    _chatListStreamController.close();
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }
}

class GroupChatManager extends BaseChatManager<GroupChat>
    implements StreamedManager {
  static Map<Connection?, GroupChatManager> _instances = Map();
  static Map<String?, GroupChat> _chatsMap = Map();

  StreamController<GroupChat> _chatListStreamController =
      StreamController.broadcast();

  Stream<GroupChat> get chatListStream => _chatListStreamController.stream;

  GroupChatManager._private(Connection connection)
      : super._private(connection) {
    connection.inStanzasStream
        .where((abstractStanza) => abstractStanza is MessageStanza)
        .map((stanza) => stanza as MessageStanza)
        .where((stanza) => MessageStanzaType.GROUPCHAT == stanza.type)
        .listen((stanza) {});
  }

  static GroupChatManager getInstance(Connection connection) {
    GroupChatManager? manager = _instances[connection];
    if (manager == null) {
      manager = GroupChatManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  GroupChat getChat(String? dialogId) {
    return _getChat(dialogId);
  }

  GroupChat _getChat(String? dialogId) {
    GroupChat? chat = _chatsMap[dialogId];
    if (chat == null) {
      chat = GroupChat(this, dialogId);
      _chatsMap[dialogId] = chat;
    }
    return chat;
  }

  @override
  Future<CubeMessage> sendMessageInternal(CubeMessage message, GroupChat chat) {
    Completer<CubeMessage> completer = Completer();

    CubeMessageStanza stanza = message.toStanza(MessageStanzaType.GROUPCHAT);
    stanza.toJid = Jid.fromFullJid(getJidForGroupChat(chat._dialogId!));

    CubeChatConnection.instance.asyncStanzaSender?.sendAsync(stanza,
        (resultStanza, exception) {
      if (resultStanza == null) {
        completer.completeError(exception);
      } else {
        completer.complete(CubeMessage.fromStanza(resultStanza));
      }
    });

    return completer.future;
  }

  void sendChatState(ChatState state, String dialogId) {
    Jid toJid = Jid.fromFullJid(getJidForGroupChat(dialogId));
    _sendChatState(state, MessageStanzaType.GROUPCHAT, toJid);
  }

  Future<GroupChat> join(GroupChat groupChat) {
    Completer<GroupChat> completer = Completer();

    JoinPresenceStanza joinStanza = JoinPresenceStanza(
        groupChat._dialogId!, CubeChatConnection.instance.currentUser!.id!);

    CubeChatConnection.instance.asyncStanzaSender?.sendAsync(joinStanza,
        (resultStanza, exception) {
      if (resultStanza == null) {
        completer.completeError(exception);
      } else {
        completer.complete(groupChat);
      }
    });

    return completer.future;
  }

  Future<GroupChat> leave(GroupChat groupChat) {
    Completer<GroupChat> completer = Completer();

    LeavePresenceStanza leaveStanza = LeavePresenceStanza(
        groupChat._dialogId!, CubeChatConnection.instance.currentUser!.id!);

    CubeChatConnection.instance.asyncStanzaSender?.sendAsync(leaveStanza,
        (resultStanza, exception) {
      if (resultStanza == null) {
        completer.completeError(exception);
      } else {
        completer.complete(groupChat);
      }
    });

    return completer.future;
  }

  @override
  void closeStreams() {
    _chatListStreamController.close();
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }
}

abstract class BaseChatManager<CH extends AbstractChat> extends Manager {
  BaseChatManager._private(Connection chatConnection) : super(chatConnection);

  Future<CubeMessage> sendMessageInternal(CubeMessage chatMessage, CH chat);

  Future<CubeMessage> sendMessage(CubeMessage message, CH chat) {
    return sendMessageInternal(message, chat);
  }

  Future<void> sendMessageStatus(String status, CubeMessage originalMessage) {
    return updateMessageStatus(connection, status, originalMessage);
  }

  Future<void> _sendChatState(
      ChatState state, MessageStanzaType chatType, Jid toJid) {
    Completer completer = Completer();

    String stanzaId = AbstractStanza.getRandomId();
    CubeMessageStanza statusMessage = CubeMessageStanza(stanzaId, chatType);
    statusMessage.addChild(ChatStateElement(state));
    statusMessage.toJid = toJid;

    connection.writeStanza(statusMessage);

    completer.complete();

    return completer.future;
  }

  Future<void> sendEditMessageStatus(CubeMessage originalMessage, bool isLast,
      Jid toJid, MessageStanzaType chatType) {
    Completer completer = Completer();

    String? body = originalMessage.body;
    String? messageId = originalMessage.messageId;
    String? dialogId = originalMessage.dialogId;

    if (isEmpty(body) || isEmpty(messageId) || isEmpty(dialogId)) {
      completer.completeError(IllegalArgumentException(
          "To edit message original message should contains updated body, 'messageId' and 'dialogId'"));
      return completer.future;
    }

    String stanzaId = AbstractStanza.getRandomId();

    ExtraParamsElement extraParams = ExtraParamsElement();
    extraParams.addParam('dialog_id', dialogId!);

    CubeMessageStanza statusMessage = CubeMessageStanza(stanzaId, chatType);
    statusMessage.toJid = toJid;
    statusMessage.body = body;
    statusMessage.addChild(EditMessageElement(messageId!, isLast));
    statusMessage.addChild(extraParams);

    connection.writeStanza(statusMessage);

    completer.complete();

    return completer.future;
  }

  Future<void> sendDeleteMessageStatus(
      CubeMessage originalMessage, Jid toJid, MessageStanzaType chatType) {
    Completer completer = Completer();

    String? messageId = originalMessage.messageId;
    String? dialogId = originalMessage.dialogId;

    if (isEmpty(messageId) || isEmpty(dialogId)) {
      completer.completeError(IllegalArgumentException(
          "To delete message original message should contains 'messageId' and 'dialogId'"));
      return completer.future;
    }

    String stanzaId = AbstractStanza.getRandomId();

    ExtraParamsElement extraParams = ExtraParamsElement();
    extraParams.addParam('dialog_id', dialogId!);

    CubeMessageStanza statusMessage = CubeMessageStanza(stanzaId, chatType);
    statusMessage.toJid = toJid;
    statusMessage.addChild(RemoveMessageElement(messageId!));
    statusMessage.addChild(extraParams);

    connection.writeStanza(statusMessage);

    completer.complete();

    return completer.future;
  }
}

class PrivateChat extends BaseCubeChat {
  PrivateChatManager _privateChatManager;
  late int _participantId;
  String? dialogId;

  PrivateChat(this._privateChatManager, this._participantId);

  PrivateChat.fromChat(Chat stoneChat, this._privateChatManager) {
    this._participantId = getUserIdFromJid(stoneChat.jid);
  }

  @override
  String? getDialogId() {
    return dialogId;
  }

  @override
  Future<void> deliverMessage(CubeMessage message) {
    return sendDeliveredStatus(_privateChatManager.connection, message);
  }

  @override
  Future<void> readMessage(CubeMessage message) {
    return sendReadStatus(_privateChatManager.connection, message);
  }

  @override
  void sendIsTypingNotification() {
    _privateChatManager.sendChatState(ChatState.COMPOSING, _participantId);
  }

  @override
  void sendStopTypingNotification() {
    _privateChatManager.sendChatState(ChatState.PAUSED, _participantId);
  }

  @override
  Future<CubeMessage> sendMessage(CubeMessage message) {
    return _privateChatManager.sendMessage(message, this);
  }

  void processIncomingMessage(MessageStanza messageStanza) {
    if (MessageStanzaType.ERROR == messageStanza.type) {
      _notifyErrorMessage(
          this, ErrorPacket.fromStanza(messageStanza.getChild('error')!));

      return;
    }

    CubeMessage cubeMessage = CubeMessage.fromStanza(messageStanza);
    if (cubeMessage.markable) {
      deliverMessage(cubeMessage);
    }

    _notifyIncomingMessage(this, cubeMessage);
  }

  @override
  Future<void> deleteMessage(CubeMessage message) {
    return _privateChatManager.sendDeleteMessageStatus(message,
        Jid.fromFullJid(getJidForUser(_participantId)), MessageStanzaType.CHAT);
  }

  @override
  Future<void> editMessage(CubeMessage message, bool isLast) {
    return _privateChatManager.sendEditMessageStatus(message, isLast,
        Jid.fromFullJid(getJidForUser(_participantId)), MessageStanzaType.CHAT);
  }
}

class GroupChat extends BaseCubeChat {
  GroupChatManager _groupChatManager;
  String? _dialogId;
  bool? isJoined;

  GroupChat(this._groupChatManager, this._dialogId);

  GroupChat.fromStanza(MessageStanza messageStanza, this._groupChatManager) {
    Jid? senderJid = messageStanza.fromJid;
    if (senderJid != null) {
      this._dialogId = getDialogIdFromGroupChatJid(senderJid);
    }
  }

  @override
  String? getDialogId() {
    return _dialogId;
  }

  @override
  Future<void> deliverMessage(CubeMessage message) {
    return sendDeliveredStatus(_groupChatManager.connection, message);
  }

  @override
  Future<void> readMessage(CubeMessage message) {
    return sendReadStatus(_groupChatManager.connection, message);
  }

  @override
  void sendIsTypingNotification() {
    _groupChatManager.sendChatState(ChatState.COMPOSING, _dialogId!);
  }

  @override
  void sendStopTypingNotification() {
    _groupChatManager.sendChatState(ChatState.PAUSED, _dialogId!);
  }

  @override
  Future<CubeMessage> sendMessage(CubeMessage message) {
    return _groupChatManager.sendMessage(message, this);
  }

  void processIncomingMessage(MessageStanza messageStanza) {
    if (MessageStanzaType.ERROR == messageStanza.type) {
      _notifyErrorMessage(
          this, ErrorPacket.fromStanza(messageStanza.getChild('error')!));

      return;
    }

    CubeMessage cubeMessage = CubeMessage.fromStanza(messageStanza);
    if (cubeMessage.markable) {
      deliverMessage(cubeMessage);
    }

    _notifyIncomingMessage(this, cubeMessage);
  }

  Future<GroupChat> join() {
    Completer<GroupChat> completer = Completer();
    if (isJoined == null || !isJoined!) {
      _groupChatManager.join(this).then((groupChat) {
        isJoined = true;
        completer.complete(groupChat);
      }).catchError((onError) {
        completer.completeError(onError);
      });
    } else {
      completer.complete(this);
    }

    return completer.future;
  }

  Future<void> leave() {
    Completer completer = Completer();
    if (isJoined != null && isJoined!) {
      _groupChatManager.leave(this).then((groupChat) {
        isJoined = false;
        completer.complete(groupChat);
      }).catchError((onError) {
        completer.completeError(onError);
      });
    } else {
      completer.complete(this);
    }

    return completer.future;
  }

  @override
  Future<void> deleteMessage(CubeMessage message) {
    return _groupChatManager.sendDeleteMessageStatus(
        message,
        Jid.fromFullJid(getJidForGroupChat(_dialogId!)),
        MessageStanzaType.GROUPCHAT);
  }

  @override
  Future<void> editMessage(CubeMessage message, bool isLast) {
    return _groupChatManager.sendEditMessageStatus(
        message,
        isLast,
        Jid.fromFullJid(getJidForGroupChat(_dialogId!)),
        MessageStanzaType.GROUPCHAT);
  }
}

abstract class BaseCubeChat implements AbstractChat {
  StreamController<CubeMessage> _chatMessagesStreamController =
      StreamController.broadcast();

//  @override
//  Stream<CubeMessage> get chatMessagesStream =>
//      _chatMessagesStreamController.stream;

  void _notifyErrorMessage(AbstractChat chat, ErrorPacket error) {
    log("notifyErrorMessage");
    _chatMessagesStreamController.addError(error);
  }

  void _notifyIncomingMessage(AbstractChat chat, CubeMessage cubeMessage) {
    log("notifyIncomingMessage");

    _chatMessagesStreamController.add(cubeMessage);
  }
}

abstract class AbstractChat {
  String? getDialogId();

//  Stream<CubeMessage> get chatMessagesStream;

  Future<void> readMessage(CubeMessage message);

  Future<void> deliverMessage(CubeMessage message);

  Future<void> deleteMessage(CubeMessage message);

  Future<void> editMessage(CubeMessage message, bool isLast);

  void sendIsTypingNotification();

  void sendStopTypingNotification();

  Future<CubeMessage> sendMessage(CubeMessage message);
}

Future<void> updateMessageStatus(
    Connection connection, String status, CubeMessage originalMessage) {
  Completer completer = Completer();

  int? senderId = originalMessage.senderId;
  String? messageId = originalMessage.messageId;
  String? dialogId = originalMessage.dialogId;

  if (senderId == null ||
      senderId == 0 ||
      isEmpty(messageId) ||
      isEmpty(dialogId)) {
    completer.completeError(IllegalArgumentException(
        "To update message status original message should contains 'senderId', 'messageId', 'dialogId'"));
    return completer.future;
  }

  String stanzaId = AbstractStanza.getRandomId();

  Jid toJid = Jid.fromFullJid(getJidForUser(senderId));

  ExtraParamsElement extraParams = ExtraParamsElement();
  extraParams.addParam('dialog_id', dialogId!);

  CubeMessageStanza statusMessage =
      CubeMessageStanza(stanzaId, MessageStanzaType.CHAT);
  statusMessage.addChild(MessageMarkerElement(status, messageId));
  statusMessage.toJid = toJid;
  statusMessage.addChild(extraParams);

  connection.writeStanza(statusMessage);

  completer.complete();

  return completer.future;
}

Future<void> sendDeliveredStatus(
    Connection connection, CubeMessage cubeMessage) {
  return updateMessageStatus(connection, 'received', cubeMessage);
}

Future<void> sendReadStatus(Connection connection, CubeMessage cubeMessage) {
  return updateMessageStatus(connection, 'displayed', cubeMessage);
}
