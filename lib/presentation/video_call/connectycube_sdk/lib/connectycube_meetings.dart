import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/src/core/rest/response/paged_result.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/src/meetings/models/cube_meeting.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/src/meetings/query/meetings_query.dart';

export 'connectycube_core.dart';

/// Creates new `CubeMeeting` model on the backend.
/// More details about required parameters by [link](https://developers.connectycube.com/server/meetings?id=parameters)
///
/// [meeting] - the instance of `CubeMeeting` which will be created on the backend.
Future<CubeMeeting> createMeeting(CubeMeeting meeting) {
  return CreateMeetingQuery(meeting).perform();
}

/// Returns meeting according to your [params]
/// More details about possible criteria of filtering by [link](https://developers.connectycube.com/server/meetings?id=parameters-1)
/// Note: function can return a maximum of 100 items, use [getMeetingsPaged] for getting more using the pagination feature
Future<List<CubeMeeting>> getMeetings([Map<String, dynamic>? params]) {
  return GetMeetingsQuery(params).perform();
}

/// Returns meetings according to your [params] using the pagination feature
/// More details about possible criteria of filtering by [link](https://developers.connectycube.com/server/meetings?id=parameters-1)
Future<PagedResult<CubeMeeting>> getMeetingsPaged(
    {int limit = 100, int skip = 0, Map<String, dynamic>? params}) {
  return GetMeetingsPagedQuery(limit, skip, params: params).perform();
}

/// Updates the exist meeting.
/// More details about required parameters by [link](https://developers.connectycube.com/server/meetings?id=parameters-2)
///
/// [meeting] - the updated meeting. It should contain `meetingId` of original object.
Future<CubeMeeting> updateMeeting(CubeMeeting meeting) {
  return UpdateMeetingQuery(meeting).perform();
}

/// Updates the exist meeting.
/// More details about required parameters by [link](https://developers.connectycube.com/server/meetings?id=parameters-2)
///
/// [meetingId] - the id of the meeting you want to update.
/// [params] - the parameters you want to update in the meeting with [meetingId].
Future<CubeMeeting> updateMeetingById(
    String meetingId, Map<String, dynamic> params) {
  return UpdateMeetingQuery.byId(meetingId, params).perform();
}

/// Deletes the meeting record by [id] on the backend.
Future<void> deleteMeeting(String id) {
  return DeleteMeetingQuery(id).perform();
}
