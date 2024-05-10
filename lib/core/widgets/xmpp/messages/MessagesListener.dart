import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/MessageStanza.dart';

abstract class MessagesListener {
  void onNewMessage(MessageStanza? message);
}
