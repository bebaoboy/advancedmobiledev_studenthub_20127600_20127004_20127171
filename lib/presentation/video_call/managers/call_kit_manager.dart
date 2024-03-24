import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
import 'package:universal_io/io.dart';

import 'package:boilerplate/presentation/video_call/connectycube_flutter_call_kit/lib/connectycube_flutter_call_kit.dart';

class CallKitManager {
  static CallKitManager get instance => _getInstance();
  static CallKitManager? _instance;
  static String TAG = "BEBAOBOY";

  static CallKitManager _getInstance() {
    return _instance ??= CallKitManager._internal();
  }

  factory CallKitManager() => _getInstance();

  CallKitManager._internal();

  late Function(String uuid) onCallAccepted;
  late Function(String uuid) onCallEnded;
  late Function(bool mute, String uuid) onMuteCall;

  init({
    required onCallAccepted(uuid),
    required onCallEnded(uuid),
    required onMuteCall(mute, uuid),
  }) {
    this.onCallAccepted = onCallAccepted;
    this.onCallEnded = onCallEnded;
    this.onMuteCall = onMuteCall;

    ConnectycubeFlutterCallKit.instance.init(
        onCallAccepted: _onCallAccepted,
        onCallRejected: _onCallRejected,
        onCallIncoming: (event) {
          log("call incoming: ${event.callerId} ${event.callType}");
          return Future.value(true);
        },
        icon: Platform.isAndroid ? 'default_avatar' : 'CallkitIcon',
        notificationIcon: 'ic_notification',
        color: '#07711e',
        ringtone:
            Platform.isAndroid ? 'custom_ringtone' : 'custom_ringtone.caf');

    if (Platform.isIOS) {
      ConnectycubeFlutterCallKit.onCallMuted = _onCallMuted;
    }
  }

  Future<void> processCallFinished(String uuid) async {
    if (Platform.isAndroid || Platform.isIOS) {
      ConnectycubeFlutterCallKit.reportCallEnded(sessionId: uuid);
      ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: false);
    }
  }

  /// Event Listener Callbacks for 'connectycube_flutter_call_kit'
  ///
  Future<void> _onCallMuted(bool mute, String uuid) async {
    onMuteCall.call(mute, uuid);
  }

  void muteCall(String sessionId, bool mute) {
    ConnectycubeFlutterCallKit.reportCallMuted(
        sessionId: sessionId, muted: mute);
  }

  Future<void> _onCallAccepted(CallEvent callEvent) async {
    onCallAccepted.call(callEvent.sessionId);
  }

  Future<void> _onCallRejected(CallEvent callEvent) async {
    if (!CubeChatConnection.instance.isAuthenticated()) {
      rejectCall(
          callEvent.sessionId, {...callEvent.opponentsIds, callEvent.callerId});
    }

    onCallEnded.call(callEvent.sessionId);
  }
}
