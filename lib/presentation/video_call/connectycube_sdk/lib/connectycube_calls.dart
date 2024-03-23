import 'src/calls/p2p/rest_api/calls_query.dart';

export 'package:flutter_webrtc/flutter_webrtc.dart';
export 'connectycube_core.dart';
export 'src/calls/p2p/p2p_client.dart';
export 'src/calls/p2p/p2p_session.dart';
export 'src/calls/conference/conference_client.dart';
export 'src/calls/conference/conference_session.dart';
export 'src/calls/conference/conference_config.dart';
export 'src/calls/call_client.dart';
export 'src/calls/call_session.dart';
export 'src/calls/signaling/janus_signaler.dart';
export 'src/calls/utils/cube_stats_reports_manager.dart';
export 'src/calls/utils/signaling_specifications.dart';
export 'src/calls/utils/rtc_media_config.dart';
export 'src/calls/utils/rtc_config.dart';
export 'src/calls/utils/widgets/screen_select_dialog.dart';

/// Sends the `reject` call signal via HTTP. It is useful in case when the used
/// doesn't have an active chat connection (for example from a Notification)
/// [callSessionId] - the id of the [P2PSession] session
/// [callMembers] - the ids of all call members including the caller and excluding
/// the current user
/// [platform] - the platform name the app ran on
/// [userInfo] - additional info about performed action
Future<void> rejectCall(
  String callSessionId,
  Set<int> callMembers, {
  String platform = 'flutter',
  Map<String, String>? userInfo,
}) {
  List<Future<void>> requests = [];
  callMembers.forEach((memberId) {
    requests.add(RejectCallQuery(
      callSessionId,
      memberId,
      platform,
      userInfo == null ? {} : userInfo,
    ).perform());
  });

  return Future.wait(requests);
}
