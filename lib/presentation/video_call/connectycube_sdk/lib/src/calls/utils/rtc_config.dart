class RTCConfig {
  static final RTCConfig _instance = RTCConfig._internal();

  RTCConfig._internal();

  static RTCConfig get instance => _instance;

  static const int _defaultDillingTimeInterval = 3;
  static const int _defaultNoAnswerTimeout = 60;

  int dillingTimeInterval = _defaultDillingTimeInterval;
  int noAnswerTimeout = _defaultNoAnswerTimeout;

  int get defaultDillingTimeInterval => _defaultDillingTimeInterval;
  int get defaultNoAnswerTimeout => _defaultNoAnswerTimeout;

  int statsReportsInterval = 0;
}
