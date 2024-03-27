// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:boilerplate/core/widgets/xmpp/xmpp_stone.dart' as xmpp;
import 'package:boilerplate/core/widgets/xmpp/elements/stanzas/IqStanza.dart';
import 'package:boilerplate/core/widgets/xmpp/features/ConnectionNegotatiorManager.dart';

import '../../connectycube_core.dart';

import 'chat_exceptions.dart';
import 'realtime/extentions.dart';
import 'realtime/managers/base_managers.dart';
import 'realtime/managers/chat_managers.dart';
import 'realtime/managers/chat_messages_manager.dart';
import 'realtime/managers/global_messages_manager.dart';
import 'realtime/managers/last_activity_manager.dart';
import 'realtime/managers/messages_reactions_manager.dart';
import 'realtime/managers/messages_statuses_manager.dart';
import 'realtime/managers/privacy_lists_manager.dart';
import 'realtime/managers/rtc_signaling_manager.dart';
import 'realtime/managers/system_messages_manager.dart';
import 'realtime/managers/typing_statuses_manager.dart';
import 'realtime/utils/async_stanza_sender.dart';
import 'realtime/utils/jid_utils.dart';

class CubeChatConnection {
  static final CubeChatConnection _singleton = CubeChatConnection._internal();

  CubeChatConnection._internal();

  static CubeChatConnection get instance => _singleton;

  // ignore: non_constant_identifier_names
  static const String TAG = "CubeChatConnection";

  CubeUser? _currentUser;

  CubeUser? get currentUser => _currentUser;

  StreamSubscription<xmpp.XmppConnectionState>? _chatLoginStateSubscription;

  PrivateChatManager? _privateChatManager;
  GroupChatManager? _groupChatManager;
  ChatMessagesManager? _chatMessagesManager;
  GlobalMessagesManager? _globalMessagesManager;
  SystemMessagesManager? _systemMessagesManager;
  MessagesStatusesManager? _messagesStatusesManager;
  TypingStatusesManager? _typingStatusesManager;
  LastActivityManager? _lastActivityManager;
  PrivacyListsManager? _privacyListsManager;
  RTCSignalingManager? _rtcSignalingManager;
  AsyncStanzaSender? _asyncStanzaSender;
  MessagesReactionsManager? _messagesReactionsManager;

  xmpp.Connection? _connection;

  xmpp.RosterManager? _rosterManager;
  xmpp.MessageHandler? _messageHandler;
  xmpp.PresenceManager? _presenceManager;
  // xmpp.VCardManager? _vCardManager;

  CubeChatConnectionState _chatConnectionState = CubeChatConnectionState.Idle;

  Completer<CubeUser>? _loginChatCompleter;

  CubeChatConnectionState get chatConnectionState => _chatConnectionState;

  final StreamController<CubeChatConnectionState>
      _connectionStateStreamController = StreamController.broadcast();

  Stream<CubeChatConnectionState> get connectionStateStream {
    return _connectionStateStreamController.stream;
  }

  Future<CubeUser> login(CubeUser cubeUser, {String? resourceId}) async {
    log('[login] userId: ${cubeUser.id}, resourceId: $resourceId', TAG);
    if (_loginChatCompleter != null) return _loginChatCompleter!.future;

    _loginChatCompleter = Completer<CubeUser>();

    if (_chatConnectionState == CubeChatConnectionState.Ready) {
      log('[login] already logged in', TAG);
      _loginChatCompleter
          ?.completeError(IllegalStateException('Already logged in.'));
      return _loginChatCompleter!.future.whenComplete(() {
        _loginChatCompleter = null;
      });
    }

    String resource = isEmpty(resourceId)
        ? CubeSettings.instance.chatDefaultResource
        : resourceId!;
    String userJid = getJidForUser(cubeUser.id!, resource);

    xmpp.Jid jid = xmpp.Jid.fromFullJid(userJid);
    xmpp.XmppAccountSettings account = xmpp.XmppAccountSettings(userJid,
        jid.local, jid.domain, cubeUser.password!, kIsWeb ? 5291 : 5222,
        resource: resource, wsProtocols: ['xmpp']);
    account.reconnectionTimeout =
        CubeChatConnectionSettings.instance.reconnectionTimeout;
    account.totalReconnections =
        CubeChatConnectionSettings.instance.totalReconnections;
    account.smResumable = false;

    _connection = xmpp.Connection.getInstance(account);
    // replace user data for case when used the same user with different passwords
    _connection!.account = account;
    _connection!.connectionNegotatiorManager =
        ConnectionNegotiatorManager(_connection!, account);
    xmpp.Log.logXmpp = CubeSettings.instance.isDebugEnabled;

    _chatLoginStateSubscription =
        _connection!.connectionStateStream.listen((state) {
      _onConnectionStateChangedInternal(state, cubeUser);
    });

    if (_connection!.state == xmpp.XmppConnectionState.ForcefullyClosed) {
      _connection?.reconnect();
    } else {
      _connection?.connect();
    }

    return _loginChatCompleter!.future.whenComplete(() {
      _loginChatCompleter = null;
    });
  }

