// ignore_for_file: implementation_imports

import 'package:web/web.dart' as web;
import 'package:dart_webrtc/src/media_stream_impl.dart';
import 'package:webrtc_interface/webrtc_interface.dart';
// ignore: avoid_web_libraries_in_flutter

export 'platform_utils.dart';

Future<MediaStream> createMediaStream(String label) {
  final jsMs = web.MediaStream();
  return Future.value(MediaStreamWeb(jsMs, label));
}
