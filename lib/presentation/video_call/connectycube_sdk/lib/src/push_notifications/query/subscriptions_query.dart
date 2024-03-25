import 'dart:convert';

import '../../../connectycube_core.dart';

import '../models/cube_subscription.dart';

class CreateSubscriptionQuery extends AutoManagedQuery<List<CubeSubscription>> {
  Map<String, dynamic> params;

  CreateSubscriptionQuery(this.params);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.POST);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([SUBSCRIPTIONS_ENDPOINT]));
  }

  @override
  setBody(RestRequest request) {
    Map<String, dynamic> parameters = request.params;
    parameters.addAll(params);
  }

  @override
  List<CubeSubscription> processResult(String response) {
    List<dynamic> items = jsonDecode(response);

    return items
        .map((element) => CubeSubscription.fromJson(element['subscription']))
        .toList();
  }
}

class GetSubscriptionsQuery extends AutoManagedQuery<List<CubeSubscription>> {
  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([SUBSCRIPTIONS_ENDPOINT]));
  }

  @override
  List<CubeSubscription> processResult(String response) {
    List<dynamic> items = jsonDecode(response);

    return items
        .map((element) => CubeSubscription.fromJson(element['subscription']))
        .toList();
  }
}

class DeleteSubscriptionQuery extends AutoManagedQuery<void> {
  int subscriptionId;

  DeleteSubscriptionQuery(this.subscriptionId);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([SUBSCRIPTIONS_ENDPOINT, subscriptionId]));
  }

  @override
  void processResult(String response) {}
}

class CreateSubscriptionParameters {
  String? environment;
  String? channel;
  String? udid;
  String? platform;
  String? pushToken;
  String? bundleIdentifier;

  Map<String, dynamic> getRequestParameters() {
    if (isEmpty(environment) ||
        isEmpty(channel) ||
        isEmpty(udid) ||
        isEmpty(platform) ||
        isEmpty(pushToken)) {
      throw IllegalArgumentException(
          "Some required parameters are empty or null");
    }

    Map<String, dynamic> result = {};

    CubeDeviceModel device = CubeDeviceModel(udid, platform);
    PushToken token = PushToken(environment, pushToken, bundleIdentifier);

    result['notification_channel'] = channel;
    result['device'] = device;
    result['push_token'] = token;

    return result;
  }
}
