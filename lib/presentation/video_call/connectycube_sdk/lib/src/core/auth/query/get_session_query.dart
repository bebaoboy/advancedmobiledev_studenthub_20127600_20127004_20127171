import 'dart:convert';

import '../models/cube_session.dart';
import '../../rest/query/query.dart';
import '../../rest/request/rest_request.dart';
import '../../utils/consts.dart';

class GetSessionQuery extends AutoManagedQuery<CubeSession> {
  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([AUTH_ENDPOINT]));
  }

  @override
  CubeSession processResult(String response) {
    Map<String, dynamic> res = jsonDecode(response);

    return CubeSession.fromJson(res['session']);
  }

  @override
  bool isUserRequired() {
    return false;
  }
}
