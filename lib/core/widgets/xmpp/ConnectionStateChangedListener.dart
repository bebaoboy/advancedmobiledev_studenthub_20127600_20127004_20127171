
import 'package:boilerplate/core/widgets/xmpp/Connection.dart';

abstract class ConnectionStateChangedListener {
  void onConnectionStateChanged(XmppConnectionState state);
}
