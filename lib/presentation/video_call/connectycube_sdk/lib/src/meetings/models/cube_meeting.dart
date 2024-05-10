import '../../../connectycube_core.dart';

class CubeMeeting extends CubeEntity {
  String? meetingId;
  String? name;
  int? startDate = -1;
  int? endDate = -1;
  List<CubeMeetingAttendee>? attendees;
  bool record = false;
  String? chatDialogId;
  int? hostId;
  bool withChat = false;

  // V2 fields
  bool public = false;
  bool scheduled = false;
  /// The notify feature is available starting from [Hobby plan](https://connectycube.com/pricing/)
  bool notify = false;
  /// The notify feature is available starting from [Hobby plan](https://connectycube.com/pricing/)
  CubeMeetingNotifyBefore? notifyBefore;

  CubeMeeting(
      {this.meetingId,
      this.name,
      this.startDate,
      this.endDate,
      this.attendees});

  CubeMeeting.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    meetingId = json['_id'];
    name = json['name'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    attendees = List.from(json['attendees'])
        .map((element) => CubeMeetingAttendee.fromJson(element))
        .toList();

    record = json['record'];
    chatDialogId = json['chat_dialog_id'];
    hostId = json['host_id'];
    public = json['public'] ?? false;
    scheduled = json['scheduled'] ?? false;
    notify = json['notify'] ?? false;

    var notifyBeforeObject = json['notify_before'];
    if (notifyBeforeObject != null) {
      notifyBefore = CubeMeetingNotifyBefore.fromJson(notifyBeforeObject);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['meetingId'] = meetingId;
    json['name'] = name;
    json['start_date'] = startDate;
    json['end_date'] = endDate;
    json['attendees'] = attendees;
    json['chat_dialog_id'] = chatDialogId;
    json['host_id'] = hostId;
    json['chat'] = withChat;
    json['record'] = record;
    json['public'] = public;
    json['scheduled'] = scheduled;
    json['notify'] = notify;
    json['notify_before'] = notifyBefore;

    return json;
  }

  Map<String, dynamic> toCreateObjectJson() => {
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
        'attendees': attendees,
        'chat': withChat,
        'record': record,
        'public': public,
        'scheduled': scheduled,
        'notify': notify,
        'notify_before': notifyBefore,
      };

  Map<String, dynamic> toUpdateObjectJson() => {
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
        'attendees': attendees,
        'record': record,
        'public': public,
        'scheduled': scheduled,
        'notify': notify,
        'notify_before': notifyBefore,
      };

  @override
  toString() => toJson().toString();
}

class CubeMeetingAttendee {
  int? userId = -1;
  String? email;

  CubeMeetingAttendee({this.userId, this.email});

  CubeMeetingAttendee.fromJson(Map<String, dynamic> json) {
    userId = json['id'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (userId != null) {
      json['id'] = userId;
    }

    if (email != null) {
      json['email'] = email;
    }

    return json;
  }

  @override
  toString() => toJson().toString();
}

class CubeMeetingNotifyBefore {
  TimeMetric metric;
  int value;

  CubeMeetingNotifyBefore(this.metric, this.value);

  CubeMeetingNotifyBefore.fromJson(Map<String, dynamic> json)
      : metric = metricFromString(json['metric']),
        value = json['value'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'metric': metric.name.toLowerCase(),
      'value': value
    };

    return json;
  }

  @override
  toString() => toJson().toString();
}

enum TimeMetric { MINUTES, HOURS, DAYS, WEEKS }

TimeMetric metricFromString(String metricString) {
  switch (metricString) {
    case 'minutes':
      return TimeMetric.MINUTES;
    case 'hours':
      return TimeMetric.HOURS;
    case 'days':
      return TimeMetric.DAYS;
    case 'weeks':
      return TimeMetric.WEEKS;
    default:
      return TimeMetric.HOURS;
  }
}
