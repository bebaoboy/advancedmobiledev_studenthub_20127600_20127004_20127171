import 'dart:convert';

import '../../../connectycube_core.dart';

import '../models/cube_event.dart';

class CreateEventQuery extends AutoManagedQuery<List<CubeEvent>> {
  CubeEvent event;

  CreateEventQuery(this.event);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.POST);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([EVENTS_ENDPOINT]));
  }

  @override
  setBody(RestRequest request) {
    Map<String, dynamic>? eventParams = event.message;
    if (eventParams == null || !eventParams.containsKey('message')) {
      throw IllegalArgumentException(
          "'message' parameter is required for event");
    }

    Map<String?, dynamic> parameters = request.params;

    List<int> bytes = utf8.encode(jsonEncode(eventParams));
    String base64Str = base64.encode(bytes);

    Map<String, dynamic> eventJson = event.toJson();
    eventJson['message'] = base64Str;

    parameters['event'] = eventJson;
  }

  @override
  List<CubeEvent> processResult(String response) {
    List<dynamic> items = jsonDecode(response);

    return items
        .map((element) => CubeEvent.fromJson(element['event']))
        .toList();
  }
}

class CreateEventParams {
  Map<String, dynamic> parameters = {};
  String? notificationType;
  String? environment;
  String? eventType;
  List<int?> usersIds = [];
  List<int> externalUsersIds = [];
  List<String> usersTagsAll = [];
  List<String> usersTagsAny = [];
  List<String> usersTagsExclude = [];
  int? date;
  int? endDate;
  int? period;
  String? name;

  CubeEvent getEventForRequest() {
    //log(toString());

    if (parameters.isEmpty ||
        !parameters.containsKey('message') ||
        isEmpty(notificationType) ||
        isEmpty(environment) ||
        ((date == null || date == 0) &&
            (eventType != null &&
                (PushEventType.FIXED_DATE == eventType ||
                    PushEventType.PERIOD_DATE == eventType))) ||
        ((period == null || period == 0) &&
            PushEventType.PERIOD_DATE == eventType) ||
        (usersIds.isEmpty &&
            externalUsersIds.isEmpty &&
            usersTagsAll.isEmpty &&
            usersTagsAny.isEmpty &&
            usersTagsExclude.isEmpty)) {
      throw IllegalArgumentException("Not filled all required fields");
    }

    CubeEvent event = CubeEvent();
    event.message = parameters;
    event.name = name;
    event.notificationType = notificationType;
    event.environment = environment;
    if (!isEmpty(eventType)) event.eventType = eventType;

    if (date != null) event.date = date;
    if (endDate != null) event.endDate = endDate;
    if (period != null) event.period = period;

    EventUserTags usersTags = EventUserTags();
    usersTags.any = usersTagsAny;
    usersTags.all = usersTagsAll;
    usersTags.exclude = usersTagsExclude;

    EventUser eventUser = EventUser();

    if (usersIds.isNotEmpty) {
      eventUser.ids = usersIds;
    }

    if (usersTags.toJson().isNotEmpty) {
      eventUser.tags = usersTags;
    }

    event.eventUser = eventUser;

    if (externalUsersIds.isNotEmpty) {
      BaseEventUser externalUser = BaseEventUser();
      externalUser.ids = externalUsersIds;
      event.externalUser = externalUser;
    }

    return event;
  }

  @override
  toString() {
    return "{"
        "parameters: $parameters, "
        "notificationType: $notificationType, "
        "environment: $environment, "
        "eventType: $eventType, "
        "usersIds: $usersIds, "
        "externalUsersIds: $externalUsersIds, "
        "usersTagsAll: $usersTagsAll, "
        "usersTagsAny: $usersTagsAny, "
        "usersTagsExclude: $usersTagsExclude, "
        "date: $date, "
        "endDate: $endDate, "
        "period: $period, "
        "name: $name"
        "}";
  }
}
