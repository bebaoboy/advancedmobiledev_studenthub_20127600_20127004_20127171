import '../../../../connectycube_core.dart';

class RejectCallQuery extends AutoManagedQuery<void> {
  String sessionId;
  int callerId;
  String platform;
  Map<String, String> userInfo = {};

  RejectCallQuery(this.sessionId, this.callerId, this.platform, this.userInfo);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.POST);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([CALLS_ENDPOINT, "reject"]));
  }

  @override
  setBody(RestRequest request) {
    if (isEmpty(sessionId)) {
      throw IllegalArgumentException("'sessionId' can not by null or empty");
    }

    if (callerId <= 0) {
      throw IllegalArgumentException(
          "'callerId' can not be equal or less than 0");
    }

    Map<String, dynamic> parameters = request.params;
    parameters['sessionID'] = sessionId;
    parameters['recipientId'] = callerId;
    parameters['platform'] = platform;

    if (userInfo.isNotEmpty) {
      parameters['userInfo'] = userInfo;
    }
  }

  @override
  void processResult(String response) {}
}
