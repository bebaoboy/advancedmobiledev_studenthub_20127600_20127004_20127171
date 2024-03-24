/// List of signal fields used for XMPP message assembling
class SignalField {
  /// Module identifier, to check message destination
  static const String MODULE_IDENTIFIER = "moduleIdentifier";

  /// One of message type from
  static const String MESSAGE_TYPE = "type";

  /// The initiator of message
  static const String FROM = "from";

  /// The recipient of message
  static const String TO = "to";

  /// See VideoChatSignalingType
  static const String SIGNALING_TYPE = "signalType";

  /// Unique id of current video chat session. All users of  same call chat have to use the same sessionID.
  /// Timestamp or UUID can be used as a sessionID value.
  static const String SESSION_ID = "sessionID";

  /// Type of call. Use 1 for video call, 2 for audio call
  static const String CALL_TYPE = "callType";

  /// Local session description, value of RTCSessionDescription.SDP
  /// property http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCSessionDescription ,
  /// obtained after ‘startAsAnswer’ call
  static const String SDP = "sdp";

  /// SDP type
  static const String SDP_TYPE = "sdpType";

  /// ios, android, web
  static const String PLATFORM = "platform";

  /// Current device orientation:
  /// - portrait,
  /// - portrait_upside_down,
  /// - landscape_left,
  /// - landscape_right
  static const String DEVICE_ORIENTATION = "device_orientation";

  /// Reason why you finish video call. Possible values:
  /// See Reason
  static const String STATUS = "status";

  /// Use for IceCandidate
  static const String CANDIDATE = "iceCandidate";

  /// Use for iceCandidates.
  static const String CANDIDATES = "iceCandidates";

  /// Use for multicast. Opponents list.
  static const String OPPONENTS = "opponentsIDs";

  /// Call opponent.
  static const String OPPONENT = "opponentID";

  /// Use for user additional info
  static const String CALLER = "callerID";

  /// Use for user additional info
  static const String USER_INFO = "userInfo";

  /// Use for internal needs. For logging
  static const String VERSION_SDK = "version_sdk";
}

/// List of webrtc signals
class SignalCMD {
  /// Call - send this message if you would like to initiate a video call
  static const String CALL = "call";

  /// Accept - send this message if you would like to accept an incoming video call
  static const String ACCEPT_CALL = "accept";

  /// Reject -  send this message if you would like to reject incoming video call
  static const String REJECT_CALL = "reject";

  /// Send this message if you would like to stop current video call
  static const String HANG_UP = "hangUp";

  /// SendCandidate - send this message when new WebRTC candidates is available
  static const String CANDITATES = "iceCandidates";

  /// SendCandidate - send this message when new WebRTC candidate is available
  static const String CANDITATE = "iceCandidate";

  ///  Send this message if you want to add user in conversation
  static const String ADD_USER = "addUser";

  ///  Send this message if you want to remove user in conversation
  static const String REMOVE_USER = "removeUser";

  ///  Send this message if you want to update conversation
  static const String UPDATE = "update";
}

/// List of candidate fields
class Candidate {
  /// Candidate SDP_MLINE_INDEX received
  static const String SDP_MLINE_INDEX = "sdpMLineIndex";

  /// Candidate SDP_MID received
  static const String SDP_MID = "sdpMid";

  /// Candidate received
  static const String CANDIDATE_DESC = "candidate";
}

class CallType {
  static const VIDEO_CALL = 1;
  static const AUDIO_CALL = 2;
}
