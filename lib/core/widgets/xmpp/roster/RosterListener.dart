import 'package:boilerplate/core/widgets/xmpp/roster/Buddy.dart';

abstract class RosterListener {
  void onRosterListChanged(List<Buddy> roster);
}