  void _initCurrentUser(CubeUser cubeUser) {
    _currentUser = cubeUser;
  }

  void _initGlobalMessagesManager(xmpp.Connection connection) {
    _globalMessagesManager = GlobalMessagesManager.getInstance(connection);
  }

  void _initRosterManager(xmpp.Connection connection) {
    _rosterManager = xmpp.RosterManager.getInstance(connection);

//    _rosterManager.addRosterItem(xmpp.Buddy(receiverJid)).then((result) {
//      if (result.description != null) {
//        //print("add roster" + result.description);
//      }
//    });
  }

  void _initPresenceManager(xmpp.Connection connection) {
    _presenceManager = xmpp.PresenceManager.getInstance(connection);
    _presenceManager!.subscriptionStream.listen((streamEvent) {
//      if (streamEvent.type == xmpp.SubscriptionEventType.REQUEST) {
//        //print("Accepting presence request");
//        presenceManager.acceptSubscription(streamEvent.jid);
//      }
    });
  }

  void _initVCardManager(xmpp.Connection connection) {
    // _vCardManager = xmpp.VCardManager(connection);
//    _vCardManager.getSelfVCard().then((vCard) {
//      if (vCard != null) {
//        //print("Your info" + vCard.buildXmlString());
//      }
//    });

//    _vCardManager.getVCardFor(receiverJid).then((vCard) {
//      if (vCard != null) {
//        //print("Receiver info" + vCard.buildXmlString());
//        if (vCard != null && vCard.image != null) {
////            var file = File('test456789.jpg')
////              ..writeAsBytesSync(image.encodeJpg(vCard.image));
////            //print("IMAGE SAVED TO: ${file.path}");
//        }
//      }
//    });
  }

  void _onConnectionStateChangedInternal(
      xmpp.XmppConnectionState state, CubeUser cubeUser) {
    switch (state) {
      case xmpp.XmppConnectionState.Idle:
        log("Chat connection Idle", TAG);
        _setConnectionState(CubeChatConnectionState.Idle);
        break;
      case xmpp.XmppConnectionState.Closed:
        log("Chat connection Closed", TAG);
        _setConnectionState(CubeChatConnectionState.Closed);
        break;
      case xmpp.XmppConnectionState.SocketOpening:
        log("Chat connection SocketOpening", TAG);
        _setConnectionState(CubeChatConnectionState.Connecting);
        break;
      case xmpp.XmppConnectionState.SocketOpened:
        log("Chat connection SocketOpened", TAG);
        _setConnectionState(CubeChatConnectionState.Connecting);
        break;
      case xmpp.XmppConnectionState.DoneParsingFeatures:
        log("Chat connection DoneParsingFeatures", TAG);
        _setConnectionState(CubeChatConnectionState.Connecting);
        break;
      case xmpp.XmppConnectionState.StartTlsFailed:
        log("Chat connection StartTlsFailed", TAG);
        _setConnectionState(CubeChatConnectionState.AuthenticationFailure);
        _notifyChatLoginError(ChatConnectionException(
            message: "Open connection error: StartTlsFailed"));

        break;
      case xmpp.XmppConnectionState.AuthenticationNotSupported:
        log("Chat connection AuthenticationNotSupported", TAG);
        _setConnectionState(CubeChatConnectionState.AuthenticationFailure);
        _notifyChatLoginError(ChatConnectionException(
            message: "Open connection error: AuthenticationNotSupported"));

        break;
      case xmpp.XmppConnectionState.PlainAuthentication:
        log("Chat connection PlainAuthentication", TAG);
        _setConnectionState(CubeChatConnectionState.Connecting);
        break;
      case xmpp.XmppConnectionState.Authenticating:
        log("Chat connection Authenticating", TAG);
        _setConnectionState(CubeChatConnectionState.Connecting);
        break;
      case xmpp.XmppConnectionState.Authenticated:
        log("Chat connection Authenticated", TAG);
        _setConnectionState(CubeChatConnectionState.Authenticated);

        break;
      case xmpp.XmppConnectionState.AuthenticationFailure:
        log("Chat connection AuthenticationFailure", TAG);
        _setConnectionState(CubeChatConnectionState.AuthenticationFailure);

        _notifyChatLoginError(ChatConnectionException(
            message: "Open connection error: AuthenticationFailure"));

        break;
      case xmpp.XmppConnectionState.Resumed:
        log("Chat connection Resumed", TAG);
        _setConnectionState(CubeChatConnectionState.Resumed);
        break;
      case xmpp.XmppConnectionState.SessionInitialized:
        log("Chat connection SessionInitialized", TAG);
        _setConnectionState(CubeChatConnectionState.Connecting);
        break;
      case xmpp.XmppConnectionState.Ready:
        log("Chat connection Ready", TAG);

        _initCurrentUser(cubeUser);
        _initGlobalMessagesManager(_connection!);
        _initRosterManager(_connection!);
        _initPresenceManager(_connection!);
        _initVCardManager(_connection!);

        if (!(_loginChatCompleter?.isCompleted ?? false)) {
          _loginChatCompleter?.complete(cubeUser);
        }

        _setConnectionState(CubeChatConnectionState.Ready);

        break;
      case xmpp.XmppConnectionState.Closing:
        log("Chat connection Closing", TAG);
        _setConnectionState(CubeChatConnectionState.Closing);
        break;
      case xmpp.XmppConnectionState.ForcefullyClosed:
        log("Chat connection ForcefullyClosed", TAG);
        _setConnectionState(CubeChatConnectionState.ForceClosed);
        _notifyChatLoginError(ChatConnectionException(
            message: "Open connection error: ForcefullyClosed"));

        break;
      case xmpp.XmppConnectionState.Reconnecting:
        log("Chat connection Reconnecting", TAG);
        _setConnectionState(CubeChatConnectionState.Reconnecting);
        break;
      case xmpp.XmppConnectionState.WouldLikeToOpen:
        log("Chat connection WouldLikeToOpen", TAG);
        _setConnectionState(CubeChatConnectionState.Connecting);
        break;
      case xmpp.XmppConnectionState.WouldLikeToClose:
        log("Chat connection WouldLikeToClose", TAG);
        _setConnectionState(CubeChatConnectionState.Closing);
        break;
      default:
    }
  }

