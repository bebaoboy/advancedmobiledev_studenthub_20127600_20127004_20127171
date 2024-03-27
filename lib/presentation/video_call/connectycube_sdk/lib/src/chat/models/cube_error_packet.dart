import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppElement.dart';

class ErrorPacket {
  String? type;
  int? code;
  Condition? condition;
  String? text;

  ErrorPacket.fromStanza(XmppElement error) {
    if (error.getAttribute("type") != null) {
      type = error.getAttribute("type")!.value;
    }

    XmppAttribute? errorCode = error.getAttribute("code");
    if (errorCode != null && errorCode.value != null) {
      code = int.parse(errorCode.value!);
    }

    for (XmppElement child in error.children) {
      if (child.name == "text") {
        text = child.textValue;
      } else {
        try {
          if (condition == null && child.name != null) {
            condition = toCondition(child.name!);
          }
        } catch (error) {}
      }
    }
  }

  @override
  String toString() {
    return "ErrorPacket: {"
        "type: $type, "
        "code: $code, "
        "condition: $condition, "
        "text: $text"
        "}";
  }
}

enum Condition {
  bad_request,
  conflict,
  feature_not_implemented,
  forbidden,
  gone,
  internal_server_error,
  item_not_found,
  jid_malformed,
  not_acceptable,
  not_allowed,
  not_authorized,
  policy_violation,
  recipient_unavailable,
  redirect,
  registration_required,
  remote_server_not_found,
  remote_server_timeout,
  resource_constraint,
  service_unavailable,
  subscription_required,
  undefined_condition,
  unexpected_request
}

String fromCondition(Condition condition) {
  return condition
      .toString()
      .split('.')
      .last
      .toLowerCase()
      .replaceAll('_', '-');
}

Condition toCondition(String stanzaCondition) {
  for (Condition condition in Condition.values) {
    if (condition.toString().split('.').last.toLowerCase() ==
        stanzaCondition.replaceAll('-', '_')) {
      return condition;
    }
  }

  throw Exception("Could not transform string '$stanzaCondition' to Condition");
}
