import 'dart:convert';

import '../models/cube_user.dart';
import '../../rest/query/query.dart';
import '../../rest/request/request_help_models.dart';
import '../../rest/request/rest_request.dart';
import '../../rest/response/paged_result.dart';
import '../../utils/consts.dart';
import '../../utils/string_utils.dart';

class GetUsersQuery extends AutoManagedQuery<PagedResult<CubeUser>> {
  String? _identifierName;
  String? _identifierValue;

  RequestFilter? _filter;
  RequestSorter? _sorter;

  Map<String, dynamic>? _additionalParams;

  GetUsersQuery.byIdentifier(this._identifierName, this._identifierValue,
      [this._additionalParams]);

  GetUsersQuery.byFilter([this._filter, this._sorter, this._additionalParams]);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    if (!isEmpty(_identifierName) && !isEmpty(_identifierValue)) {
      request.setUrl(
          buildQueryUrl([USERS_ENDPOINT, FILTER_PREFIX + _identifierName!]));
    } else {
      request.setUrl(buildQueryUrl([USERS_ENDPOINT]));
    }
  }

  @override
  setParams(RestRequest request) {
    super.setParams(request);

    Map<String, dynamic> parameters = request.params;

    if (!isEmpty(_identifierName) && !isEmpty(_identifierValue)) {
      putValue(parameters, _identifierName!, _identifierValue);
    } else {
      if (_filter != null) {
        putValue(parameters, FILTER_PARAM_NAME,
            "${_filter!.fieldType} ${_filter!.fieldName} ${_filter!.rule} ${_filter!.fieldValue}");
      }

      if (_sorter != null) {
        putValue(parameters, ORDER_PARAM_NAME,
            "${_sorter!.sortType} ${_sorter!.fieldType} ${_sorter!.fieldName}");
      }
    }

    if (_additionalParams != null && _additionalParams!.isNotEmpty) {
      _additionalParams!.forEach((key, value) {
        putValue(parameters, key, value);
      });
    }
  }

  @override
  PagedResult<CubeUser> processResult(String response) {
    return PagedResult<CubeUser>(
        response, (element) => CubeUser.fromJson(element['user']));
  }
}

class GetUserQuery extends AutoManagedQuery<CubeUser> {
  int? _userId;

  String? _identifierName;
  String? _identifierValue;

  int? _externalId;

  GetUserQuery.byId(this._userId);

  GetUserQuery.byIdentifier(this._identifierName, this._identifierValue);

  GetUserQuery.byExternal(this._externalId);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    if (_userId != null) {
      request.setUrl(buildQueryUrl([USERS_ENDPOINT, _userId]));
    } else if (!isEmpty(_identifierName) && !isEmpty(_identifierValue)) {
      request.setUrl(
          buildQueryUrl([USERS_ENDPOINT, FILTER_PREFIX + _identifierName!]));
    } else if (_externalId != null) {
      request.setUrl(buildQueryUrl([USERS_ENDPOINT, EXTERNAL_ID, _externalId]));
    }
  }

  @override
  setParams(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    if (!isEmpty(_identifierName)) {
      putValue(parameters, _identifierName!, _identifierValue);
    }
  }

  @override
  CubeUser processResult(String response) {
    Map<String, dynamic> res = jsonDecode(response);

    return CubeUser.fromJson(res['user']);
  }
}
