import 'package:collection/collection.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../connectycube_core.dart';
import '../peer_connection.dart';
import '../utils/rtc_media_config.dart';

class ConferencePeerConnection extends PeerConnection {
  static const TAG = 'ConferencePeerConnection';

  ConferencePeerConnection(
      int userId, CubePeerConnectionStateCallback peerConnectionStateCallback)
      : super(userId, peerConnectionStateCallback, false);

  @override
  void setMediaStream(RTCPeerConnection pc, MediaStream? mediaStream) {
    if (mediaStream == null) return;

    MediaStreamTrack? videoTrack = mediaStream.getVideoTracks().firstOrNull;

    if (videoTrack != null) {
      var sendEncodings = getVideoEncodings();

      RTCRtpTransceiverInit initVideo = RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendOnly,
        streams: [mediaStream],
        sendEncodings: sendEncodings,
      );

      pc.addTransceiver(
        track: videoTrack,
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: initVideo,
      );
    }

    MediaStreamTrack? audioTrack = mediaStream.getAudioTracks().firstOrNull;

    if (audioTrack != null) {
      RTCRtpTransceiverInit initAudio = RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendOnly,
        streams: [mediaStream],
      );

      pc.addTransceiver(
        track: audioTrack,
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: initAudio,
      );
    }
  }

  @override
  Future<RTCRtpSender> addTrack(
      MediaStreamTrack track, MediaStream? mediaStream) {
    if (mediaStream == null) {
      return Future.error(IllegalStateException(
          'Can\'t add the track to the null media stream'));
    }

    if (track.kind == 'video') {
      var sendEncodings = getVideoEncodings();

      RTCRtpTransceiverInit initVideo = RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendOnly,
        streams: [mediaStream],
        sendEncodings: sendEncodings,
      );

      return peerConnection
              ?.addTransceiver(
            track: track,
            kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
            init: initVideo,
          )
              .then((transceiver) {
            log('addTrack mid:${transceiver.mid}, transceiverId = ${transceiver.transceiverId}',
                TAG);
            return transceiver.sender;
          }) ??
          Future.error(IllegalStateException(
              'Can\'t add the track to the null peer connection'));
    } else if (track.kind == 'audio') {
      RTCRtpTransceiverInit initAudio = RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendOnly,
        streams: [mediaStream],
      );

      return peerConnection
              ?.addTransceiver(
            track: track,
            kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
            init: initAudio,
          )
              .then((transceiver) {
            return transceiver.sender;
          }) ??
          Future.error(IllegalStateException(
              'Can\'t add the track to the null peer connection'));
    } else {
      return Future.error(
          IllegalStateException('Can\'t add the track of unknown type'));
    }
  }

  @override
  void setMaxBandwidth(int? bandwidth) {
    // ignoring for conference calls
  }

  @override
  bool isAnswerShouldBeIgnored() {
    return false;
  }
}

List<RTCRtpEncoding> getVideoEncodings() {
  var simulcastConfig = RTCMediaConfig.instance.simulcastConfig;

  var encodings = [
    RTCRtpEncoding()
      ..rid = 'h'
      ..active = true
      ..maxBitrate = simulcastConfig.highVideoBitrate * 1000,
    RTCRtpEncoding()
      ..rid = 'm'
      ..active = true
      ..maxBitrate = simulcastConfig.mediumVideoBitrate * 1000
      ..scaleResolutionDownBy = 2,
    RTCRtpEncoding()
      ..rid = 'l'
      ..active = true
      ..maxBitrate = simulcastConfig.lowVideoBitrate * 1000
      ..scaleResolutionDownBy = 4,
  ];

  return encodings;
}
