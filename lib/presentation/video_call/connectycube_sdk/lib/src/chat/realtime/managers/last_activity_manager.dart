import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:xmpp_stone/xmpp_stone.dart';

import 'base_managers.dart';
import '../extentions.dart';
import '../../chat_connection_service.dart';
import '../utils/jid_utils.dart';

class LastActivityManager extends Manager implements StreamedManager {
  static Map<Connection, LastActivityManager> _instances = Map();

  static Map<int, Function(int)?> _usersCallbacks = {};

  late StreamController<LastActivitySubscriptionEvent>
      _lastActivityStreamController;

  Stream<LastActivitySubscriptionEvent> get lastActivityStream =>
      _lastActivityStreamController.stream;

  LastActivityManager._private(Connection connection) : super(connection) {
    _lastActivityStreamController = StreamController.broadcast();

    connection.inStanzasStream.where((stanza) {
      if (stanza == null) return false;

      var isLastActivityStanza = false;

      var queryElement = stanza.children.firstWhereOrNull(
          (child) => child.name == LastActivityQuery.ELEMENT_NAME);

      if (queryElement == null) return false;

      isLastActivityStanza = queryElement.getAttribute('xmlns')?.value ==
          LastActivityQuery.NAME_SPACE;

      return isLastActivityStanza;
    }).listen(_processStanza);
  }

  static getInstance(Connection connection) {
    LastActivityManager? manager = _instances[connection];
    if (manager == null) {
      manager = LastActivityManager._private(connection);
      _instances[connection] = manager;
    }

    return manager;
  }

  Future<int> getLastActivity(int userId) {
    Completer<int> completer = Completer();

    String id = AbstractStanza.getRandomId();
    Jid toJid = Jid.fromFullJid(getJidForUser(userId));
    LastActivityQuery lastActivityQuery = LastActivityQuery();

    IqStanza lastActivityStanza = IqStanza(id, IqStanzaType.GET);
    lastActivityStanza.toJid = toJid;
    lastActivityStanza.addChild(lastActivityQuery);

    CubeChatConnection.instance.asyncStanzaSender?.sendAsync(lastActivityStanza,
        (resultStanza, exception) {
      if (resultStanza == null) {
        completer.completeError(exception);
      } else {
        LastActivityQuery response = LastActivityQuery.fromStanza(
            resultStanza.getChild(LastActivityQuery.ELEMENT_NAME));
        int seconds = response.getSeconds();
        completer.complete(seconds);
      }
    });

    return completer.future;
  }

  Future<void> subscribeToUserLastActivityStatus(int userId,
      {Function(int)? callback}) {
    _usersCallbacks[userId] = callback;
    return _setSubscriptionToUserLastActivity(userId, true);
  }

  Future<void> unsubscribeFromUserLastActivityStatus(int userId) {
    _usersCallbacks.remove(userId);
    return _setSubscriptionToUserLastActivity(userId, false);
  }

  Future<void> _setSubscriptionToUserLastActivity(int userId, bool enable) {
    Completer<void> completer = Completer();

    String id = AbstractStanza.getRandomId();
    SubscribeLastActivityElement enableMobileElement =
        SubscribeLastActivityElement(userId, enable);

    IqStanza enableMobileOptimisation = IqStanza(id, IqStanzaType.SET);
    enableMobileOptimisation.addChild(enableMobileElement);

    CubeChatConnection.instance.asyncStanzaSender
        ?.sendAsync(enableMobileOptimisation, (resultStanza, exception) {
      if (resultStanza == null) {
        completer.completeError(exception);
      } else {
        completer.complete();
      }
    });

    return completer.future;
  }

  @override
  void closeStreams() {
    _lastActivityStreamController.close();
  }

  @override
  void destroy() {
    _instances.remove(connection);
  }

  void _processStanza(AbstractStanza? stanza) {
    if (stanza == null) return;

    var fromJid = stanza.fromJid;
    if (fromJid == null) return;

    int userId = getUserIdFromJid(fromJid);

    LastActivityQuery lastActivityQuery = LastActivityQuery.fromStanza(
        stanza.getChild(LastActivityQuery.ELEMENT_NAME)!);

    int seconds = lastActivityQuery.getSeconds();

    var userCallback = _usersCallbacks[userId];
    if (userCallback != null) {
      userCallback.call(seconds);
    }

    _lastActivityStreamController
        .add(LastActivitySubscriptionEvent(userId, seconds));
  }
}

class LastActivitySubscriptionEvent {
  final int userId;
  final int seconds;

  LastActivitySubscriptionEvent(this.userId, this.seconds);
}
