import 'package:boilerplate/core/widgets/xmpp/xmpp_stone.dart' as xmpp;

import '../utils/jid_utils.dart';

import 'base_managers.dart';

class PrivacyListsManager extends Manager {
  static final Map<xmpp.Connection, PrivacyListsManager> _instances = {};

  PrivacyListsManager._private(super.connection);

  static getInstance(xmpp.Connection connection) {
    PrivacyListsManager? manager = _instances[connection];
    if (manager == null) {
      manager = PrivacyListsManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  Future<xmpp.PrivacyLists> getAllLists() {
    return xmpp.PrivacyListsManager.getInstance(connection).getAllLists();
  }

  Future<List<CubePrivacyListItem>> getList(String listName) {
    return xmpp.PrivacyListsManager.getInstance(connection)
        .getListByName(listName)
        .then((listItems) {
      var usersList = <int, CubePrivacyListItem>{};

      for (var item in listItems) {
        if (item.type == xmpp.PrivacyType.JID) {
          var userId = item.value!.startsWith('muc.')
              ? getUserIdFromNickWithMucDomain(item.value!)
              : getUserIdFromJidString(item.value!);
          var action = item.action.toString().toLowerCase().split('.').last;

          var isMutual = !item.controlStanzas!
                  .contains(xmpp.PrivacyControlStanza.MESSAGE) &&
              !item.controlStanzas!
                  .contains(xmpp.PrivacyControlStanza.PRESENCE_IN) &&
              !item.controlStanzas!
                  .contains(xmpp.PrivacyControlStanza.PRESENCE_OUT) &&
              !item.controlStanzas!.contains(xmpp.PrivacyControlStanza.IQ);

          usersList[userId] =
              CubePrivacyListItem(userId, action, isMutual: isMutual);
        }
      }

      return List.from(usersList.values);
    });
  }

  Future<void> setActiveList(String listName) {
    return xmpp.PrivacyListsManager.getInstance(connection)
        .setActiveList(listName);
  }

  Future<void> declineActiveList() {
    return xmpp.PrivacyListsManager.getInstance(connection).declineActiveList();
  }

  Future<void> setDefaultList(String listName) {
    return xmpp.PrivacyListsManager.getInstance(connection)
        .setDefaultList(listName);
  }

  Future<void> declineDefaultList() {
    return xmpp.PrivacyListsManager.getInstance(connection)
        .declineDefaultList();
  }

  Future<void> createList(String name, List<CubePrivacyListItem> items) {
    var xmppItems = <xmpp.PrivacyListItem>[];
    for (int i = 0, j = items.length + 1; i < items.length; i++, j++) {
      xmppItems.add(convertCubeItemToXmpp(items[i], i + 1, false));
      xmppItems.add(convertCubeItemToXmpp(items[i], j, true));
    }

    return xmpp.PrivacyListsManager.getInstance(connection)
        .createPrivacyList(xmpp.PrivacyList(name, xmppItems));
  }

  Future<void> removeList(String name) {
    return xmpp.PrivacyListsManager.getInstance(connection)
        .removePrivacyList(name);
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }
}

xmpp.PrivacyListItem convertCubeItemToXmpp(
    CubePrivacyListItem cubeItem, int order, bool inGroup) {
  var controlStanzas = <xmpp.PrivacyControlStanza>[];
  if (!cubeItem.isMutual) {
    controlStanzas.add(xmpp.PrivacyControlStanza.IQ);
    controlStanzas.add(xmpp.PrivacyControlStanza.MESSAGE);
    controlStanzas.add(xmpp.PrivacyControlStanza.PRESENCE_OUT);
    controlStanzas.add(xmpp.PrivacyControlStanza.PRESENCE_IN);
  }

  var item = xmpp.PrivacyListItem(
      type: xmpp.PrivacyType.JID,
      value: inGroup
          ? getUserNickWithMucDomain(cubeItem.userId)
          : getJidForUser(cubeItem.userId),
      action: cubeItem.action.toEnum(xmpp.PrivacyAction.values)!,
      order: order,
      controlStanzas: controlStanzas);

  return item;
}

class CubePrivacyListItem {
  int userId;
  String action;
  bool isMutual;

  CubePrivacyListItem(this.userId, this.action, {this.isMutual = true});

  @override
  String toString() {
    return '{'
        'userId: $userId, '
        'action: $action, '
        'isMutual: $isMutual '
        '}';
  }
}
