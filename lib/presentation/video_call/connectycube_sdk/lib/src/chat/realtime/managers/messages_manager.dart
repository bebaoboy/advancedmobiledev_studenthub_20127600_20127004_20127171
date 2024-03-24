import 'package:xmpp_stone/xmpp_stone.dart';

import 'base_managers.dart';

abstract class MessagesManager extends Manager implements StreamedManager {
  MessagesManager(Connection chatConnection) : super(chatConnection);

  bool acceptMessage(MessageStanza messageStanza);
}
