import '../../rest/query/query.dart';
import '../../rest/request/rest_request.dart';
import '../../utils/consts.dart';

class ResetPasswordQuery extends AutoManagedQuery<void> {
  String _email;

  ResetPasswordQuery(this._email);

  @override
  setMethod(RestRequest request) {
    request.method = RequestMethod.GET;
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([USERS_ENDPOINT, PASSWORD, RESET]));
  }

  @override
  setParams(RestRequest request) {
    putValue(request.params, EMAIL, _email);
  }

  @override
  void processResult(String responseBody) {}
}
