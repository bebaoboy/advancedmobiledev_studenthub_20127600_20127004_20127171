import 'package:flutter_webrtc/flutter_webrtc.dart';

export 'platform_utils.dart';

Future<MediaStream> createMediaStream(String label) {
  return createLocalMediaStream(label);
}
