import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../connectycube_chat.dart';

import 'utils/rtc_config.dart';
import 'utils/rtc_media_config.dart';
import 'utils/signaling_specifications.dart';

class PeerConnection {
  static const String TAG = "PeerConnection";
  int _userId;
  CubePeerConnectionStateCallback _peerConnectionStateCallback;

  RTCPeerConnection? _peerConnection;
  List<RTCIceCandidate?> _remoteCandidates = [];
  List<RTCIceCandidate>? _localCandidates = [];

  RTCSessionDescription? _remoteSdp;
  PeerConnectionState? _signalingState;
  Timer? _dillingTimer;
  Timer? _statsReportTimer;
  late int _startConnectionTime;
  bool useDialingTimer;

  PeerConnectionState? get state => _signalingState;

  @protected
  RTCPeerConnection? get peerConnection => _peerConnection;

  PeerConnection(
      this._userId, this._peerConnectionStateCallback, this.useDialingTimer) {
    _onConnectionStateChanged(PeerConnectionState.RTC_CONNECTION_NEW);
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    RTCPeerConnection pc = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': 'unified-plan'}
    }, _config);
    pc.onIceCandidate = (candidate) {
      if (_localCandidates != null) {
        _localCandidates!.add(candidate);
      } else {
        this
            ._peerConnectionStateCallback
            .onSendIceCandidate(_userId, candidate);
      }
    };

    pc.onIceConnectionState = (state) {
      logTime(
          "onIceConnectionState changed to $state for opponent $_userId", TAG);

      if (RTCIceConnectionState.RTCIceConnectionStateNew == state) {
        _onConnectionStateChanged(PeerConnectionState.RTC_CONNECTION_NEW);
      } else if (RTCIceConnectionState.RTCIceConnectionStateChecking == state) {
        _onConnectionStateChanged(PeerConnectionState.RTC_CONNECTION_CHECKING);
        _cancelDillingTimer();
      } else if (RTCIceConnectionState.RTCIceConnectionStateCompleted == state) {
        // ignoring
      } else if (RTCIceConnectionState.RTCIceConnectionStateConnected ==
          state) {
        _onConnectionStateChanged(PeerConnectionState.RTC_CONNECTION_CONNECTED);
        setMaxBandwidth(RTCMediaConfig.instance.maxBandwidth);
      } else if (RTCIceConnectionState.RTCIceConnectionStateDisconnected ==
          state) {
        _onConnectionStateChanged(
            PeerConnectionState.RTC_CONNECTION_DISCONNECTED);
      } else if (RTCIceConnectionState.RTCIceConnectionStateFailed == state) {
        _onConnectionStateChanged(PeerConnectionState.RTC_CONNECTION_FAILED);
      } else if (RTCIceConnectionState.RTCIceConnectionStateClosed == state) {
        _onConnectionStateChanged(PeerConnectionState.RTC_CONNECTION_CLOSED);
      } else if (RTCIceConnectionState.RTCIceConnectionStateCount == state) {
        // ignoring
      }
    };

    pc.onTrack = (event) async {
      this._peerConnectionStateCallback.onRemoteStreamReceive(
            _userId,
            event.streams.first,
            transceiver: event.transceiver,
            track: event.track,
          );
    };

    pc.onRemoveStream = (stream) {
      this._peerConnectionStateCallback.onRemoteStreamRemove(_userId, stream);
    };

    pc.onRemoveTrack = (stream, track) {
      if (track.kind == 'video' || kIsWeb) {
        this
            ._peerConnectionStateCallback
            .onRemoteStreamRemove(_userId, stream, trackId: track.id);
      }
    };

    pc.onSignalingState = (state) {
      log("onSignalingState changed to $state for opponent $_userId", TAG);
    };

    pc.onIceGatheringState = (state) {
      log("onIceGatheringState changed to $state for opponent $_userId", TAG);
      this
          ._peerConnectionStateCallback
          .onIceGatheringStateChanged(_userId, state);
    };

    pc.onRenegotiationNeeded = () async {
      log('onRenegotiationNeeded, connectionState: ${pc.connectionState}', TAG);
      if (pc.connectionState !=
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) return;
      _localCandidates = [];
      _signalingState = PeerConnectionState.RTC_CONNECTION_RENEGOTIATING;

      var localSdp = await pc.createOffer();
      pc.setLocalDescription(localSdp);
      log('onRenegotiationNeeded, localSdp.type: ${localSdp.type}', TAG);
      this._peerConnectionStateCallback.onSendUpdateCall(_userId, localSdp);
    };

    await this
        ._peerConnectionStateCallback
        .getLocalMediaStream(_userId)
        .then((localMediaStream) {
      setMediaStream(pc, localMediaStream);
    });

    return pc;
  }

  // TODO VT add possibility to use custom servers
  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:turn.connectycube.com'},
      {
        'urls': 'turn:turn.connectycube.com:5349?transport=udp',
        'username': 'connectycube',
        'credential': '4c29501ca9207b7fb9c4b4b6b04faeb1'
      },
      {
        'urls': 'turn:turn.connectycube.com:5349?transport=tcp',
        'username': 'connectycube',
        'credential': '4c29501ca9207b7fb9c4b4b6b04faeb1'
      },
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  Map<String, dynamic> get _constraints => {
        'mandatory': {
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': _isVideoCall(),
        },
        'optional': [],
      };

  void startOffer() {
    _createPeerConnection().then((pc) {
      this._peerConnection = pc;

      _createOffer(pc);

      _startStatsFetching();
    });
  }

  _createOffer(RTCPeerConnection peerConnection) async {
    log("_createOffer for opponent $_userId", TAG);

    _onConnectionStateChanged(PeerConnectionState.RTC_CONNECTION_PENDING);

    try {
      RTCSessionDescription sessionDescription =
          await peerConnection.createOffer(_constraints);
      peerConnection.setLocalDescription(sessionDescription);
      _sendOffer(sessionDescription);
      if (useDialingTimer) _startDillingTimer(sessionDescription);
    } catch (e) {
      log("_createOffer error: ${e.toString()}", TAG);
    }
  }

  setRemoteDescription() async {
    await _peerConnection!.setRemoteDescription(_remoteSdp!);
  }

  startAnswer({bool force = false}) async {
    if (!force && isAnswerShouldBeIgnored()) return;

    log("startAnswer", TAG);

    if (force && _localCandidates == null) {
      _localCandidates = [];
    }

    _signalingState = PeerConnectionState.RTC_CONNECTION_CONNECTING;

    if (_remoteSdp == null) return;

    if (_peerConnection == null) {
      _peerConnection = await _createPeerConnection();
    }

    setRemoteDescription();

    await _createAnswer();

    if (this._remoteCandidates.length > 0) {
      _remoteCandidates.forEach((candidate) async {
        log("startAnswer, candidate ${candidate!.toMap()}", TAG);
        if (candidate.candidate != null) {
          await _peerConnection!.addCandidate(candidate);
        }
      });
      _remoteCandidates.clear();
    }

    _startStatsFetching();
  }

  bool isAnswerShouldBeIgnored() {
    log("[isAnswerShouldBeIgnored] state: $state", TAG);
    return PeerConnectionState.RTC_CONNECTION_PENDING != state &&
        PeerConnectionState.RTC_CONNECTION_NEW != state;
  }

  _createAnswer() async {
    try {
      RTCSessionDescription sdp =
          await _peerConnection!.createAnswer(_constraints);
      await _peerConnection!.setLocalDescription(sdp);
      _sendAnswer(sdp);
      _drainIceCandidates();
    } catch (e) {
      log("_createAnswer error: ${e.toString()}", TAG);
    }
  }

  void _sendOffer(RTCSessionDescription sdp) {
    this._peerConnectionStateCallback.onSendOffer(_userId, sdp);
  }

  void _sendAnswer(RTCSessionDescription sdp) {
    this._peerConnectionStateCallback.onSendAnswer(_userId, sdp);
  }

  void setMediaStream(RTCPeerConnection pc, MediaStream? mediaStream) {
    if (mediaStream != null) {
      mediaStream.getTracks().forEach((track) {
        pc.addTrack(track, mediaStream);
      });
    }
  }

  Future<RTCRtpSender> addTrack(
      MediaStreamTrack track, MediaStream? mediaStream) {
    if (mediaStream != null) {
      return _peerConnection?.addTrack(track, mediaStream) ??
          Future.error(IllegalStateException(
              'Can\'t add the track to the null peer connection'));
    } else {
      return _peerConnection?.addTrack(track) ??
          Future.error(IllegalStateException(
              'Can\'t add the track to the null peer connection'));
    }
  }

  Future<bool> removeTrack(String trackId) {
    return _peerConnection?.senders.then((rtcRtpSenders) {
          for (var sender in rtcRtpSenders) {
            if (sender.track?.id == trackId) {
              return _peerConnection?.removeTrack(sender) ??
                  Future.error(IllegalStateException(
                      'Can\'t remove the track from the null peer connection'));
            }
          }

          return Future.error(IllegalStateException(
              'Can\'t remove the track, the track with id \'$trackId\' not found'));
        }) ??
        Future.error(IllegalStateException(
            'Can\'t remove the track from the null peer connection'));
  }

  Future<void> processIceCandidates(
      List<RTCIceCandidate?> iceCandidates) async {
    log("processIceCandidates, user id = $_userId, received ${iceCandidates.length} candidates",
        TAG);

    if (_peerConnection != null) {
      log("processIceCandidates, ${(await _peerConnection!.getRemoteDescription())?.toMap()}",
          TAG);
      iceCandidates.forEach((candidate) async {
        log("processIceCandidates, candidate ${candidate!.toMap()}", TAG);
        if (candidate.candidate != null) {
          try {await _peerConnection!.addCandidate(candidate);
          } catch (e) {}
        }
      });
    } else {
      _remoteCandidates.addAll(iceCandidates);
    }
  }

  Future<void> replaceMediaStream(MediaStream newStream) {
    return _peerConnection?.senders.then((senders) {
          senders.forEach((sender) async {
            if (sender.track?.kind == 'video') {
              if (newStream.getVideoTracks().length > 0) {
                await sender.replaceTrack(newStream.getVideoTracks()[0]);
              }
            } else if (sender.track?.kind == 'audio') {
              if (newStream.getAudioTracks().length > 0) {
                await sender.replaceTrack(newStream.getAudioTracks()[0]);
              }
            }
          });
          return Future.value();
        }) ??
        Future.error(
            Exception('An error occurred during switching the stream'));
  }

  Future<void> replaceAudioTrack(MediaStreamTrack? newAudioTrack) {
    return _peerConnection?.senders.then((senders) {
          senders.forEach((sender) async {
            if (sender.track?.kind == 'audio') {
              await sender.replaceTrack(newAudioTrack);
            }
          });
          return Future.value();
        }) ??
        Future.error(
            Exception('An error occurred during replacing the audio track'));
  }

  Future<void> replaceVideoTrack(MediaStreamTrack? newVideoTrack) {
    return _peerConnection?.senders.then((senders) {
          senders.forEach((sender) async {
            if (sender.track?.kind == 'video') {
              await sender.replaceTrack(newVideoTrack);
            }
          });
          return Future.value();
        }) ??
        Future.error(
            Exception('An error occurred during replacing the video track'));
  }

  void setMaxBandwidth(int? bandwidth) {
    _peerConnection?.senders.then((senders) {
      senders.forEach((sender) async {
        var parameters = sender.parameters;
        var encodings = parameters.encodings;

        if (encodings == null || encodings.isEmpty) {
          encodings = List.of([RTCRtpEncoding()]);
        }

        encodings.forEach((encoding) {
          if (bandwidth == null || bandwidth == 0) {
            encoding.maxBitrate = null;
          } else {
            encoding.maxBitrate = bandwidth * 1000;
          }
        });

        parameters.encodings = encodings;
        sender.setParameters(parameters);
      });
    });
  }

  void _startStatsFetching() {
    if (RTCConfig.instance.statsReportsInterval > 0 &&
        _statsReportTimer == null) {
      _statsReportTimer = Timer.periodic(
          Duration(milliseconds: RTCConfig.instance.statsReportsInterval),
          _fetchStats);
    }
  }

  void _fetchStats(Timer timer) {
    if (_peerConnection == null) {
      timer.cancel();
      return;
    }

    _peerConnection?.getStats().then((stats) {
      //
      // stats.where((stat) {
      //   return stat.type == 'outbound-rtp' || stat.type == 'inbound-rtp' || stat.type == 'ssrc' ||stat.type == 'media-source' ||stat.type == 'track';
      // }).forEach((stat) {
      //   log('[PeerConnection][getStats], \n'
      //       'type: ${stat.type} \n'
      //       'id: ${stat.id} \n'
      //       'values: ${stat.values}',
      //       TAG);
      // });

      _peerConnectionStateCallback.onStatsReceived(_userId, stats);
    }).catchError((error) {
      log("[PeerConnection][getStats], user id = $_userId, stats ERROR: $error",
          TAG);
    });
  }

  void close() {
    _cancelDillingTimer();
    _statsReportTimer?.cancel();

    if (_peerConnection == null) return;

    _peerConnection!.close();
    _peerConnection = null;
  }

  Future<void> processAnswer(RTCSessionDescription sdp) async {
    log("processAnswer, user id = $_userId", TAG);
    log("processAnswer, _remoteCandidates.lenght = ${_remoteCandidates.length}",
        TAG);

    if (_peerConnection != null) {
      log("processAnswer, _peerConnection != null", TAG);
      setRemoteSdpToChannel(sdp);
    }
  }

  void setRemoteSdpToChannel(RTCSessionDescription sdp) {
    setRemoteSdp(sdp);
    setRemoteDescription();

    _drainIceCandidates();
  }

  void setRemoteSdp(RTCSessionDescription sdp) {
    _remoteSdp = sdp;
  }

  bool _isVideoCall() {
    return CallType.VIDEO_CALL == _peerConnectionStateCallback.callType;
  }

  void _startDillingTimer(RTCSessionDescription sessionDescription) {
    _startConnectionTime = DateTime.now().millisecondsSinceEpoch;
    _dillingTimer = Timer.periodic(
        Duration(
            seconds: max(RTCConfig.instance.defaultDillingTimeInterval,
                RTCConfig.instance.dillingTimeInterval)), (timer) {
      if (_isConnectionExpired()) {
        _onConnectionStateChanged(PeerConnectionState.RTC_CONNECTION_TIMEOUT);
        timer.cancel();
      } else {
        if (PeerConnectionState.RTC_CONNECTION_CONNECTING == state ||
            PeerConnectionState.RTC_CONNECTION_PENDING == state) {
          _sendOffer(sessionDescription);
        } else {
          timer.cancel();
        }
      }
    });
  }

  bool _isConnectionExpired() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int diff = currentTime - _startConnectionTime;
    bool isCallExpired = (diff / 1000) >= RTCConfig.instance.noAnswerTimeout;

    return isCallExpired;
  }

  void _onConnectionStateChanged(PeerConnectionState state) {
    _signalingState = state;
    _peerConnectionStateCallback.onPeerConnectionStateChanged(_userId, state);
  }

  void _cancelDillingTimer() {
    if (_dillingTimer != null) _dillingTimer!.cancel();
  }

  bool hasRemoteSdp() {
    return _remoteSdp != null;
  }

  void _drainIceCandidates() {
    log("_drainIceCandidates", TAG);
    if (_localCandidates != null && _localCandidates!.isNotEmpty) {
      log("_drainIceCandidates, onSendIceCandidates", TAG);
      _peerConnectionStateCallback.onSendIceCandidates(
          _userId, _localCandidates);
    }

    _localCandidates = null;
  }
}

