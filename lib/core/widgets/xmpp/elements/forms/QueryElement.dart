

import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppElement.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/forms/XElement.dart';

class QueryElement extends XmppElement{
  QueryElement() {
    name = 'query';
  }

  void addX(XElement xElement) {
    addChild(xElement);
  }

  void setXmlns(String xmlns) {
    addAttribute(XmppAttribute('xmlns', xmlns));
  }

  void setQueryId(String queryId) {
    XmppAttribute('queryid', queryId);
  }

  String? get queryId => getAttribute('queryid')?.value;
}