import 'dart:convert';

import '../models/cube_user.dart';
import '../../rest/query/query.dart';
import '../../rest/request/rest_request.dart';
import '../../utils/consts.dart';

class UpdateUserQuery extends AutoManagedQuery<CubeUser> {
  CubeUser _user;

  UpdateUserQuery(this._user);

  @override
  setMethod(RestRequest request) {
    request.method = RequestMethod.PUT;
  }

  @override
  setBody(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    Map<String, dynamic> userWithoutBlankFields = Map();

    for (String key in _user.toJson().keys) {
      if (_user.toJson()[key] != null) {
        userWithoutBlankFields[key] = _user.toJson()[key];
      }
    }

    parameters['user'] = userWithoutBlankFields;
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([USERS_ENDPOINT, _user.id]));
  }

  @override
  CubeUser processResult(String response) {
    Map<String, dynamic> res = jsonDecode(response);

    return CubeUser.fromJson(res['user']);
  }
}
