import 'package:xmpp_stone/xmpp_stone.dart';

import '../models/cube_message.dart';
import 'utils/jid_utils.dart';
import 'utils/messages_utils.dart';

// use single line stanza to avoid cross-platform conflicts
class CubeMessageStanza extends MessageStanza {
  CubeMessageStanza(id, type) : super(id, type);

  @override
  String buildXmlString() {
    return buildXml().toXmlString(pretty: false);
  }
}

class CubeXmppElementBase extends XmppElement {
  @override
  String buildXmlString() {
    String string = buildXml().toXmlString(pretty: false);
    return string;
  }
}

abstract class CubeXmppElement extends CubeXmppElementBase {
  get elementName;

  get nameSpace;

  CubeXmppElement() {
    addAttribute(XmppAttribute('xmlns', nameSpace));
  }

  @override
  get name => elementName;

  @override
  String getNameSpace() => nameSpace;
}

class ExtraParamsElement extends CubeXmppElement {
  static const String ELEMENT_NAME = 'extraParams';
  static const String NAME_SPACE = 'jabber:client';

  ExtraParamsElement.fromStanza(XmppElement stanza) {
    stanza.attributes.forEach((attribute) => addAttribute(attribute));
    stanza.children.forEach((child) => addChild(child));
  }

  ExtraParamsElement() : super();

  void addParam(String name, String? value) {
    XmppElement customParam = XmppElement();
    customParam.name = name;
    customParam.textValue = value == null ? "" : value;

    children.add(customParam);
  }

  void addParams(Map<String, String> params) {
    params.forEach((key, value) => addParam(key, value));
  }

  Map<String, String> getParams() {
    Map<String, String> params = Map();

    children.forEach((xmppElement) {
      if (xmppElement.name != AttachmentElement.ELEMENT_NAME) {
        if (xmppElement.name != null)
          params[xmppElement.name!] = xmppElement.textValue ?? '';
      }
    });

    return params;
  }

  List<CubeAttachment> getAttachments() {
    return children
        .where(
            (xmppElement) => AttachmentElement.ELEMENT_NAME == xmppElement.name)
        .map((xmppElement) {
      AttachmentElement attachmentElement =
          AttachmentElement.fromStanza(xmppElement);
      return attachmentElement.toAttachment();
    }).toList();
  }

  @override
  get elementName => ELEMENT_NAME;

  @override
  get nameSpace => NAME_SPACE;
}

class AttachmentElement extends XmppElement {
  static const String ELEMENT_NAME = 'attachment';

  @override
  get name => ELEMENT_NAME;

  AttachmentElement.fromStanza(XmppElement stanza) {
    stanza.attributes.forEach((attribute) => addAttribute(attribute));
    stanza.children.forEach((child) => addChild(child));
  }

  AttachmentElement.fromAttachment(CubeAttachment attachment) {
    attachment.toJson().forEach((key, value) {
      if (value != null) {
        if (key == 'data') {
          value = Uri.encodeComponent(value);
        }
        addAttribute(XmppAttribute(key, value.toString()));
      }
    });
  }

  CubeAttachment toAttachment() {
    Map<String, dynamic> attachmentAttributes = Map();

    attributes.forEach((attribute) {
      String name = attribute.name;
      String? stringValue = attribute.value;

      dynamic value;

      switch (name) {
        case 'data':
          if (stringValue != null) {
            value = Uri.decodeComponent(stringValue);
          } else {
            value = null;
          }
          break;
        default:
          value = stringValue;
      }
      attachmentAttributes[name] = value;
    });

    return CubeAttachment.fromJson(attachmentAttributes);
  }
}

class SelfDestroyElement extends CubeXmppElement {
  static const String ELEMENT_NAME = 'destroy';
  static const String NAME_SPACE = 'urn:xmpp:message-destroy-after:0';

  int? _after;

  SelfDestroyElement(int destroyAfter) {
    addAttribute(XmppAttribute('after', destroyAfter.toString()));
  }

  SelfDestroyElement.fromStanza(XmppElement stanza) {
    this._after = int.parse(stanza.getAttribute('after')!.value!);
  }

  get after => _after;

  @override
  get elementName => ELEMENT_NAME;

  @override
  get nameSpace => NAME_SPACE;
}

class RemoveMessageElement extends CubeXmppElement {
  static const String ELEMENT_NAME = 'remove';
  static const String NAME_SPACE = 'urn:xmpp:message-delete:0';

  String? _id;

  String get id => _id ?? '';

  RemoveMessageElement(String originalMsgId) {
    addAttribute(XmppAttribute('id', originalMsgId));
  }

  RemoveMessageElement.fromStanza(XmppElement stanza) {
    stanza.attributes.forEach((attribute) {
      if (attribute.name == 'id') {
        _id = attribute.value;
      }

      addAttribute(attribute);
    });
    stanza.children.forEach((child) => addChild(child));
  }

  @override
  get elementName => ELEMENT_NAME;

  @override
  get nameSpace => NAME_SPACE;
}

class EditMessageElement extends CubeXmppElement {
  static const String ELEMENT_NAME = 'replace';
  static const String NAME_SPACE = 'urn:xmpp:message-correct:0';

  bool? _isLast;
  String? _id;

  bool get isLast => _isLast ?? false;

  String get id => _id ?? '';

  EditMessageElement(String originalMsgId, bool isLastMessage) {
    addAttribute(XmppAttribute('id', originalMsgId));
    addAttribute(XmppAttribute('last', isLastMessage.toString()));
  }

