import 'models/call_base_session.dart';

import '../../connectycube_calls.dart';
import 'conference/ws_exeptions.dart';

abstract class BaseCallSession<S extends BaseSession> {
  SessionClosedCallback<S>? onSessionClosed;
  LocalStreamCallback? onLocalStreamReceived;
  RemoteStreamCallback<S>? onRemoteStreamRemoved;

  void setMicrophoneMute(bool mute);

  void enableSpeakerphone(bool enable);

  void setVideoEnabled(bool enabled);

  ///Future contains isFrontCamera
  ///Throws error if switching camera failed
  Future<bool> switchCamera();

  Future<void> setTorchEnabled(bool enabled);

  Future<void> enableScreenSharing(bool enable);

  void replaceMediaStream(MediaStream mediaStream);

  void setMaxBandwidth(int? bandwidth);

  int getUserIdForStream(String? trackId, String? trackIdentifier, int defaultId);

  Future<MediaStream> addMediaTrack(MediaStreamTrack track);

  Future<MediaStream> removeMediaTrack(String trackId);
}

abstract class ConferenceCallSession {
  PublishersReceived? onPublishersReceived;
  PublisherLeft? onPublisherLeft;
  SubscribedOnPublisher? onSubscribedOnPublisher;
  SubscriberAttached? onSubscriberAttached;
  SlowLink? onSlowLink;
  Error? onError;
  SubStreamChanged? onSubStreamChanged;
  LayerChanged? onLayerChanged;
}

abstract class P2PCallSession {
  UserConnectionStateCallback<P2PSession>? onUserNoAnswer;
  UserActionCallback<P2PSession>? onCallAcceptedByUser;
  UserActionCallback<P2PSession>? onCallRejectedByUser;
  UserActionCallback<P2PSession>? onReceiveHungUpFromUser;

  void startCall([Map<String, String>? userInfo]);

  void acceptCall([Map<String, String>? userInfo]);

  void reject([Map<String, String>? userInfo]);

  void hungUp([Map<String, String>? userInfo]);

  int get callerId;

  String get sessionId;

  int get callType;

  set callType(int callType);

  Set<int> get opponentsIds;
}

typedef void LocalStreamCallback(MediaStream stream);
typedef void RemoteStreamCallback<T>(T session, int userId, MediaStream stream);
typedef void UserConnectionStateCallback<T>(T session, int userId);
typedef void UserActionCallback<T>(T session, int userId,
    [Map<String, String>? userInfo]);
typedef void SessionClosedCallback<T>(T session);

typedef void PublishersReceived(List<int?> publishers);
typedef void PublisherLeft(int? userId);
typedef void SubscribedOnPublisher(int userId);
typedef void SubscriberAttached(int userId);
typedef void SlowLink(bool? uplink, int? lost);
typedef void Error(WsException ex);
typedef void SubStreamChanged(int userId, StreamType streamType);
typedef void LayerChanged(int userId, int layer);
typedef void RemoteStreamCallbackConference<T>(T session, int userId, MediaStream stream, {String? trackId});

enum RTCSessionState {
  RTC_SESSION_PENDING,
  RTC_SESSION_NEW,
  RTC_SESSION_CONNECTING,
  RTC_SESSION_CONNECTED,
  RTC_SESSION_GOING_TO_CLOSE,
  RTC_SESSION_CLOSED
}

abstract class RTCSessionStateCallback<T extends BaseSession> {
  void onConnectingToUser(T session, int userId);

  void onConnectedToUser(T session, int userId);

  void onDisconnectedFromUser(T session, int userId);

  void onConnectionFailedWithUser(T session, int userId);

  void onConnectionClosedForUser(T session, int userId);
}

class CubeStatsReport {
  final int userId;
  final List<StatsReport> stats;

  CubeStatsReport(this.userId, this.stats);
}
