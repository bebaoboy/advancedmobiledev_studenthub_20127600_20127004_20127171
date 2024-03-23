import 'dart:convert';

import '../../../connectycube_core.dart';

class CubeEvent extends CubeEntity {
  String? notificationType;
  String? environment;
  String? eventType;
  int? date;
  int? period;
  String? name;
  int? occuredCount;
  int? endDate;
  bool? active;
  int? applicationId;
  int? userId;
  String? kind;
  String? notificationChannel;
  String? tagQuery;
  Map<String, dynamic>? message;
  EventUser? eventUser;
  BaseEventUser? externalUser;

  CubeEvent();

  CubeEvent.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    notificationChannel = json['notification_channel']['name'];
    eventType = json['event_type'];
    message = _decodeMessage(json['message'], notificationChannel);
    date = json['date'];
    period = json['period'];
    name = json['name'];
    occuredCount = json['occured_count'];
    endDate = json['end_date'];
    active = json['active'];
    applicationId = json['application_id'];
    userId = json['user_id'];
    kind = json['kind'];
    environment = json['environment'];
    tagQuery = json['tag_query'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      ...super.toJson(),
      'notification_type': notificationType,
      'environment': environment,
      'message': message
    };

    if (!isEmpty(eventType)) result['event_type'] = eventType;
    if (!isEmpty(name)) result['name'] = name;
    if (date != null) result['date'] = date;
    if (endDate != null) result['end_date'] = endDate;
    if (period != null) result['period'] = period;

    if (eventUser != null && eventUser!.toJson().isNotEmpty) {
      result['user'] = eventUser;
    }

    if (externalUser != null && externalUser!.toJson().isNotEmpty) {
      result['external_user'] = externalUser;
    }

    if (!isEmpty(notificationChannel))
      result['notification_channel'] = notificationChannel;
    if (userId != null) result['user_id'] = userId;

    return result;
  }

  @override
  toString() => toJson().toString();
}

Map<String, dynamic> _decodeMessage(String? json, String? channelName) {
  String decodedJson = String.fromCharCodes(base64Decode(json!));

  return jsonDecode(decodedJson);
}

class BaseEventUser {
  List<int?>? ids;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = Map();
    if (ids != null && ids!.isNotEmpty) {
      result['ids'] = ids!.join(',');
    }

    return result;
  }
}

class EventUser extends BaseEventUser {
  EventUserTags? tags;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = super.toJson();
    if (tags != null && tags!.toJson().isNotEmpty) {
      result['tags'] = tags;
    }
    return result;
  }
}

class EventUserTags {
  List<String>? any;
  List<String>? all;
  List<String>? exclude;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = Map();
    if (any != null && any!.isNotEmpty) {
      result['any'] = any!.join(',');
    }

    if (all != null && all!.isNotEmpty) {
      result['all'] = all!.join(',');
    }

    if (exclude != null && exclude!.isNotEmpty) {
      result['exclude'] = exclude!.join(',');
    }

    return result;
  }
}
