import '../../cube_session_manager.dart';
import '../../rest/query/query.dart';
import '../../rest/request/rest_request.dart';
import '../../rest/response/rest_response.dart';
import '../../utils/consts.dart';

class DeleteSessionQuery extends AutoManagedQuery<void> {
  late bool _exceptCurrent;

  DeleteSessionQuery({bool exceptCurrent = false}) {
    this._exceptCurrent = exceptCurrent;
  }

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    List<String> parts = List.of({AUTH_ENDPOINT});

    if (_exceptCurrent) {
      parts.add(USER_SESSION_ENDPOINT);
    }

    request.setUrl(buildQueryUrl(parts));
  }

  @override
  handleResponse(RestResponse response) {
    CubeSessionManager.instance.deleteActiveSession();
  }

  @override
  void processResult(String responseBody) {}

  @override
  bool isUserRequired() {
    return false;
  }

  @override
  bool isSessionRequired() {
    return _exceptCurrent;
  }
}