  void _setConnectionState(CubeChatConnectionState state) {
    if (_chatConnectionState != state) {
      _chatConnectionState = state;
      _connectionStateStreamController.add(state);
    }
  }

  void _notifyChatLoginError(Exception chatConnectionException) {
    if (!(_loginChatCompleter?.isCompleted ?? false)) {
      _loginChatCompleter?.completeError(chatConnectionException);
    }
  }

  void relogin() {
    if (currentUser == null) {
      throw IllegalStateException(
          "Call 'login(cubeUser)' first before use 'relogin()'");
    }

    if (_connection!.state == xmpp.XmppConnectionState.Reconnecting) return;

    if (_connection!.state == xmpp.XmppConnectionState.ForcefullyClosed) {
      _connection!.reconnect();
    } else if (_connection!.state == xmpp.XmppConnectionState.Closed) {
      _setConnectionState(CubeChatConnectionState.Reconnecting);

      login(currentUser!);
    }
  }

  void logout() {
    log('[logout]', TAG);
    _chatLoginStateSubscription?.cancel();
    _setConnectionState(CubeChatConnectionState.Closed);
    _chatLoginStateSubscription = null;
    _loginChatCompleter = null;
    _connection?.close();
  }

  void destroy() {
    log('[destroy]', TAG);
    logout();

    _clearConnection();
    _setConnectionState(CubeChatConnectionState.Idle);
  }

  void _clearConnection() {
    log('[_clearConnection]', TAG);
    _connection = null;

    _currentUser = null;

    _destroyManager(_globalMessagesManager);

    _rosterManager = null;
    _messageHandler = null;
    _presenceManager = null;
    // _vCardManager = null;

    _closeManagerStreams(_privateChatManager);
    _closeManagerStreams(_groupChatManager);
    _closeManagerStreams(_chatMessagesManager);
    _closeManagerStreams(_systemMessagesManager);
    _closeManagerStreams(_messagesStatusesManager);
    _closeManagerStreams(_typingStatusesManager);
    _closeManagerStreams(_rtcSignalingManager);
    _closeManagerStreams(_lastActivityManager);
    _closeManagerStreams(_messagesReactionsManager);

    _destroyManager(_privateChatManager);
    _destroyManager(_groupChatManager);
    _destroyManager(_chatMessagesManager);
    _destroyManager(_systemMessagesManager);
    _destroyManager(_messagesStatusesManager);
    _destroyManager(_typingStatusesManager);
    _destroyManager(_rtcSignalingManager);
    _destroyManager(_asyncStanzaSender);
    _destroyManager(_lastActivityManager);
    _destroyManager(_messagesReactionsManager);
  }

  bool isAuthenticated() {
    return _connection != null && _connection!.authenticated;
  }

