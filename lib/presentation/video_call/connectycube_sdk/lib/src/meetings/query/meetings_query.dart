import 'dart:convert';

import '../../../connectycube_core.dart';

import '../models/cube_meeting.dart';

class GetMeetingsQuery extends AutoManagedQuery<List<CubeMeeting>> {
  Map<String, dynamic>? params;

  GetMeetingsQuery([this.params]);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([MEETINGS_ENDPOINT]));
  }

  @override
  setParams(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    if (params != null && params!.isNotEmpty) {
      for (String key in params!.keys) {
        putValue(parameters, key, params![key]);
      }
    }
  }

  @override
  List<CubeMeeting> processResult(String response) {
    if (params?.containsKey('_id') ?? false) {
      return List.of([CubeMeeting.fromJson(jsonDecode(response))]);
    } else {
      return List.from(jsonDecode(response))
          .map((element) => CubeMeeting.fromJson(element))
          .toList();
    }
  }
}

class GetMeetingsPagedQuery extends AutoManagedQuery<PagedResult<CubeMeeting>> {
  int limit;
  int skip;
  Map<String, dynamic>? params;

  GetMeetingsPagedQuery(this.limit, this.skip, {this.params});

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  void setHeaders(RestRequest request) {
    request.headers['CB-Api-Version'] = '2';
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([MEETINGS_ENDPOINT]));
  }

  @override
  setParams(RestRequest request) {
    Map<String, dynamic> parameters = request.params;
    parameters['limit'] = limit;
    parameters['offset'] = skip;

    if (params != null && params!.isNotEmpty) {
      for (String key in params!.keys) {
        putValue(parameters, key, params![key]);
      }
    }
  }

  @override
  PagedResult<CubeMeeting> processResult(String response) {
    return PagedResult<CubeMeeting>(
        response, (element) => CubeMeeting.fromJson(element));
  }
}

class CreateMeetingQuery extends AutoManagedQuery<CubeMeeting> {
  CubeMeeting cubeMeeting;

  CreateMeetingQuery(this.cubeMeeting);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.POST);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([MEETINGS_ENDPOINT]));
  }

  @override
  setBody(RestRequest request) {
    if (isValidMeeting(cubeMeeting)) {
      Map<String, dynamic> parameters = request.params;

      Map<String, dynamic> meetingToCreate = cubeMeeting.toCreateObjectJson();
      for (String key in meetingToCreate.keys) {
        parameters[key] = meetingToCreate[key];
      }
    }
  }

  @override
  CubeMeeting processResult(String response) {
    return CubeMeeting.fromJson(jsonDecode(response));
  }
}

class UpdateMeetingQuery extends AutoManagedQuery<CubeMeeting> {
  String meetingId;
  Map<String, dynamic> params;

  UpdateMeetingQuery(CubeMeeting cubeMeeting)
      : this.meetingId = cubeMeeting.meetingId!,
        this.params = cubeMeeting.toUpdateObjectJson();

  UpdateMeetingQuery.byId(this.meetingId, this.params);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.PUT);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([MEETINGS_ENDPOINT, meetingId]));
  }

  @override
  setBody(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    params.entries.forEach((element) {
      parameters[element.key] =  element.value;
    });
  }

  @override
  CubeMeeting processResult(String response) {
    return CubeMeeting.fromJson(jsonDecode(response));
  }
}

class DeleteMeetingQuery extends AutoManagedQuery<void> {
  String id;

  DeleteMeetingQuery(this.id);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([MEETINGS_ENDPOINT, id]));
  }

  @override
  void processResult(String response) {}
}

bool isValidMeeting(CubeMeeting cubeMeeting) {
  var errors = [];
  if (cubeMeeting.name?.isEmpty ?? true) {
    errors.add('\'name\' can not be null or empty');
  }

  if (cubeMeeting.attendees?.isEmpty ?? true) {
    errors.add('\'attendees\' can not be null or empty');
  } else {
    for (CubeMeetingAttendee attendee in cubeMeeting.attendees!) {
      if ((attendee.userId?.isNegative ?? true) &&
          (attendee.email?.isEmpty ?? true)) {
        errors.add(
            '\'userId\' or \'email\' is required for \'CubeMeetingAttendee\'');
        break;
      }
    }
  }

  if ((cubeMeeting.startDate?.isNegative ?? true) ||
      (cubeMeeting.endDate?.isNegative ?? true)) {
    errors.add(
        '\'startDate\' and \'endDate\' is required and must be greater than zero');
  }

  if (errors.isNotEmpty) {
    throw IllegalArgumentException('Error(s): ${errors.join(', ')}');
  } else {
    return true;
  }
}
