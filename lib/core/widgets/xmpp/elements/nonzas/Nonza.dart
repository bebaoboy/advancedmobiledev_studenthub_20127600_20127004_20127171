import 'package:boilerplate/core/widgets/xmpp/data/Jid.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppElement.dart';
import 'package:boilerplate/core/widgets/xmpp/parser/StanzaParser.dart';
import 'package:xml/xml.dart' as xml;

class Nonza extends XmppElement {
  Jid? _fromJid;
  Jid? _toJid;

  Jid? get fromJid => _fromJid;

  set fromJid(Jid? value) {
    _fromJid = value;
    addAttribute(XmppAttribute('from', _fromJid!.fullJid));
  }

  Jid? get toJid => _toJid;

  set toJid(Jid? value) {
    _toJid = value;
    addAttribute(XmppAttribute('to', _toJid!.userAtDomain));
  }

  static Nonza parse(xml.XmlElement xmlElement) {
    var nonza = Nonza();
    nonza.name = xmlElement.name.local;

    var fromString = xmlElement.getAttribute('from');
    if (fromString != null) {
      var from = Jid.fromFullJid(fromString);
      nonza.fromJid = from;
    }
    var toString = xmlElement.getAttribute('to');
    if (toString != null) {
      var to = Jid.fromFullJid(toString);
      nonza.toJid = to;
    }
    for (var attribute in xmlElement.attributes) {
      nonza
        .addAttribute(XmppAttribute(attribute.name.local, attribute.value));
    }
    for (var xmlChild in xmlElement.children) {
      if (xmlChild is xml.XmlElement) {
        nonza.addChild(StanzaParser.parseElement(xmlChild));
      } else if (xmlChild is xml.XmlText) {
        nonza.textValue = xmlChild.value;
      }
    }
    return nonza;
  }
}