  Future<int> getLasUserActivity(int userId) {
    if (lastActivityManager == null) {
      return Future.error(
          ChatConnectionException(message: CHAT_NOT_CONNECTED_ERROR));
    }

    return lastActivityManager!.getLastActivity(userId);
  }

  Future<void> subscribeToUserLastActivityStatus(int userId,
      {Function(int)? callback}) {
    if (lastActivityManager == null) {
      return Future.error(
          ChatConnectionException(message: CHAT_NOT_CONNECTED_ERROR));
    }

    return lastActivityManager!
        .subscribeToUserLastActivityStatus(userId, callback: callback);
  }

  Future<void> unsubscribeFromUserLastActivityStatus(int userId) {
    if (lastActivityManager == null) {
      return Future.error(
          ChatConnectionException(message: CHAT_NOT_CONNECTED_ERROR));
    }

    return lastActivityManager!.unsubscribeFromUserLastActivityStatus(userId);
  }

  Stream<LastActivitySubscriptionEvent>? get lastActivityStream =>
      lastActivityManager?.lastActivityStream;

  Future<void> markInactive() {
    return _enableMobileOptimisation(true);
  }

  Future<void> markActive() {
    return _enableMobileOptimisation(false);
  }

  Future<void> _enableMobileOptimisation(bool enable) {
    Completer<void> completer = Completer();

    String id = xmpp.AbstractStanza.getRandomId();
    EnableMobileElement enableMobileElement = EnableMobileElement(enable);

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

  /// Useful only for SDK needs
  GlobalMessagesManager? get globalMessagesManager {
    return _globalMessagesManager;
  }

  SystemMessagesManager? get systemMessagesManager {
    if (isAuthenticated()) {
      _systemMessagesManager = SystemMessagesManager.getInstance(_connection!);
    }

    return _systemMessagesManager;
  }

  PrivateChatManager? get privateChatManager {
    if (isAuthenticated()) {
      _privateChatManager = PrivateChatManager.getInstance(_connection!);
    }

    return _privateChatManager;
  }

  GroupChatManager? get groupChatManager {
    if (isAuthenticated()) {
      _groupChatManager = GroupChatManager.getInstance(_connection!);
    }

    return _groupChatManager;
  }

  ChatMessagesManager? get chatMessagesManager {
    if (isAuthenticated()) {
      _chatMessagesManager = ChatMessagesManager.getInstance(_connection!);
    }

    return _chatMessagesManager;
  }

  MessagesStatusesManager? get messagesStatusesManager {
    if (isAuthenticated()) {
      _messagesStatusesManager =
          MessagesStatusesManager.getInstance(_connection!);
    }

    return _messagesStatusesManager;
  }

  TypingStatusesManager? get typingStatusesManager {
    if (isAuthenticated()) {
      _typingStatusesManager = TypingStatusesManager.getInstance(_connection!);
    }

    return _typingStatusesManager;
  }

  RTCSignalingManager? get rtcSignalingManager {
    if (isAuthenticated()) {
      _rtcSignalingManager = RTCSignalingManager.getInstance(_connection!);
    }

    return _rtcSignalingManager;
  }

  AsyncStanzaSender? get asyncStanzaSender {
    if (isAuthenticated()) {
      _asyncStanzaSender = AsyncStanzaSender.getInstance(_connection!);
    }

    return _asyncStanzaSender;
  }

  LastActivityManager? get lastActivityManager {
    if (isAuthenticated()) {
      _lastActivityManager = LastActivityManager.getInstance(_connection!);
    }

    return _lastActivityManager;
  }

  PrivacyListsManager? get privacyListsManager {
    if (isAuthenticated()) {
      _privacyListsManager = PrivacyListsManager.getInstance(_connection!);
    }

    return _privacyListsManager;
  }

  MessagesReactionsManager? get messagesReactionsManager {
    if (isAuthenticated()) {
      _messagesReactionsManager =
          MessagesReactionsManager.getInstance(_connection!);
    }

    return _messagesReactionsManager;
  }

  void _closeManagerStreams(StreamedManager? manager) {
    manager?.closeStreams();
  }

  void _destroyManager(Manager? manager) {
    manager?.destroy();
    manager = null;
  }
}

class CubeChatConnectionSettings {
  static final CubeChatConnectionSettings _singleton =
      CubeChatConnectionSettings._internal();

  CubeChatConnectionSettings._internal();

  static CubeChatConnectionSettings get instance => _singleton;

  int totalReconnections = 3;
  int reconnectionTimeout = 5000;
}

enum CubeChatConnectionState {
  Idle,
  Connecting,
  Authenticated,
  AuthenticationFailure,
  Reconnecting,
  Resumed,
  Ready,
  Closing,
  ForceClosed,
  Closed
}
