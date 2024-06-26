import 'dart:async';

import 'package:boilerplate/core/widgets/xmpp/Connection.dart';
import 'package:boilerplate/core/widgets/xmpp/chat/Message.dart';
import 'package:boilerplate/core/widgets/xmpp/data/Jid.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppElement.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/AbstractStanza.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/MessageStanza.dart';

class ChatImpl implements Chat {
  static String TAG = 'Chat';

  final Connection _connection;
  final Jid _jid;

  @override
  Jid get jid => _jid;
  ChatState? _myState;
  @override
  ChatState? get myState => _myState;

  ChatState? _remoteState;
  @override
  ChatState? get remoteState => _remoteState;

  @override
  List<StanzaMessage>? messages = [];

  final StreamController<StanzaMessage> _newMessageController =
      StreamController.broadcast();
  final StreamController<ChatState?> _remoteStateController =
      StreamController.broadcast();

  @override
  Stream<StanzaMessage> get newMessageStream => _newMessageController.stream;
  @override
  Stream<ChatState?> get remoteStateStream => _remoteStateController.stream;

  ChatImpl(this._jid, this._connection);

  void parseMessage(StanzaMessage message) {
    if (message.type == MessageStanzaType.CHAT) {
      if (message.text != null && message.text!.isNotEmpty) {
        messages!.add(message);
        _newMessageController.add(message);
      }

      if (message.chatState != null && !(message.isDelayed ?? false)) {
        _remoteState = message.chatState;
        _remoteStateController.add(message.chatState);
      }
    }
  }

  @override
  void sendMessage(String text) {
    var stanza =
        MessageStanza(AbstractStanza.getRandomId(), MessageStanzaType.CHAT);
    stanza.toJid = _jid;
    stanza.fromJid = _connection.fullJid;
    stanza.body = text;
    var message = StanzaMessage.fromStanza(stanza);
    messages!.add(message);
    _newMessageController.add(message);
    _connection.writeStanza(stanza);
  }

  @override
  set myState(ChatState? state) {
    var stanza =
        MessageStanza(AbstractStanza.getRandomId(), MessageStanzaType.CHAT);
    stanza.toJid = _jid;
    stanza.fromJid = _connection.fullJid;
    var stateElement = XmppElement();
    stateElement.name = state.toString().split('.').last.toLowerCase();
    stateElement.addAttribute(
        XmppAttribute('xmlns', 'http://jabber.org/protocol/chatstates'));
    stanza.addChild(stateElement);
    _connection.writeStanza(stanza);
    _myState = state;
  }
}

abstract class Chat {
  Jid get jid;
  ChatState? get myState;
  ChatState? get remoteState;
  Stream<StanzaMessage> get newMessageStream;
  Stream<ChatState?> get remoteStateStream;
  List<StanzaMessage>? messages;
  void sendMessage(String text);
  set myState(ChatState? state);
}

enum ChatState { INACTIVE, ACTIVE, GONE, COMPOSING, PAUSED }
