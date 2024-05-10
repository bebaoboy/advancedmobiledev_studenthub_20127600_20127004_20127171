import 'package:boilerplate/core/widgets/xmpp/data/Jid.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppElement.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/forms/FieldElement.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/forms/XElement.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/AbstractStanza.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/MessageStanza.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/PresenceStanza.dart';
import 'package:boilerplate/core/widgets/xmpp/features/servicediscovery/Feature.dart';
import 'package:boilerplate/core/widgets/xmpp/features/servicediscovery/Identity.dart';
import 'package:boilerplate/core/widgets/xmpp/parser/IqParser.dart';
import 'package:xml/xml.dart' as xml;

import '../logger/Log.dart';

class StanzaParser {
  static const TAG = 'StanzaParser';

  //ToDO: Improve this!
  static AbstractStanza? parseStanza(xml.XmlElement element) {
    AbstractStanza? stanza;
    var id = element.getAttribute('id');
    if (id == null) {
      Log.d(TAG, 'No id found for stanza');
    }

    if (element.name.local == 'iq') {
      stanza = IqParser.parseIqStanza(id, element);
    } else if (element.name.local == 'message') {
      stanza = _parseMessageStanza(id, element);
    } else if (element.name.local == 'presence') {
      stanza = _parsePresenceStanza(id, element);
    }
    var fromString = element.getAttribute('from');
    if (fromString != null) {
      var from = Jid.fromFullJid(fromString);
      stanza!.fromJid = from;
    }
    var toString = element.getAttribute('to');
    if (toString != null) {
      var to = Jid.fromFullJid(toString);
      stanza!.toJid = to;
    }
    for (var xmlAttribute in element.attributes) {
      stanza!.addAttribute(
          XmppAttribute(xmlAttribute.name.local, xmlAttribute.value));
    }
    for (var child in element.children) {
      if (child is xml.XmlElement) stanza!.addChild(parseElement(child));
    }
    return stanza;
  }

  static MessageStanza _parseMessageStanza(String? id, xml.XmlElement element) {
    var typeString = element.getAttribute('type');
    MessageStanzaType? type;
    if (typeString == null) {
      Log.w(TAG, 'No type found for message stanza');
    } else {
      switch (typeString) {
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
    var stanza = MessageStanza(id, type);

    return stanza;
  }

  static PresenceStanza _parsePresenceStanza(
      String? id, xml.XmlElement element) {
    var presenceStanza = PresenceStanza();
    presenceStanza.id = id;
    return presenceStanza;
  }

  static XmppElement parseElement(xml.XmlElement xmlElement) {
    XmppElement xmppElement;
    var parentName = (xmlElement.parent as xml.XmlElement?)?.name.local ?? '';
    var name = xmlElement.name.local;
    if (parentName == 'query' && name == 'identity') {
      xmppElement = Identity();
    } else if (parentName == 'query' && name == 'feature') {
      xmppElement = Feature();
    } else if (name == 'x') {
      xmppElement = XElement();
    } else if (name == 'field') {
      xmppElement = FieldElement();
    } else {
      xmppElement = XmppElement();
    }
    xmppElement.name = xmlElement.name.local;
    for (var xmlAttribute in xmlElement.attributes) {
      xmppElement.addAttribute(
          XmppAttribute(xmlAttribute.name.local, xmlAttribute.value));
    }
    for (var xmlChild in xmlElement.children) {
      if (xmlChild is xml.XmlElement) {
        xmppElement.addChild(parseElement(xmlChild));
      } else if (xmlChild is xml.XmlText) {
        xmppElement.textValue = xmlChild.value;
      }
    }
    return xmppElement;
  }
}
