// ignore_for_file: implementation_imports

import 'package:dart_webrtc/src/media_stream_impl.dart';
import 'package:webrtc_interface/webrtc_interface.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

export 'platform_utils.dart';

Future<MediaStream> createMediaStream(String label) {
  final jsMs = html.MediaStream();
  return Future.value(MediaStreamWeb(jsMs, label));
}
