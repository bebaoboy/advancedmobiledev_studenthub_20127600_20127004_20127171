import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:boilerplate/core/widgets/xmpp/Connection.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/XmppElement.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/nonzas/Nonza.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/AbstractStanza.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/IqStanza.dart';
import 'package:boilerplate/core/widgets/xmpp/features/Negotiator.dart';

class SessionInitiationNegotiator extends Negotiator {
  final Connection _connection;
  StreamSubscription<AbstractStanza?>? subscription;

  IqStanza? sentRequest;

  SessionInitiationNegotiator(this._connection) {
    expectedName = 'SessionInitiationNegotiator';
  }
  @override
  List<Nonza> match(List<Nonza> requests) {
    var nonza =
        requests.firstWhereOrNull((request) => request.name == 'session');
    return nonza != null ? [nonza] : [];
  }

  @override
  void negotiate(List<Nonza> nonzas) {
    if (match(nonzas).isNotEmpty) {
      state = NegotiatorState.NEGOTIATING;
      subscription = _connection.inStanzasStream.listen(parseStanza);
      sendSessionInitiationStanza();
    }
  }

  void parseStanza(AbstractStanza? stanza) {
    if (stanza is IqStanza) {
      var idValue = stanza.getAttribute('id')?.value;
      if (idValue != null &&
          idValue == sentRequest?.getAttribute('id')?.value) {
        _connection.sessionReady();
        state = NegotiatorState.DONE;
      }
    }
  }

  void sendSessionInitiationStanza() {
    var stanza = IqStanza(AbstractStanza.getRandomId(), IqStanzaType.SET);
    var sessionElement = XmppElement();
    sessionElement.name = 'session';
    var attribute =
        XmppAttribute('xmlns', 'urn:ietf:params:xml:ns:xmpp-session');
    sessionElement.addAttribute(attribute);
    stanza.toJid = _connection.serverName;
    stanza.addChild(sessionElement);
    sentRequest = stanza;
    _connection.writeStanza(stanza);
  }
}
