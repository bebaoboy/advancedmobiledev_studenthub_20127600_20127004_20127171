import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import '../../../connectycube_calls.dart';
import '../peer_connection.dart';

abstract class BaseSession<C, P extends PeerConnection>
    implements BaseCallSession, CubePeerConnectionStateCallback {
  static const String _TAG = "BaseSession";
  @override
  LocalStreamCallback? onLocalStreamReceived;
  @override
  RemoteStreamCallback<BaseSession>? onRemoteStreamRemoved;
  @override
  SessionClosedCallback<BaseSession>? onSessionClosed;
  @protected
  final C client;
  @protected
  Map<int, P> channels = {};

  MediaStream? localStream;

  RTCSessionState? state;

  RTCSessionStateCallback? _connectionCallback;

  bool startScreenSharing = false;
  bool requestAudioForScreenSharing = false;
  DesktopCapturerSource? desktopCapturerSource;
  bool useIOSBroadcasting = false;
  String? selectedAudioInputDevice;
  String? selectedVideoInputDevice;
  Completer<MediaStream>? _initLocalStreamCompleter;

  @protected
  StreamController<CubeStatsReport> statsReportsStreamController =
      StreamController.broadcast();

  Stream<CubeStatsReport> get statsReports =>
      statsReportsStreamController.stream;

  BaseSession(this.client,
      {this.startScreenSharing = false,
      this.requestAudioForScreenSharing = false,
      this.selectedAudioInputDevice,
      this.selectedVideoInputDevice,
      this.desktopCapturerSource,
      this.useIOSBroadcasting = false});

  setSessionCallbacksListener(RTCSessionStateCallback callback) {
    _connectionCallback = callback;
  }

  removeSessionCallbacksListener() {
    _connectionCallback = null;
  }

  @protected
  void setState(RTCSessionState state) {
    if (this.state != state) {
      this.state = state;
    }
  }

  Future<MediaStream> initLocalMediaStream() {
    if (_initLocalStreamCompleter != null) {
      return _initLocalStreamCompleter!.future;
    }

    _initLocalStreamCompleter = Completer<MediaStream>();

    _createStream(startScreenSharing).then((mediaStream) async {
      localStream?.getTracks().forEach((track) async {
        await track.stop();
      });
      await localStream?.dispose();

      localStream = mediaStream;

      this.onLocalStreamReceived?.call(localStream!);

      _initLocalStreamCompleter?.complete(localStream);
    }).catchError((onError) {
      _initLocalStreamCompleter?.completeError(onError);
    });

    return _initLocalStreamCompleter!.future.whenComplete(() {
      _initLocalStreamCompleter = null;
    });
  }

  Future<MediaStream> _createStream(bool isScreenSharing) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': getAudioConfig(deviceId: selectedAudioInputDevice),
    };

    if (CallType.VIDEO_CALL == callType) {
      mediaConstraints['video'] =
          getVideoConfig(deviceId: selectedVideoInputDevice);
    }

    return isScreenSharing
        ? navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
            'audio': requestAudioForScreenSharing,
            'video': desktopCapturerSource != null
                ? {
                    'deviceId': {'exact': desktopCapturerSource!.id},
                    'mandatory': {'frameRate': 30.0}
                  }
                : !kIsWeb && Platform.isIOS && useIOSBroadcasting
                    ? {'deviceId': 'broadcast'}
                    : true
          }).then((mediaStream) {
            if (mediaStream.getAudioTracks().isEmpty &&
                requestAudioForScreenSharing) {
              return navigator.mediaDevices.getUserMedia({
                'audio': getAudioConfig(deviceId: selectedAudioInputDevice),
                'video': false
              }).then((userMediaStream) {
                mediaStream.addTrack(userMediaStream.getAudioTracks()[0]);

                return mediaStream;
              });
            }

            return mediaStream;
          })
        : navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  @override
  Future<MediaStream?> getLocalMediaStream(int userId) {
    if (localStream != null) return Future.value(localStream);

    return initLocalMediaStream();
  }

  @override
  void onRemoteStreamRemove(int userId, MediaStream remoteMediaStream,
      {String? trackId}) {
    onRemoteStreamRemoved?.call(this, userId, remoteMediaStream);
  }

  @override
  void onIceGatheringStateChanged(int userId, RTCIceGatheringState state) {
    log("onIceGatheringStateChanged state= $state for userId= $userId", _TAG);
  }

  @override
  void onStatsReceived(int userId, List<StatsReport> stats) {
    statsReportsStreamController.add(CubeStatsReport(userId, stats));
  }

  /// For web implementation, make sure to pass the target deviceId
  @override
  Future<bool> switchCamera({String? deviceId}) async {
    if (CallType.VIDEO_CALL != callType) {
      return Future.error(IllegalStateException(
          "Can't perform operation [switchCamera] for AUDIO call"));
    }

    try {
      if (localStream == null) {
        return Future.error(IllegalStateException(
            "Can't perform operation [switchCamera], cause 'localStream' not initialised"));
      } else {
        this.selectedVideoInputDevice = deviceId;

        if (selectedVideoInputDevice != null) {
          var newMediaStream = await navigator.mediaDevices.getUserMedia({
            'audio': false,
            'video': kIsWeb
                ? {'deviceId': selectedVideoInputDevice}
                : getVideoConfig(deviceId: selectedVideoInputDevice),
          });

          var oldVideoTrack = localStream!.getVideoTracks()[0];

          await localStream?.removeTrack(oldVideoTrack);
          oldVideoTrack.stop();

          await localStream?.addTrack(newMediaStream.getVideoTracks()[0]);

          channels.forEach((userId, peerConnection) async {
            await peerConnection
                .replaceVideoTrack(newMediaStream.getVideoTracks()[0]);
          });

          this.onLocalStreamReceived?.call(localStream!);

          return Future.value(true);
        } else {
          final videoTrack = localStream!.getVideoTracks()[0];
          return Helper.switchCamera(videoTrack, null, localStream);
        }
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  @override
  Future<void> setTorchEnabled(bool enabled) {
    if (CallType.VIDEO_CALL != callType) {
      return Future.error(IllegalStateException(
          "Can't perform operation [setTorchEnabled] for AUDIO call"));
    }

    try {
      if (localStream == null) {
        return Future.error(IllegalStateException(
            "Can't perform operation [setTorchEnabled], cause 'localStream' not initialised"));
      } else {
        final videoTrack = localStream!
            .getVideoTracks()
            .firstWhere((track) => track.kind == 'video');
        return videoTrack.hasTorch().then((has) {
          if (has) {
            return videoTrack.setTorch(enabled);
          } else {
            return Future.error(IllegalStateException(
                "Can't perform operation  [setTorchEnabled], cause current camera does not support torch mode"));
          }
        });
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  @override
  void setVideoEnabled(bool enabled) {
    if (CallType.VIDEO_CALL != callType) {
      log("Can't perform operation [setVideoEnabled] for AUDIO call");
      return;
    }

    if (localStream == null) {
      log("Can't perform operation [setVideoEnabled], cause 'localStream' not initialised");
      return;
    }

    final videoTrack = localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');

    videoTrack.enabled = enabled;
  }

  @override
  void setMicrophoneMute(bool mute) {
    if (localStream == null) {
      log("Can't perform operation [setMicrophoneMute], cause 'localStream' not initialised");
      return;
    }

    final audioTrack = localStream!
        .getAudioTracks()
        .firstWhere((track) => track.kind == 'audio');

    Helper.setMicrophoneMute(mute, audioTrack);
  }

  /// Set speakerphone enable/disable for iOS/Android only.
  /// For other platforms use the [selectAudioOutput]
  @override
  void enableSpeakerphone(bool enable) {
    Helper.setSpeakerphoneOn(enable);
  }

  /// Enables/disables the Screen Sharing feature.
  /// [enable] - `true` - for enabling Screen Sharing or `false` - for disabling.
  /// [desktopCapturerSource] - the desktop capturer source, if it is `null` the
  ///  default Window/Screen will be captured. Use only for desktop platforms.
  ///  Use [ScreenSelectDialog] to give the user a choice of the shared Window/Screen.
  /// [useIOSBroadcasting] - set `true` if the `Broadcast Upload Extension` was
  /// added to your iOS project for implementation Screen Sharing feature, otherwise
  /// set `false` and `in-app` Screen Sharing will be started. Used for iOS platform only.
  /// See our [step-by-step guide](https://developers.connectycube.com/flutter/videocalling?id=ios-screen-sharing-using-the-screen-broadcasting-feature)
  /// on how to integrate the Screen Broadcasting feature into your iOS app.
  /// [requestAudioForScreenSharing] - set `true` if need to request the audio
  /// stream from your Audio input device, otherwise the Screen Sharing will be
  /// requested without an audio
  @override
  Future<void> enableScreenSharing(
    bool enable, {
    DesktopCapturerSource? desktopCapturerSource,
    bool useIOSBroadcasting = false,
    bool requestAudioForScreenSharing = false,
  }) {
    this.desktopCapturerSource = desktopCapturerSource;
    this.useIOSBroadcasting = useIOSBroadcasting;
    this.requestAudioForScreenSharing = requestAudioForScreenSharing;
    try {
      return _createStream(enable).then((mediaStream) {
        return replaceMediaStream(mediaStream);
      });
    } catch (e) {
      return Future.value();
    }
  }

  @override
  Future<void> replaceMediaStream(MediaStream mediaStream) async {
    try {
      localStream?.getTracks().forEach((track) async {
        await track.stop();
      });
      await localStream?.dispose();
    } catch (error) {
      log("[replaceMediaStream] error: $error", _TAG);
    }

    localStream = mediaStream;

    channels.forEach((userId, peerConnection) async {
      await peerConnection.replaceMediaStream(localStream!);
    });

    this.onLocalStreamReceived?.call(localStream!);
  }

  /// Sets maximum bandwidth for the local media stream
  /// [bandwidth] - the bandwidth in kbps, set to 0 or null for disabling the limitation
  @override
  void setMaxBandwidth(int? bandwidth) {
    channels.forEach((userId, peerConnection) {
      peerConnection.setMaxBandwidth(bandwidth);
    });
  }

  /// Return the available cameras
  ///
  /// Note: Make sure to call this gettet after [initLocalMediaStream],
  /// otherwise the devices will not be listed.
  Future<List<MediaDeviceInfo>> getCameras() {
    return Helper.cameras;
  }

  /// Return the available audiooutputs
  ///
  /// Note: Make sure to call this gettet after [initLocalMediaStream],
  /// otherwise the devices will not be listed.
  Future<List<MediaDeviceInfo>> getAudioOutputs() {
    return Helper.audiooutputs;
  }

  /// Return the available audioinputs
  ///
  /// Note: Make sure to call this gettet after [initLocalMediaStream],
  /// otherwise the devices will not be listed.
  Future<List<MediaDeviceInfo>> getAudioInputs() {
    return Helper.enumerateDevices('audioinput');
  }

  /// Used to select a specific audio output device.
  ///
  /// Note: This method is only used for Flutter native,
  /// supported on iOS/Android/macOS/Windows.
  ///
  /// Android/macOS/Windows: Can be used to switch all output devices.
  /// iOS: you can only switch directly between the
  /// speaker and the preferred device
  /// web: flutter web can use RTCVideoRenderer.audioOutput instead
  Future<void> selectAudioOutput(String deviceId) {
    return Helper.selectAudioOutput(deviceId);
  }

  /// Sets the selected device as the audio input device.
  /// Use [getAudioInputs] for getting the list of available audio input devices
  Future<void> selectAudioInput(String deviceId) async {
    // return Helper.selectAudioInput(deviceId);
    try {
      this.selectedAudioInputDevice = deviceId;

      if (kIsWeb) {
        var newMediaStream = await navigator.mediaDevices.getUserMedia({
          'audio': {'deviceId': selectedAudioInputDevice},
          'video': false,
        });

        var oldAudioStream = localStream!.getAudioTracks()[0];

        await localStream?.removeTrack(oldAudioStream);
        oldAudioStream.stop();

        await localStream?.addTrack(newMediaStream.getAudioTracks()[0]);

        channels.forEach((userId, peerConnection) async {
          await peerConnection
              .replaceAudioTrack(newMediaStream.getAudioTracks()[0]);
        });

        return Future.value();
      } else {
        return Helper.selectAudioInput(selectedAudioInputDevice!);
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  @override
  void onPeerConnectionStateChanged(int userId, PeerConnectionState state) {
    switch (state) {
      case PeerConnectionState.RTC_CONNECTION_NEW:
        break;
      case PeerConnectionState.RTC_CONNECTION_CONNECTING:
      case PeerConnectionState.RTC_CONNECTION_CHECKING:
        _connectionCallback?.onConnectingToUser(this, userId);
        break;
      case PeerConnectionState.RTC_CONNECTION_CONNECTED:
        setState(RTCSessionState.RTC_SESSION_CONNECTED);
        _connectionCallback?.onConnectedToUser(this, userId);
        break;
      case PeerConnectionState.RTC_CONNECTION_DISCONNECTED:
        _connectionCallback?.onDisconnectedFromUser(this, userId);
        break;
      case PeerConnectionState.RTC_CONNECTION_CLOSED:
        closeConnectionForOpponent(userId, null);
        _connectionCallback?.onConnectionClosedForUser(this, userId);
        break;
      case PeerConnectionState.RTC_CONNECTION_FAILED:
        closeConnectionForOpponent(userId, null);
        _connectionCallback?.onConnectionFailedWithUser(this, userId);
        break;
      default:
        break;
    }
  }

  void closeConnectionForOpponent(
    int opponentId,
    Function(int opponentId)? callback,
  ) {
    PeerConnection? peerConnection = channels[opponentId];
    if (peerConnection == null) return;

    peerConnection.close();
    channels.remove(opponentId);

    if (callback != null) {
      callback(opponentId);
    }

    log(
      "closeConnectionForOpponent, "
      "_channels.length = ${channels.length}",
      _TAG,
    );

    if (channels.isEmpty) {
      closeCurrentSession();
    } else {
      log(
        "closeConnectionForOpponent, "
        "left channels = ${channels.keys.join(", ")}",
        _TAG,
      );
    }
  }

  Future<void> closeCurrentSession() async {
    log("closeCurrentSession", _TAG);
    setState(RTCSessionState.RTC_SESSION_CLOSED);
    if (localStream != null) {
      log("[closeCurrentSession] dispose localStream", _TAG);
      try {
        localStream?.getTracks().forEach((track) async {
          await track.stop();
        });
        await localStream?.dispose();
      } catch (error) {
        log('closeCurrentSession ERROR: $error');
      }

      localStream = null;
    }

    statsReportsStreamController.close();

    notifySessionClosed();
  }

  void notifySessionClosed() {
    log("_notifySessionClosed", _TAG);
    onSessionClosed?.call(this);
  }

  @override
  Future<MediaStream> addMediaTrack(MediaStreamTrack track) {
    if (localStream == null) {
      return Future.error(IllegalStateException(
          'Can\'t add the track cause the local media stream doesn\'t exist'));
    }

    return Future.wait(channels
            .map((userId, peerConnection) => MapEntry(
                  userId,
                  peerConnection.addTrack(track, localStream),
                ))
            .values)
        .then((_) {
      localStream?.addTrack(track);
      onLocalStreamReceived?.call(localStream!);
      return localStream!;
    });
  }

  @override
  Future<MediaStream> removeMediaTrack(String trackId) {
    if (localStream == null) {
      return Future.error(IllegalStateException(
          'Can\'t remove the track cause the local media stream doesn\'t exist'));
    }

    var track = localStream?.getTrackById(trackId);

    if (track == null) {
      return Future.error(IllegalStateException(
          'Can\'t remove the track cause it not found in the local media stream'));
    }

    return Future.wait(channels
            .map((userId, peerConnection) => MapEntry(
                  userId,
                  peerConnection.removeTrack(trackId),
                ))
            .values)
        .then((_) {
      localStream?.removeTrack(track);
      track.stop();
      onLocalStreamReceived?.call(localStream!);
      return localStream!;
    });
  }
}
