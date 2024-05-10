import 'package:boilerplate/core/widgets/xmpp/elements/XmppAttribute.dart';
import 'package:boilerplate/core/widgets/xmpp/elements/nonzas/Nonza.dart';

class ANonza extends Nonza {
  static String NAME = 'a';
  static String XMLNS = 'urn:xmpp:sm:3';

  static bool match(Nonza nonza) =>
      (nonza.name == NAME && nonza.getAttribute('xmlns')!.value == XMLNS);

  ANonza(int hValue) {
    name = NAME;
    addAttribute(XmppAttribute('xmlns', XMLNS));
    addAttribute(XmppAttribute('h', hValue.toString()));
  }
}