  EditMessageElement.fromStanza(XmppElement stanza) {
    stanza.attributes.forEach((attribute) {
      if (attribute.name == 'last') {
        _isLast = bool.fromEnvironment(attribute.value!);
      } else if (attribute.name == 'id') {
        _id = attribute.value;
      }

      addAttribute(attribute);
    });
    stanza.children.forEach((child) => addChild(child));
  }

  @override
  get elementName => ELEMENT_NAME;

  @override
  get nameSpace => NAME_SPACE;
}

class JoinPresenceStanza extends AbstractStanza {
  JoinPresenceStanza(String dialogId, int currentUserId) {
    id = AbstractStanza.getRandomId();

    children.add(JoinXElement());

    toJid = Jid.fromFullJid("${getJidForGroupChat(dialogId)}/$currentUserId");
  }

  @override
  set toJid(Jid? value) {
    super.toJid = value;
    if (value != null) {
      addAttribute(XmppAttribute('to', value.fullJid));
    }
  }

  @override
  get name => 'presence';
}

class LeavePresenceStanza extends AbstractStanza {
  LeavePresenceStanza(String dialogId, int currentUserId) {
    id = AbstractStanza.getRandomId();
    addAttribute(XmppAttribute("type", "unavailable"));

    toJid = Jid.fromFullJid("${getJidForGroupChat(dialogId)}/$currentUserId");
  }

  @override
  set toJid(Jid? value) {
    super.toJid = value;
    if (value != null) {
      addAttribute(XmppAttribute('to', value.fullJid));
    }
  }

  @override
  get name => 'presence';
}

class JoinXElement extends CubeXmppElement {
  static const String ELEMENT_NAME = 'x';
  static const String NAME_SPACE = 'http://jabber.org/protocol/muc';

  @override
  get elementName => ELEMENT_NAME;

  @override
  get nameSpace => NAME_SPACE;
}

class MessageMarkerElement extends CubeXmppElement {
  static const String NAME_SPACE = 'urn:xmpp:chat-markers:0';
  String? _markerName;
  String? _id;

  MessageMarkerElement.fromStanza(XmppElement stanza) {
    _markerName = stanza.name!;
    stanza.attributes.forEach((attribute) => addAttribute(attribute));
    stanza.children.forEach((child) => addChild(child));
  }

  MessageMarkerElement(this._markerName, [this._id]) : super() {
    if (_id != null) {
      addAttribute(XmppAttribute('id', _id));
    }
  }

  String getMessageId() {
    return getAttribute('id')!.value!;
  }

  @override
  get elementName => _markerName;

  @override
  get nameSpace => NAME_SPACE;

  @override
  get name => elementName;
}

class ChatStateElement extends CubeXmppElement {
  static const String NAME_SPACE = 'http://jabber.org/protocol/chatstates';
  ChatState? state;

  ChatStateElement.fromStanza(XmppElement stanza) {
    state = stateFromString(stanza.name!);
    stanza.attributes.forEach((attribute) => addAttribute(attribute));
    stanza.children.forEach((child) => addChild(child));
  }

  ChatStateElement(this.state) : super();

  @override
  get elementName => state.toString().split('.').last.toLowerCase();

  @override
  get nameSpace => NAME_SPACE;

  @override
  get name => elementName;
}

class LastActivityQuery extends CubeXmppElement {
  static const String ELEMENT_NAME = 'query';
  static const String NAME_SPACE = 'jabber:iq:last';

  LastActivityQuery.fromStanza(XmppElement stanza) {
    stanza.attributes.forEach((attribute) => addAttribute(attribute));
    stanza.children.forEach((child) => addChild(child));
  }

  LastActivityQuery() : super();

  int getSeconds() {
    return int.parse(getAttribute('seconds')?.value ?? '-1');
  }

  @override
  get elementName => ELEMENT_NAME;

  @override
  get nameSpace => NAME_SPACE;
}

class EnableMobileElement extends CubeXmppElement {
  static const String ELEMENT_NAME = 'mobile';
  static const String NAME_SPACE = 'http://tigase.org/protocol/mobile#v2';
  bool _enable = false;

  EnableMobileElement.fromStanza(XmppElement stanza) {
    this._enable =
        bool.fromEnvironment(stanza.getAttribute('enable')?.value ?? "false");
  }

  EnableMobileElement(this._enable) : super() {
    addAttribute(XmppAttribute('enable', _enable.toString()));
  }

  bool get isEnable => _enable;

  @override
  get elementName => ELEMENT_NAME;

  @override
  get nameSpace => NAME_SPACE;
}

class SubscribeLastActivityElement extends CubeXmppElement {
  static const String ELEMENT_NAME = 'subscribe';
  static const String NAME_SPACE =
      'https://connectycube.com/protocol/status_streaming';

  SubscribeLastActivityElement(int userId, bool enable) : super() {
    addAttribute(XmppAttribute('user_jid', getJidForUser(userId)));
    addAttribute(XmppAttribute('enable', enable.toString()));
  }

  @override
  get elementName => ELEMENT_NAME;

  @override
  get nameSpace => NAME_SPACE;
}

class ReactionsElement extends XmppElement {
  static const String ELEMENT_NAME = 'reactions';

  @override
  get name => ELEMENT_NAME;

  late int userId;
  late String messageId;
  String? addReaction;
  String? removeReaction;

  ReactionsElement.fromStanza(XmppElement stanza) {
    this.userId =
        int.tryParse(stanza.getAttribute('user_id')?.value ?? '') ?? -1;
    this.messageId = stanza.getAttribute('message_id')?.value ?? '';

    stanza.children.forEach((child) {
      child.attributes.forEach((attribute) {
        if (attribute.name == 'add') {
          addReaction = child.getAttribute('type')?.value;
        } else if (attribute.name == 'remove') {
          removeReaction = child.getAttribute('type')?.value;
        }
      });
    });
  }
}
