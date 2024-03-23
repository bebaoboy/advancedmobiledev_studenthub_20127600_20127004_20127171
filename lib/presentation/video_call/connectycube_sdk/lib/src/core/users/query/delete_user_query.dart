import '../../rest/query/query.dart';
import '../../rest/request/rest_request.dart';
import '../../utils/consts.dart';

class DeleteUserQuery extends AutoManagedQuery<void> {
  int? _userId;
  int? _externalId;

  DeleteUserQuery.byId(this._userId);

  DeleteUserQuery.byExternalId(this._externalId);

  @override
  setMethod(RestRequest request) {
    request.method = RequestMethod.DELETE;
  }

  @override
  setUrl(RestRequest request) {
    if (_userId != null) {
      request.setUrl(buildQueryUrl([USERS_ENDPOINT, _userId]));
    } else {
      request.setUrl(buildQueryUrl([USERS_ENDPOINT, EXTERNAL_ID, _externalId]));
    }
  }

  @override
  void processResult(String responseBody) {}
}
