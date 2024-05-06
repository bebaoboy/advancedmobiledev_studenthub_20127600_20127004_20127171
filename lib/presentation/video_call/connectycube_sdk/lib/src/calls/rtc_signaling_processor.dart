import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:boilerplate/core/widgets/xmpp/xmpp_stone.dart';

import '../../connectycube_chat.dart';

import 'models/cube_rtc_session_description.dart';
import 'signaling/call_message_extention.dart';
import 'utils/signaling_specifications.dart';

import '../chat/realtime/managers/rtc_signaling_manager.dart';

class RTCSignalingProcessor {
  static final RTCSignalingProcessor _singleton =
      RTCSignalingProcessor._internal();
  RTCSignalingManager? _rtcSignalingManager;
  StreamSubscription? _subscription;

  Set<CallsSignalingCallback> callbacks = {};

  RTCSignalingProcessor._internal();

  static RTCSignalingProcessor get instance => _singleton;

  void init() {
    _rtcSignalingManager = CubeChatConnection.instance.rtcSignalingManager;

    _subscription = _rtcSignalingManager!.signalingMessagesStream
        .listen(_processSignalingMessage);
    //print("");
  }

  void dispose() {
    _rtcSignalingManager = null;

    _subscription?.cancel();
  }

  void sendSignalingMessage(MessageStanza signalingMsg) {
    _rtcSignalingManager?.sendSignalingMessage(signalingMsg);
  }

  void _processSignalingMessage(MessageStanza signalingMessage) {
    print("new stanza");
    XmppElement? stanzaExtraParams =
        signalingMessage.getChild(ExtraParamsElement.ELEMENT_NAME);

    if (stanzaExtraParams == null) return;

    int? senderId;
    if (signalingMessage.fromJid != null) {
      senderId = getUserIdFromJid(signalingMessage.fromJid!);
    }

    CallExtraParamsElement callExtraParams =
        CallExtraParamsElement.fromStanza(stanzaExtraParams);

    Map<String, String> params = callExtraParams.getParams();

    String? signalingType = params[SignalField.SIGNALING_TYPE];
    String sessionId = params[SignalField.SESSION_ID]!;
    int? callerId = int.tryParse(params[SignalField.CALLER] ?? '');
    int? callType = int.tryParse(params[SignalField.CALL_TYPE] ?? '');
    Set<int>? opponents = callExtraParams.getOpponents();
    Map<String, String>? userInfo = callExtraParams.getUserInfo();
    CubeUser userFrom = CubeUser(id: senderId);

    CubeRTCSessionDescription cubeSdp = CubeRTCSessionDescription.withSession(
      sessionId,
      callerId ?? 0,
      opponents,
      callType ?? 0,
      userInfo,
    );

    switch (signalingType) {
      case SignalCMD.CALL:
        String rawSdp = params[SignalField.SDP]!;
        RTCSessionDescription sdp = RTCSessionDescription(rawSdp, "offer");
        log("incoming call stanza for user ${userFrom.id}");

        _notifyNewCallReceive(cubeSdp, userFrom, sdp);

        break;
      case SignalCMD.CANDITATE:
        RTCIceCandidate? iceCandidate = callExtraParams.getIceCandidate();

        _notifyCandidatesReceive([iceCandidate], cubeSdp, userFrom);

        break;
      case SignalCMD.CANDITATES:
        List<RTCIceCandidate> iceCandidates =
            callExtraParams.getIceCandidates();

        _notifyCandidatesReceive(iceCandidates, cubeSdp, userFrom);

        break;
      case SignalCMD.ACCEPT_CALL:
        String rawSdp = params[SignalField.SDP]!;
        RTCSessionDescription sdp = RTCSessionDescription(rawSdp, "answer");

        _notifyCallAcceptedByUser(cubeSdp, userFrom, sdp);

        break;
      case SignalCMD.REJECT_CALL:
        _notifyCallRejectedByUser(cubeSdp, userFrom);

        break;
      case SignalCMD.HANG_UP:
        _notifyHungUpReceiveFromUser(cubeSdp, userFrom);

        break;
      case SignalCMD.ADD_USER:
        break;
      case SignalCMD.REMOVE_USER:
        break;
      case SignalCMD.UPDATE:
        String rawSdp = params[SignalField.SDP]!;
        String sdpType = params[SignalField.SDP_TYPE]!;
        RTCSessionDescription sdp = RTCSessionDescription(rawSdp, sdpType);

        _notifyUpdateCallReceive(cubeSdp, userFrom, sdp);
        break;
    }
  }

  void _notifyNewCallReceive(
    CubeRTCSessionDescription cubeSdp,
    CubeUser cubeUser,
    RTCSessionDescription rtcSdp,
  ) {
    for (var callback in callbacks) {
      callback.onNewCallReceive(cubeSdp, cubeUser, rtcSdp);
    }
  }

  void _notifyCallAcceptedByUser(
    CubeRTCSessionDescription cubeSdp,
    CubeUser cubeUser,
    RTCSessionDescription rtcSdp,
  ) {
    for (var callback in callbacks) {
      callback.onCallAcceptReceive(cubeSdp, cubeUser, rtcSdp);
    }
  }

  void _notifyCallRejectedByUser(
    CubeRTCSessionDescription cubeSdp,
    CubeUser cubeUser,
  ) {
    for (var callback in callbacks) {
      callback.onRejectReceive(cubeSdp, cubeUser);
    }
  }

  void _notifyHungUpReceiveFromUser(
    CubeRTCSessionDescription cubeSdp,
    CubeUser cubeUser,
  ) {
    for (var callback in callbacks) {
      callback.onHungUpReceive(cubeSdp, cubeUser);
    }
  }

  void _notifyCandidatesReceive(
    List<RTCIceCandidate?> candidates,
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
  ) {
    for (var callback in callbacks) {
      callback.onCandidatesReceive(candidates, cubeRtcSdp, cubeUser);
    }
  }

  void _notifyUpdateCallReceive(
    CubeRTCSessionDescription cubeSdp,
    CubeUser cubeUser,
    RTCSessionDescription rtcSdp,
  ) {
    for (var callback in callbacks) {
      callback.onUpdateCallReceive(cubeSdp, cubeUser, rtcSdp);
    }
  }

  void addSignalingCallback(CallsSignalingCallback callback) {
    callbacks.add(callback);

    if (_subscription!.isPaused) {
      _subscription!.resume();
    }
  }

  void removeSignalingCallback(CallsSignalingCallback callback) {
    callbacks.remove(callback);

    if (callbacks.isEmpty) {
      _subscription!.pause();
    }
  }
}

abstract class CallsSignalingCallback {
  void onNewCallReceive(
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
    RTCSessionDescription sdp,
  );

  void onCallAcceptReceive(
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
    RTCSessionDescription sdp,
  );

  void onRejectReceive(
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
  );

  void onHungUpReceive(
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
  );

  void onCandidatesReceive(
    List<RTCIceCandidate?> candidates,
    CubeRTCSessionDescription cubeRtcSdp,
    CubeUser cubeUser,
  );

  void onUpdateCallReceive(
    CubeRTCSessionDescription cubeSdp,
    CubeUser cubeUser,
    RTCSessionDescription rtcSdp,
  );
}
