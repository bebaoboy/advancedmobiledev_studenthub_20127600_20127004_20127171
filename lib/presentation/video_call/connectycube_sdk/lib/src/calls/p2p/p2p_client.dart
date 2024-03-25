import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:boilerplate/core/widgets/xmpp/xmpp_stone.dart';

import '../../../connectycube_chat.dart';

import 'p2p_session.dart';
import '../call_client.dart';
import '../models/cube_rtc_session_description.dart';
import '../rtc_signaling_processor.dart';

class P2PClient implements CallClient<P2PSession>, CallsSignalingCallback {
  static const String TAG = "P2PClient";

  static final P2PClient _instance = P2PClient._privateConstructor();

  @override
  SessionStateCallback<P2PSession>? onReceiveNewSession;
  @override
  SessionStateCallback<P2PSession>? onSessionClosed;

  RTCSignalingProcessor? _signalingProcessor;

  P2PClient._privateConstructor();

  static P2PClient get instance => _instance;

  final Map<String?, P2PSession> _sessions = {};

  /// Creates the instance of [ConferenceSession].
  /// [callType] - can be [CallType.VIDEO_CALL] or [CallType.AUDIO_CALL].
  /// [opponentsIds] - the set of ids of users you want to call.
  /// [startScreenSharing] - set `true` if want to initialize the call with Screen sharing feature.
  /// [desktopCapturerSource] - the desktop capturer source, if it is `null` the
  ///  default Window/Screen will be captured. Use only for desktop platforms.
  ///  Use [ScreenSelectDialog] to give the user a choice of the shared Window/Screen.
  /// [useIOSBroadcasting] - set `true` if the `Broadcast Upload Extension` was
  /// added to your iOS project for implementation Screen Sharing feature, otherwise
  /// set `false` and `in-app` Screen Sharing will be started. Used for iOS platform only.
  /// See our [step-by-step guide](https://developers.connectycube.com/flutter/videocalling?id=ios-screen-sharing-using-the-screen-broadcasting-feature)
  /// on how to integrate the Screen Broadcasting feature into your iOS app.
  @override
  P2PSession createCallSession(
    int callType,
    Set<int> opponentsIds, {
    bool startScreenSharing = false,
    DesktopCapturerSource? desktopCapturerSource,
    bool useIOSBroadcasting = false,
  }) {
    int callerId = CubeChatConnection.instance.currentUser?.id ?? -1;

    CubeRTCSessionDescription cubeSdp = CubeRTCSessionDescription(
      callerId,
      opponentsIds,
      callType,
    );
    P2PSession session = P2PSession(this, cubeSdp,
        startScreenSharing: startScreenSharing,
        desktopCapturerSource: desktopCapturerSource,
        useIOSBroadcasting: useIOSBroadcasting);

    _sessions[session.sessionId] = session;

    return session;
  }

  void sendSignalingMessage(MessageStanza signalingMessage) {
    _signalingProcessor?.sendSignalingMessage(signalingMessage);
  }

  @override
  void init() {
    _signalingProcessor ??= RTCSignalingProcessor.instance;

    _signalingProcessor!.init();
    _signalingProcessor!.addSignalingCallback(this);
  }

  @override
  void destroy() {
    _signalingProcessor?.removeSignalingCallback(this);
    _signalingProcessor?.dispose();
    _signalingProcessor = null;
  }

  @override
  void onCallAcceptReceive(
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
    RTCSessionDescription sdp,
  ) {
    P2PSession? session = _sessions[cubeRtcSdp.sessionId];
    if (session == null) return;

    session.processAcceptCall(cubeRtcSdp, cubeUser.id!, sdp);
  }

  @override
  void onCandidatesReceive(
    List<RTCIceCandidate?> candidates,
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
  ) {
    P2PSession? session = _sessions[cubeRtcSdp.sessionId];
    if (session == null) return;

    session.processIceCandidates(candidates, cubeUser.id!);
  }

  @override
  void onHungUpReceive(
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
  ) {
    P2PSession? session = _sessions[cubeRtcSdp.sessionId];
    if (session == null) return;

    session.processHungUpFromUser(cubeRtcSdp, cubeUser.id!);
  }

  @override
  void onNewCallReceive(
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
    RTCSessionDescription sdp,
  ) {
    P2PSession? session = _sessions[cubeRtcSdp.sessionId];

    if (session == null) {
      session = P2PSession(this, cubeRtcSdp);

      _sessions[session.sessionId] = session;

      if (onReceiveNewSession != null) {
        onReceiveNewSession!(session);
      }
    }

    session.processNewCall(cubeUser.id!, sdp);
  }

  @override
  void onRejectReceive(
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
  ) {
    P2PSession? session = _sessions[cubeRtcSdp.sessionId];
    if (session == null) return;

    session.processRejectFromUser(cubeRtcSdp, cubeUser.id!);
  }

  void removeSession(P2PSession session) {
    if (onSessionClosed != null) {
      onSessionClosed!(session);
    }
  }

  @override
  void onUpdateCallReceive(CubeRTCSessionDescription cubeSdp, CubeUser cubeUser,
      RTCSessionDescription sdp) {
    P2PSession? session = _sessions[cubeSdp.sessionId];

    session?.processCallUpdated(cubeUser.id!, sdp);
  }
}
