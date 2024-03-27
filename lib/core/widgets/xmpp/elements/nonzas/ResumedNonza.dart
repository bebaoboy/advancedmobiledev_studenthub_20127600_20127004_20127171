

import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/nonzas/Nonza.dart';

class ResumedNonza extends Nonza {
  static String NAME = 'resumed';
  static String XMLNS = 'urn:xmpp:sm:3';

  static bool match(Nonza nonza) =>
      (nonza.name == NAME && nonza.getAttribute('xmlns')!.value == XMLNS);

  ResumedNonza() {
    name = NAME;
    addAttribute(XmppAttribute('xmlns', XMLNS));
  }
}