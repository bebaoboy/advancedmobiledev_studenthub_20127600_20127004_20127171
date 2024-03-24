class ConferenceConfig {
  static final ConferenceConfig _instance = ConferenceConfig._internal();

  ConferenceConfig._internal();

  static ConferenceConfig get instance => _instance;

  String url = "";
  String protocol = "janus-protocol";
  String plugin = "janus.plugin.videoroom";
  int socketTimeOutMs = 10 * 1000;
  int keepAliveValueSec = 30;
}
