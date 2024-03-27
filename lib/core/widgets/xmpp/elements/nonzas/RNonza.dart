import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/nonzas/Nonza.dart';

class RNonza extends Nonza {
  static String NAME = 'r';
  static String XMLNS = 'urn:xmpp:sm:3';

  static bool match(Nonza nonza) =>
      (nonza.name == NAME && nonza.getAttribute('xmlns')!.value == XMLNS);

  RNonza() {
    name = NAME;
    addAttribute(XmppAttribute('xmlns', XMLNS));
  }
}
