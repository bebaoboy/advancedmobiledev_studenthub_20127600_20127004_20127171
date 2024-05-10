const String HEADER_FRAMEWORK_VERSION = "CB-SDK";
const String HEADER_FRAMEWORK_VERSION_VALUE_PREFIX = "Flutter";
const String HEADER_TOKEN_EXPIRATION_DATE = "CB-Token-ExpirationDate";
const String HEADER_TOKEN = "CB-Token";
const String HEADER_API_VERSION = "ConnectyCube-REST-API-Version";

const String PREFIX_CHAT_RESOURCE = "flutter";

const String TOKEN_EXPIRATION_DATE_FORMAT = "yyyy-MM-dd HH:mm:ss z";
const String SEARCH_CHAT_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'";

const String REST_API_VERSION = "0.1.1";
const String REQUEST_FORMAT = ".json";

const String AUTH_ENDPOINT = "session";
const String SIGNIN_ENDPOINT = "login";
const String USERS_ENDPOINT = "users";
const String USERS_V2_ENDPOINT = "users/v2";
const String ADDRESS_BOOK_ENDPOINT = "address_book";
const String REGISTERED_USERS_ENDPOINT = "registered_users";
const String CHAT_ENDPOINT = "chat";
const String DIALOG_ENDPOINT = "Dialog";
const String SEARCH_ENDPOINT = "search";
const String MESSAGE_ENDPOINT = "Message";
const String SYSTEM_MESSAGE_ENDPOINT = "Message/system";
const String SUBSCRIPTIONS_ENDPOINT = "subscriptions";
const String EVENTS_ENDPOINT = "events";
const String BLOBS_ENDPOINT = "blobs";
const String DATA_ENDPOINT = "data";
const String WHITEBOARDS_ENDPOINT = "whiteboards";
const String MEETINGS_ENDPOINT = "meetings";
const String CALLS_ENDPOINT = "calls";
const String REACTIONS_ENDPOINT = "reactions";

const String SIGNATURE = "signature";
const String APP_ID = "application_id";
const String TIMESTAMP = "timestamp";
const String NONCE = "nonce";
const String AUTH_KEY = "auth_key";

const String USER_LOGIN = "user[login]";
const String USER_PASSWORD = "user[password]";
const String USER_EMAIL = "user[email]";
const String USER_GUEST = "user[guest]";
const String USER_FULL_NAME = "user[full_name]";

const String PROVIDER = "provider";

const String KEYS_TOKEN = "keys[token]";
const String KEYS_SECRET = "keys[secret]";

const String FIREBASE_PHONE_TOKEN = "firebase_phone[access_token]";
const String FIREBASE_PHONE_PROJECT_ID = "firebase_phone[project_id]";
const String FIREBASE_EMAIL_TOKEN = "firebase_email[access_token]";
const String FIREBASE_EMAIL_PROJECT_ID = "firebase_email[project_id]";
const String USER_SESSION_ENDPOINT = "list";

const String FILTER_PARAM_NAME = "filter[]";
const String ORDER_PARAM_NAME = "order";

const String PASSWORD = "password";
const String EMAIL = "email";
const String RESET = "reset";

const String CONTACTS = "contacts";
const String COMPACT = "compact";

const String FORCE = "force";

const String UDID = "udid";

const String FILTER_PREFIX = "by_";
const String FILTER_ID = 'id';
const String FILTER_FULL_NAME = "full_name";
const String FILTER_TAGS = "tags";
const String FILTER_USER_TAGS = "user_tags";
const String FILTER_LOGIN = "login";
const String FILTER_EMAIL = "email";
const String FILTER_FACEBOOK_ID = "facebook_id";
const String FILTER_TWITTER_ID = "twitter_id";
const String EXTERNAL_ID = "external";
const String EXTERNAL_USER_ID = "external_id";
const String FILTER_PHONE = "phone";

const String BY_CRITERIA = "by_criteria";

const String LIMIT = 'limit';
const String OFFSET = 'offset';

class CubeProvider {
  static const String FACEBOOK = "facebook";
  static const String TWITTER = "twitter";
  static const String FIREBASE_PHONE = "firebase_phone";
  static const String FIREBASE_EMAIL = "firebase_email";
}

class RequestFieldType {
  static const String NUMBER = "number";
  static const String STRING = "string";
  static const String DATE = "date";
}

class QueryRule {
  static const String GT = "gt";
  static const String GTE = "gte";
  static const String LT = "lt";
  static const String GE = "ge";
  static const String LE = "le";
  static const String LTE = "lte";
  static const String EQ = "eq";
  static const String NE = "ne";
  static const String IN = "in";
  static const String NIN = "nin";
  static const String START_WITH = "start_with";
  static const String BETWEEN = "between";
}

class OrderType {
  static const String ASC = "asc";
  static const String DESC = "desc";
}

class NotificationsChannels {
  static const String APNS = "apns";
  static const String APNS_VOIP = "apns_voip";
  static const String GCM = "gcm";
}

class CubeEnvironment {
  static const String DEVELOPMENT = "development";
  static const String PRODUCTION = "production";
}

class CubePlatform {
  static const String IOS = "ios";
  static const String ANDROID = "android";
}

class CubeNotificationType {
  static const String PUSH = "push";
  static const String EMAIL = "email";
}

class PushEventType {
  static const String FIXED_DATE = "fixed_date";
  static const String PERIOD_DATE = "period_date";
  static const String ONE_SHOT = "one_shot";
}
