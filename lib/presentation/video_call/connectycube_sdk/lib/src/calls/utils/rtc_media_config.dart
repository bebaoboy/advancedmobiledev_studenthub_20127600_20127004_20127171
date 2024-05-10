import 'package:flutter/foundation.dart';

class RTCMediaConfig {
  static final RTCMediaConfig _instance = RTCMediaConfig._internal();

  RTCMediaConfig._internal();

  static RTCMediaConfig get instance => _instance;

  int minWidth = 1280;
  int minHeight = 720;
  int minFrameRate = 25;

  // the initial maximum bandwidth in kbps, set to 0 or null for disabling the limitation
  // change it during the call via `callSession.setMaxBandwidth(512)`
  int? maxBandwidth = 0;

  SimulcastConfig simulcastConfig = SimulcastConfig.optimal();
}

Map<String, dynamic> getVideoConfig({String? deviceId}) {
  RTCMediaConfig mediaConfig = RTCMediaConfig.instance;

  return {
    'width': mediaConfig.minWidth,
    'height': mediaConfig.minHeight,
    'frameRate': mediaConfig.minFrameRate,
    if (deviceId != null && kIsWeb) 'deviceId': deviceId,
    'facingMode': 'user',
    if (deviceId != null && !kIsWeb)
      'optional': [
        {'sourceId': deviceId}
      ],
  };
}

dynamic getAudioConfig({String? deviceId}) {
  if (deviceId == null) return true;

  if (kIsWeb) {
    return {'deviceId': deviceId};
  } else {
    return {
      'optional': [
        {'sourceId': deviceId}
      ],
    };
  }
}

class SimulcastConfig {
  int highVideoBitrate;
  int mediumVideoBitrate;
  int lowVideoBitrate;

  SimulcastConfig.optimal()
      : highVideoBitrate = 720,
        mediumVideoBitrate = 240,
        lowVideoBitrate = 80;

  SimulcastConfig(
      {required this.highVideoBitrate,
      required this.mediumVideoBitrate,
      required this.lowVideoBitrate});
}