abstract class CubePeerConnectionStateCallback {
  int get callType;

  Future<MediaStream?> getLocalMediaStream(int userId);

  void onRemoteStreamReceive(
    int userId,
    MediaStream remoteMediaStream, {
    RTCRtpTransceiver? transceiver,
    MediaStreamTrack? track,
  });

  void onRemoteStreamRemove(
    int userId,
    MediaStream remoteMediaStream, {
    String? trackId,
  });

  void onSendIceCandidate(
    int userId,
    RTCIceCandidate iceCandidate,
  );

  void onSendIceCandidates(
    int userId,
    List<RTCIceCandidate>? iceCandidates,
  );

  void onSendOffer(
    int userId,
    RTCSessionDescription sdp,
  );

  void onSendAnswer(
    int userId,
    RTCSessionDescription sdp,
  );

  void onSendUpdateCall(
    int userId,
    RTCSessionDescription sdp,
  );

  void onPeerConnectionStateChanged(
    int userId,
    PeerConnectionState state,
  );

  void onIceGatheringStateChanged(int userId, RTCIceGatheringState state);

  void onStatsReceived(int userId, List<StatsReport> stats);
}

enum PeerConnectionState {
  RTC_CONNECTION_NEW,
  RTC_CONNECTION_PENDING,
  RTC_CONNECTION_CONNECTING,
  RTC_CONNECTION_CHECKING,
  RTC_CONNECTION_CONNECTED,
  RTC_CONNECTION_DISCONNECTED,
  RTC_CONNECTION_TIMEOUT,
  RTC_CONNECTION_CLOSED,
  RTC_CONNECTION_FAILED,
  RTC_CONNECTION_RENEGOTIATING,
}

