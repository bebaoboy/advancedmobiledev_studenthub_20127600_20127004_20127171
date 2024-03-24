import '../signaling/janus_signaler.dart';
import 'package:uuid/uuid.dart';

class CubeRTCSessionDescription {
  /// Unique identifier
  late String sessionId;

  /// Conference maker
  int callerId;

  /// Set of opponents ids
  Set<int> opponents;

  /// Conference type
  int conferenceType;

  /// Additional api user info.
  /// Added and parse on api client's side.
  /// Could be use for additional chat participant's data exchange and extending SDK api functionality
  /// on client's side.
  Map<String, String>? userInfo;

  CubeRTCSessionDescription.withSession(
      this.sessionId, this.callerId, this.opponents, this.conferenceType,
      [this.userInfo]);

  CubeRTCSessionDescription(this.callerId, this.opponents, this.conferenceType,
      [this.userInfo]) {
    this.sessionId = Uuid().v4();
  }

  @override
  String toString() {
    return "CubeRTCSessionDescription: "
        "{"
        "sessionId = $sessionId, "
        "callerId = $callerId, "
        "opponents = $opponents, "
        "conferenceType = $conferenceType, "
        "userInfo = $userInfo"
        "}";
  }
}

class CubeConferenceSessionDescription {
  String? dialogID;
  int conferenceType;
  ConferenceRole? conferenceRole;

  CubeConferenceSessionDescription(this.conferenceType);
}
