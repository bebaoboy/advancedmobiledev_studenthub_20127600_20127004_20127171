
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/AbstractStanza.dart';

abstract class StanzaProcessor {
  void processStanza(AbstractStanza stanza);
}
