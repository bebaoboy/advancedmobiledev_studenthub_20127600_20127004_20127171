import 'package:xmpp_stone/xmpp_stone.dart';

import '../../../../connectycube_core.dart';

String getJidForUser(int userId, [String? resource]) {
  String? appId = CubeSettings.instance.applicationId;
  String? chatEndpoint = CubeSettings.instance.chatEndpoint;

  return "$userId-$appId@$chatEndpoint${!isEmpty(resource) ? "/$resource" : ""}";
}

String getJidForGroupChat(String dialogId) {
  String? appId = CubeSettings.instance.applicationId;
  String? chatEndpoint = CubeSettings.instance.chatEndpoint;

  return "$appId\_$dialogId@muc.$chatEndpoint";
}

int getUserIdFromJid(Jid jid) {
  return int.parse(jid.local.split('-')[0]);
}

int getUserIdFromJidString(String jid) {
  return int.parse(jid.split('-')[0]);
}

int getUserIdFromNickWithMucDomain(String nick) {
  return int.tryParse(nick.split('/').last) ?? -1;
}

String getUserNickWithMucDomain(int userId) {
  var mucEndpoint = 'muc.${CubeSettings.instance.chatEndpoint}';
  return '$mucEndpoint/$userId';
}

bool isGroupChatJid(Jid jid) {
  return jid.domain.contains("muc.");
}

int getUserIdFromGroupChatJid(Jid jid) {
  return int.parse(jid.resource!);
}

String getDialogIdFromGroupChatJid(Jid jid) {
  return jid.local.split('_')[1];
}