// Code can be used for setting the custom bandwidth if WebRTC lid doesn't support `unified` plan
// String updateBandwidthRestriction(String sdp, int bandwidth) {
//   var modifier = 'AS';
//   // TODO VT improbe for firefox
//   // if (kIsWeb && Browser().browserAgent == BrowserAgent.Firefox) {
//   //   bandwidth = urs(bandwidth, 0) * 1000;
//   //   modifier = 'TIAS';
//   // }
//
//   if (sdp.indexOf('b=' + modifier + ':') == -1) {
//     var searchRegExp = RegExp(r'c=IN (.*)\r\n');
//     var replacedLines = [];
//     searchRegExp.allMatches(sdp).forEach((match) {
//       var inValue = match.group(0);
//       if (!replacedLines.contains(inValue)) {
//         replacedLines.add(inValue);
//         sdp =
//             sdp.replaceAll('$inValue', "${inValue}b=$modifier:$bandwidth\r\n");
//       }
//     });
//   } else {
//     sdp = sdp.replaceAll(
//         RegExp('b=$modifier:.*\r\n'), 'b=$modifier:$bandwidth\r\n');
//   }
//   return sdp;
// }
//
// String removeBandwidthRestriction(String sdp) {
//   return sdp
//       .replaceAll(RegExp('b=AS:.*\r\n'), '')
//       .replaceAll(RegExp('b=TIAS:.*\r\n'), '');
// }
