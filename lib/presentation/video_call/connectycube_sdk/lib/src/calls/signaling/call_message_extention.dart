import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

import '../../../connectycube_chat.dart';

import '../utils/signaling_specifications.dart';

class CallExtraParamsElement extends ExtraParamsElement {
  CallExtraParamsElement.fromStanza(XmppElement stanza)
      : super.fromStanza(stanza);

  CallExtraParamsElement() : super();

  Set<int> getOpponents() {
    Set<int> result = {};

    XmppElement? opponentsElement = getChild(SignalField.OPPONENTS);

    if (opponentsElement != null) {
      for (XmppElement child in opponentsElement.children) {
        if (child.name == SignalField.OPPONENT) {
          if (child.textValue != null) {
            result.add(int.parse(child.textValue!));
          }
        }
      }
    }

    return result;
  }

  void setOpponents(Set<int> opponentsIds) {
    CubeXmppElementBase opponentsElement = CubeXmppElementBase();
    opponentsElement.name = SignalField.OPPONENTS;

    for (int opponentId in opponentsIds) {
      CubeXmppElementBase child = CubeXmppElementBase();
      child.name = SignalField.OPPONENT;
      child.textValue = opponentId.toString();
      opponentsElement.addChild(child);
    }

    addChild(opponentsElement);
  }

  Map<String, String> getUserInfo() {
    Map<String, String> result = {};

    XmppElement? userInfoElement = getChild(SignalField.USER_INFO);

    if (userInfoElement != null) {
      for (XmppElement child in userInfoElement.children) {
        if (child.name != null && child.textValue != null) {
          result[child.name!] = child.textValue!;
        }
      }
    }

    return result;
  }

  void setUserInfo(Map<String, String>? userInfo) {
    if (userInfo?.isEmpty ?? true) return;

    XmppElement userInfoElement = XmppElement();
    userInfoElement.name = SignalField.USER_INFO;

    for (String param in userInfo!.keys) {
      XmppElement child = XmppElement();
      child.name = param;
      child.textValue = userInfo[param]!;
      userInfoElement.addChild(child);
    }

    addChild(userInfoElement);
  }

  List<RTCIceCandidate> getIceCandidates() {
    List<RTCIceCandidate> result = [];

    XmppElement? candidatesElement = getChild(SignalField.CANDIDATES);

    if (candidatesElement != null) {
      for (XmppElement child in candidatesElement.children) {
        late String? candidate;
        late String? sdpMid;
        late int? sdpMLineIndex;
        for (XmppElement candidateField in child.children) {
          if (candidateField.name == Candidate.CANDIDATE_DESC) {
            candidate = candidateField.textValue;
          } else if (candidateField.name == Candidate.SDP_MID) {
            sdpMid = candidateField.textValue;
          } else if (candidateField.name == Candidate.SDP_MLINE_INDEX) {
            if (candidateField.textValue != null) {
              sdpMLineIndex = int.parse(candidateField.textValue!);
            }
          }
        }

        result.add(RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
      }
    }

    return result;
  }

  RTCIceCandidate? getIceCandidate() {
    XmppElement? candidateElement = getChild(Candidate.CANDIDATE_DESC);
    XmppElement? sdpMidElement = getChild(Candidate.SDP_MID);
    XmppElement? sdpMLineIndexElement = getChild(Candidate.SDP_MLINE_INDEX);

    if (candidateElement == null &&
        sdpMidElement == null &&
        sdpMLineIndexElement == null) {
      return null;
    }

    String? candidate = candidateElement!.textValue;
    String? sdpMid = sdpMidElement!.textValue;
    int? sdpMLineIndex;
    if (sdpMLineIndexElement!.textValue != null) {
      sdpMLineIndex = int.parse(sdpMLineIndexElement.textValue!);
    }

    return RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);
  }

  void setIceCandidates(List<RTCIceCandidate> candidates) {
    XmppElement candidatesElement = XmppElement();
    candidatesElement.name = SignalField.CANDIDATES;

    for (RTCIceCandidate candidate in candidates) {
      XmppElement candidateElement = XmppElement();
      candidateElement.name = SignalField.CANDIDATE;

      XmppElement sdpMLineIndexChild = XmppElement();
      sdpMLineIndexChild.name = Candidate.SDP_MLINE_INDEX;
      sdpMLineIndexChild.textValue = candidate.sdpMLineIndex.toString();
      candidateElement.addChild(sdpMLineIndexChild);

      XmppElement sdpMidChild = XmppElement();
      sdpMidChild.name = Candidate.SDP_MID;
      sdpMidChild.textValue = candidate.sdpMid;
      candidateElement.addChild(sdpMidChild);

      XmppElement candidateDescChild = XmppElement();
      candidateDescChild.name = Candidate.CANDIDATE_DESC;
      candidateDescChild.textValue = candidate.candidate;
      candidateElement.addChild(candidateDescChild);

      candidatesElement.addChild(candidateElement);
    }

    addChild(candidatesElement);
  }
}
