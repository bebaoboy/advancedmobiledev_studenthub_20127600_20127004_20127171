import 'dart:convert';

import 'package:intl/intl.dart';

import '../../../connectycube_core.dart';

import '../models/cube_dialog.dart';
import '../models/cube_message.dart';

class GlobalSearchQuery extends AutoManagedQuery<GlobalSearchResult> {
  String searchText;
  Map<String, dynamic>? params;

  GlobalSearchQuery(this.searchText, [this.params]);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([CHAT_ENDPOINT, SEARCH_ENDPOINT]));
  }

  @override
  setParams(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    putValue(parameters, "search_text", searchText);

    if (params != null && params!.isNotEmpty) {
      params!.forEach((key, value) {
        putValue(parameters, key, value);
      });
    }
  }

  @override
  GlobalSearchResult processResult(String response) {
    return GlobalSearchResult.fromJson(jsonDecode(response));
  }
}

class GlobalSearchParams {
  List<String> dialogIds = [];
  DateTime? startDate;
  DateTime? endDate;
  int? limit;

  Map<String, dynamic> getSearchParams() {
    Map<String, dynamic> params = {};

    if (dialogIds.isNotEmpty) {
      params['chat_dialog_ids'] = dialogIds.join(",");
    }

    if (startDate != null) {
      if (endDate == null) {
        throw IllegalArgumentException(
            "'endDate' is required if 'startDate' passed");
      }
      params['start_date'] =
          DateFormat(SEARCH_CHAT_DATE_FORMAT).format(startDate!);
    }

    if (endDate != null) {
      log("endDate = $endDate");
      params['end_date'] = DateFormat(SEARCH_CHAT_DATE_FORMAT).format(endDate!);
    }

    if (limit != null && limit! > 0) {
      params['limit'] = limit;
    }

    return params;
  }
}

class GlobalSearchResult {
  List<CubeUser> users = [];
  List<CubeDialog> dialogs = [];
  List<CubeMessage> messages = [];

  GlobalSearchResult.fromJson(Map<String, dynamic> json) {
    var dialogsRaw = json['dialogs'];
    if (dialogsRaw != null && dialogsRaw.isNotEmpty) {
      dialogs = List.of(dialogsRaw)
          .map((element) => CubeDialog.fromJson(element))
          .toList();
    }

    var usersRaw = json['users'];
    if (usersRaw != null && usersRaw.isNotEmpty) {
      users = List.of(usersRaw)
          .map((element) => CubeUser.fromJson(element))
          .toList();
    }

    var messagesRaw = json['messages'];
    if (messagesRaw != null && messagesRaw.isNotEmpty) {
      messages = List.of(messagesRaw)
          .map((element) => CubeMessage.fromJson(element))
          .toList();
    }
  }

  @override
  String toString() {
    return "{"
        "users: $users, "
        "dialogs: $dialogs,"
        "messages: $messages"
        "}";
  }
}
