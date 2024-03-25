import 'package:boilerplate/core/widgets/xmpp/xmpp_stone.dart';

import 'base_managers.dart';

abstract class MessagesManager extends Manager implements StreamedManager {
  MessagesManager(super.chatConnection);

  bool acceptMessage(MessageStanza messageStanza);
}
