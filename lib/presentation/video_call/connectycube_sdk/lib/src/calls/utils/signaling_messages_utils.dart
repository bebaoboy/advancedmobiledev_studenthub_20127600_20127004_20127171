import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_chat.dart';

import 'signaling_specifications.dart';
import '../models/cube_rtc_session_description.dart';
import '../signaling/call_message_extention.dart';

MessageStanza createOfferMessage(
  CubeRTCSessionDescription cubeSdp,
  int opponentId,
  RTCSessionDescription sdp,
) {
  CallExtraParamsElement callExtraParams = prepareBaseCallParams(
      cubeSdp.sessionId,
      cubeSdp.conferenceType,
      cubeSdp.callerId,
      cubeSdp.opponents,
      SignalCMD.CALL);
  callExtraParams.setUserInfo(cubeSdp.userInfo);
  callExtraParams.addParam(SignalField.SDP, sdp.sdp);

  return buildSignalingMessage(callExtraParams, opponentId);
}

MessageStanza createAnswerMessage(
  CubeRTCSessionDescription cubeSdp,
  int opponentId,
  RTCSessionDescription sdp,
) {
  CallExtraParamsElement callExtraParams = prepareBaseCallParams(
      cubeSdp.sessionId,
      cubeSdp.conferenceType,
      cubeSdp.callerId,
      cubeSdp.opponents,
      SignalCMD.ACCEPT_CALL);
  callExtraParams.setUserInfo(cubeSdp.userInfo);
  callExtraParams.addParam(SignalField.SDP, sdp.sdp);

  return buildSignalingMessage(callExtraParams, opponentId);
}

MessageStanza createHungUpMessage(
  CubeRTCSessionDescription cubeSdp,
  int opponentId,
  Map<String, String>? userInfo,
) {
  CallExtraParamsElement callExtraParams = prepareBaseCallParams(
      cubeSdp.sessionId,
      cubeSdp.conferenceType,
      cubeSdp.callerId,
      cubeSdp.opponents,
      SignalCMD.HANG_UP);
  callExtraParams.setUserInfo(userInfo);

  return buildSignalingMessage(callExtraParams, opponentId);
}

MessageStanza createRejectMessage(
  CubeRTCSessionDescription cubeSdp,
  int opponentId,
  Map<String, String>? userInfo,
) {
  CallExtraParamsElement callExtraParams = prepareBaseCallParams(
      cubeSdp.sessionId,
      cubeSdp.conferenceType,
      cubeSdp.callerId,
      cubeSdp.opponents,
      SignalCMD.REJECT_CALL);
  callExtraParams.setUserInfo(userInfo);

  return buildSignalingMessage(callExtraParams, opponentId);
}

MessageStanza createIceCandidatesMessage(
  CubeRTCSessionDescription cubeSdp,
  int opponentId,
  List<RTCIceCandidate> candidates,
) {
  CallExtraParamsElement callExtraParams = prepareBaseCallParams(
      cubeSdp.sessionId,
      cubeSdp.conferenceType,
      cubeSdp.callerId,
      cubeSdp.opponents,
      SignalCMD.CANDITATES);
  callExtraParams.setIceCandidates(candidates);

  return buildSignalingMessage(callExtraParams, opponentId);
}

MessageStanza createUpdateCallMessage(
  CubeRTCSessionDescription cubeSdp,
  int opponentId,
  RTCSessionDescription sdp,
) {
  CallExtraParamsElement callExtraParams = prepareBaseCallParams(
      cubeSdp.sessionId,
      cubeSdp.conferenceType,
      cubeSdp.callerId,
      cubeSdp.opponents,
      SignalCMD.UPDATE);
  callExtraParams.setUserInfo(cubeSdp.userInfo);
  callExtraParams.addParam(SignalField.SDP, sdp.sdp);
  callExtraParams.addParam(SignalField.SDP_TYPE, sdp.type);

  return buildSignalingMessage(callExtraParams, opponentId);
}

MessageStanza buildSignalingMessage(
  CallExtraParamsElement params,
  int opponentId,
) {
  String id = AbstractStanza.getRandomId();

  CubeMessageStanza signalingMsg =
      CubeMessageStanza(id, MessageStanzaType.HEADLINE);
  signalingMsg.addChild(params);

  Jid toJid = Jid.fromFullJid(getJidForUser(opponentId));

  signalingMsg.toJid = toJid;

  return signalingMsg;
}

CallExtraParamsElement prepareBaseCallParams(
  String sessionId,
  int callType,
  int callerId,
  Set<int> opponentsIds,
  String signalingType,
) {
  CallExtraParamsElement callExtraParams = CallExtraParamsElement();
  callExtraParams.setOpponents(opponentsIds);
  callExtraParams.addParam(MODULE_IDENTIFIER, MODULE_CALL_NOTIFICATIONS);
  callExtraParams.addParam(SignalField.CALLER, callerId.toString());
  callExtraParams.addParam(SignalField.CALL_TYPE, callType.toString());
  callExtraParams.addParam(SignalField.SESSION_ID, sessionId);
  callExtraParams.addParam(SignalField.SIGNALING_TYPE, signalingType);
  callExtraParams.addParam(SignalField.PLATFORM, "flutter");
  callExtraParams.addParam(
    SignalField.VERSION_SDK,
    CubeSettings.instance.versionName,
  );

  return callExtraParams;
}
