import 'package:boilerplate/core/widgets/xmpp/elements/nonzas/Nonza.dart';

class FailedNonza extends Nonza {
  static String NAME = 'failed';
  static String XMLNS = 'urn:xmpp:sm:3';

  static bool match(Nonza nonza) =>
      (nonza.name == NAME && nonza.getAttribute('xmlns')!.value == XMLNS);

  FailedNonza() {
    name = NAME;
  }
}
