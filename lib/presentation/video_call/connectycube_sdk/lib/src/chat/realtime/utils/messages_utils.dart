import 'package:collection/collection.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

import 'chat_constants.dart';
import '../extentions.dart';

bool isSystemNotification(MessageStanza message) {
  XmppElement? extraParams = message.getChild(ExtraParamsElement.ELEMENT_NAME);
  if (extraParams == null) return false;

  ExtraParamsElement extension = ExtraParamsElement.fromStanza(extraParams);

  Map<String, String> properties = extension.getParams();

  String? moduleIdentifier = properties[MODULE_IDENTIFIER];
  if (moduleIdentifier != null &&
      moduleIdentifier == MODULE_SYSTEM_NOTIFICATIONS) {
    return true;
  }

  return false;
}

bool isCallNotification(MessageStanza message) {
  XmppElement? extraParams = message.getChild(ExtraParamsElement.ELEMENT_NAME);
  if (extraParams == null) return false;

  ExtraParamsElement extension = ExtraParamsElement.fromStanza(extraParams);

  Map<String, String> properties = extension.getParams();

  String? moduleIdentifier = properties[MODULE_IDENTIFIER];
  if (MODULE_CALL_NOTIFICATIONS == moduleIdentifier) {
    return true;
  }

  return false;
}

ChatState stateFromString(String chatStateString) {
  switch (chatStateString) {
    case "inactive":
      return ChatState.INACTIVE;
    case "active":
      return ChatState.ACTIVE;
    case "gone":
      return ChatState.GONE;
    case "composing":
      return ChatState.COMPOSING;
    case "paused":
      return ChatState.PAUSED;
  }
  return ChatState.INACTIVE;
}

String? getDialogIdFromExtraParams(XmppElement stanza) {
  String? dialogId;
  XmppElement? extraParamsElement =
      stanza.getChild(ExtraParamsElement.ELEMENT_NAME);
  if (extraParamsElement != null) {
    ExtraParamsElement extraParams =
        ExtraParamsElement.fromStanza(extraParamsElement);
    dialogId = extraParams.getParams()['dialog_id'];
  }

  return dialogId;
}

MessageStanza unwrapCarbonMessage(MessageStanza stanza) {
  var carbon = stanza.children.firstWhereOrNull(
      (element) => (element.name == 'sent' || element.name == 'received'));

  if (carbon == null) return stanza;

  var forwarded = carbon.getChild('forwarded');
  if (forwarded != null) {
    var messageElement = forwarded.getChild('message');
    if (messageElement != null) return parseMessageStanza(messageElement);
  }

  return stanza;
}

MessageStanza parseMessageStanza(XmppElement messageElement) {
  var typeAttribute = messageElement.getAttribute('type');
  MessageStanzaType? type;
  if (typeAttribute != null && typeAttribute.value != null) {
    switch (typeAttribute.value) {
      case 'chat':
        type = MessageStanzaType.CHAT;
        break;
      case 'error':
        type = MessageStanzaType.ERROR;
        break;
      case 'groupchat':
        type = MessageStanzaType.GROUPCHAT;
        break;
      case 'headline':
        type = MessageStanzaType.HEADLINE;
        break;
      case 'normal':
        type = MessageStanzaType.NORMAL;
        break;
    }
  }

  var id = messageElement.getAttribute('id')?.value;

  var stanza = MessageStanza(id, type);

  var toAttribute = messageElement.getAttribute('to')?.value;
  if (toAttribute != null && toAttribute.isNotEmpty) {
    stanza.toJid = Jid.fromFullJid(toAttribute);
  }

  var fromAttribute = messageElement.getAttribute('from')?.value;
  if (fromAttribute != null && fromAttribute.isNotEmpty) {
    stanza.fromJid = Jid.fromFullJid(fromAttribute);
  }

  messageElement.attributes.forEach((xmppAttribute) {
    stanza.addAttribute(xmppAttribute);
  });

  messageElement.children.forEach((child) {
    stanza.addChild(child);
  });

  return stanza;
}
