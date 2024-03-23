export 'connectycube_core.dart';

export 'src/push_notifications/models/cube_event.dart';
export 'src/push_notifications/models/cube_subscription.dart';

export 'src/push_notifications/query/events_query.dart';
export 'src/push_notifications/query/subscriptions_query.dart';

import 'src/push_notifications/models/cube_event.dart';
import 'src/push_notifications/models/cube_subscription.dart';
import 'src/push_notifications/query/events_query.dart';
import 'src/push_notifications/query/subscriptions_query.dart';

/// [params] - additional parameters for request. Use class-helper [CreateSubscriptionParameters] to simple config request
///
Future<List<CubeSubscription>> createSubscription(Map<String, dynamic> params) {
  return CreateSubscriptionQuery(params).perform();
}

Future<List<CubeSubscription>> getSubscriptions() {
  return GetSubscriptionsQuery().perform();
}

Future<void> deleteSubscription(int subscriptionId) {
  return DeleteSubscriptionQuery(subscriptionId).perform();
}

/// [event] - new event to creation. Use class-helper [CreateEventParams]] to simple creation of new instance of event
///
Future<List<CubeEvent>> createEvent(CubeEvent event) {
  return CreateEventQuery(event).perform();
}
