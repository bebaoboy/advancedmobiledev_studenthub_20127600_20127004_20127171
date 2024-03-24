import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/call_base_session.dart';
import 'ws_exeptions.dart';
import '../models/cube_rtc_session_description.dart';

import '../../../connectycube_calls.dart';
import '../peer_connection.dart';
import 'conference_peer_connection.dart';

import '../utils/platform_utils/platform_utils.dart'
    if (dart.library.io) '../utils/platform_utils/platform_utils_native.dart'
    if (dart.library.html) '../utils/platform_utils/platform_utils_web.dart';

const JANUS_PREFIX = 'janus';

class ConferenceSession
    extends BaseSession<ConferenceClient, ConferencePeerConnection>
    implements JanusResponseEventCallback, ConferenceCallSession {
  static const String _TAG = "ConferenceSession";

  JanusSignaler _signaler;
  late CubeConferenceSessionDescription sessionDescription;
  int? joinSenderId;

  int get currentUserId => client.currentUserId;

  int get publisherId => 1;

  int get subscriberId => 0;

  bool joinedAsSubscriber = false;
  bool creatingSubscription = false;

  Set<int> allActivePublishers = Set();
  Set<int> joinEventPublishers = Set();
  Set<int> allActiveSubscribers = Set();

  Map<String, String> trackIdMid = {};
  Map<String, String> trackIdTrackIdentifier = {};

  late Function _joinCallback;

  @override
  void Function(WsException)? onError;

  @override
  void Function(int?)? onPublisherLeft;

  @override
  void Function(int)? onSubscribedOnPublisher;

  @override
  void Function(int)? onSubscriberAttached;

  RemoteStreamCallbackConference<ConferenceSession>?
      onRemoteStreamTrackReceived;

  @deprecated
  RTCSessionStateCallback? _connectionCallback;

  /// The subscription on publisher now doing automatically by the SDK. Don\'t
  /// use it for subscription on publisher instead use for managing the publishers in your app.
  @override
  void Function(List<int?>)? onPublishersReceived;

  @override
  void Function(bool?, int?)? onSlowLink;

  @override
  void Function(int, StreamType)? onSubStreamChanged;

  @override
  void Function(int, int)? onLayerChanged;

  ConferenceSession(
    client,
    this._signaler,
    int conferenceType, {
    bool startScreenSharing = false,
    DesktopCapturerSource? desktopCapturerSource,
    bool useIOSBroadcasting = false,
    bool requestAudioForScreenSharing = false,
    String? selectedAudioInputDevice,
    String? selectedVideoInputDevice,
  }) : super(
          client,
          startScreenSharing: startScreenSharing,
          desktopCapturerSource: desktopCapturerSource,
          useIOSBroadcasting: useIOSBroadcasting,
          requestAudioForScreenSharing: requestAudioForScreenSharing,
          selectedAudioInputDevice: selectedAudioInputDevice,
          selectedVideoInputDevice: selectedVideoInputDevice,
        ) {
    sessionDescription = CubeConferenceSessionDescription(conferenceType);
  }

  @Deprecated('The callback is not actual anymore for Conference session. '
      'Use the `onPublisherLeft` instead of `onDisconnectedFromUser` and `onConnectionClosedForUser` and '
      'use the `onSubscribedOnPublisher` and the `onSubscribedAttached` instead of `onConnectedToUser`. '
      'Will be removed in the next major release.')
  @override
  setSessionCallbacksListener(RTCSessionStateCallback callback) {
    _connectionCallback = callback;
  }

  @Deprecated('The callback is not actual anymore for Conference session. '
      'Use the `onPublisherLeft` instead of `onDisconnectedFromUser` and `onConnectionClosedForUser` and '
      'use the `onSubscribedOnPublisher` and the `onSubscribedAttached` instead of `onConnectedToUser`. '
      'Will be removed in the next major release.')
  @override
  removeSessionCallbacksListener() {
    _connectionCallback = null;
  }

  Future<void> joinDialog(String dialogId, callback(List<int?> publishers),
      {ConferenceRole conferenceRole = ConferenceRole.PUBLISHER}) async {
    _joinCallback = callback;
    _signaler.setJanusResponseEventCallback(this);
    sessionDescription.conferenceRole = conferenceRole;
    await _signaler.attachPlugin(ConferenceConfig.instance.plugin,
        conferenceRole == ConferenceRole.PUBLISHER);
    await _signaler.joinDialog(
        dialogId,
        currentUserId,
        JOIN_JANUS_ROLE_PUBLISHER,
        conferenceRole,
        conferenceRole == ConferenceRole.PUBLISHER);
  }

  Future<void> subscribeToPublisher(int? publisherId) async {
    logTime("subscribeToPublisher = $publisherId", _TAG);

    if (publisherId == null)
      return Future.error(
          IllegalArgumentException('The \'publisherId\' can\'t be null'));

    return subscribeToPublishers({publisherId});
  }

  Future<void> subscribeToPublishers(Set<int> publishersIds) async {
    logTime("subscribeToPublishers = $publishersIds", _TAG);
    try {
      if (creatingSubscription) {
        return Future.delayed(Duration(milliseconds: 500),
            () => subscribeToPublishers(publishersIds));
      }

      if (joinedAsSubscriber) {
        return _signaler.subscribe(publishersIds).then((_) {
          publishersIds.forEach((publisher) {
            onSubscribedOnPublisher?.call(publisher);
            _connectionCallback?.onConnectedToUser(this, publisher);
          });

          joinEventPublishers.removeAll(publishersIds);
        });
      }

      creatingSubscription = true;
      return _signaler
          .attachPlugin(ConferenceConfig.instance.plugin, false)
          .then((_) {
        return _signaler.joinDialogAsSubscriber(publishersIds).then((_) {
          joinedAsSubscriber = true;

          publishersIds.forEach((publisher) {
            onSubscribedOnPublisher?.call(publisher);
            _connectionCallback?.onConnectedToUser(this, publisher);
          });

          // joinEventPublishers.removeAll(publishersIds);
        });
      });
    } on WsException catch (ex) {
      logTime("subscribeToPublishers error: =$ex", _TAG);
      notifySessionError(ex);
      return Future.error(ex);
    }
  }

  Future<void> unsubscribeFromPublisher(int publisherId,
      {Set<String>? tracks}) async {
    try {
      await _unsubscribeFromPublishers({publisherId: tracks});
    } on WsException catch (ex) {
      logTime("unsubscribeFromPublisher error: = $ex");
      notifySessionError(ex);
    }
  }

  Future<void> unsubscribeFromPublishers(
      Map<int, Set<String>?> publishers) async {
    try {
      await _unsubscribeFromPublishers(publishers);
    } on WsException catch (ex) {
      logTime("unsubscribeFromPublishers error: = $ex");
      notifySessionError(ex);
    }
  }

  void leave() {
    if (state != RTCSessionState.RTC_SESSION_GOING_TO_CLOSE &&
        state != RTCSessionState.RTC_SESSION_CLOSED) {
      setState(RTCSessionState.RTC_SESSION_GOING_TO_CLOSE);
      _signaler.setJanusResponseEventCallback(null);
      _signaler.stopAutoSendPresence();
      _leaveSession();
      disposeSession();
    } else {
      logTime(
          "Trying to leave from room, while session has been already closed",
          _TAG);
    }
  }

  void _leaveSession() async {
    logTime("signaler leave", _TAG);
    await _signaler.leave(currentUserId, false);

    if (sessionDescription.conferenceRole == ConferenceRole.PUBLISHER) {
      await _signaler.leave(currentUserId, true);
    }

    logTime("signaler destroySession", _TAG);
    _signaler.destroySession();
  }

  void disposeSession() {
    channels.keys.toList().forEach((opponentId) {
      logTime("disposeSession opponentId $opponentId", _TAG);
      closeConnectionForOpponent(opponentId, ((opponentId) {
        logTime(
            "closeConnectionForOpponent opponentId $opponentId success", _TAG);
      }));
    });
  }

  void notifySessionError(WsException exception) {
    if (onError != null) onError!(exception);
  }

  /// Sets maximum bandwidth for the local media stream
  /// [bandwidth] - the bandwidth in kbps, set to `0` or `null` for disabling the limitation
  @override
  void setMaxBandwidth(int? bitrate) {
    _signaler.sendBitrateConfig(currentUserId, bitrate ?? 0);
  }

  /// Requests the preferred quality for the opponent's video stream
  /// There available three types of media streams depending on the video
  /// bitrate and resolution. There are:
  ///   * [StreamType.high] - the maximum resolution and bitrate 720 kbit;
  ///   * [StreamType.medium] - the resolution cut in two times and bitrate 240 kbit;
  ///   * [StreamType.low] - the resolution cut in four times and bitrate 80 kbit;
  Future<void> requestPreferredStreamForOpponent(
      int opponentId, StreamType streamType) {
    return requestPreferredStreamsForOpponents({opponentId: streamType});
  }

  /// Requests the preferred quality for the opponents' video streams
  /// [configs] - is the map where key is the opponent's id and the value is
  ///             the required quality of the video stream
  /// There available three types of media streams depending on the video
  /// bitrate and resolution. There are:
  ///   * [StreamType.high] - the maximum resolution and bitrate 720 kbit;
  ///   * [StreamType.medium] - the resolution cut in two times and bitrate 240 kbit;
  ///   * [StreamType.low] - the resolution cut in four times and bitrate 80 kbit;
  Future<void> requestPreferredStreamsForOpponents(
      Map<int, StreamType> configs) {
    return _signaler.requestPreferredStreamsForUsers(configs);
  }

  /// Allows changing the layer with different FPS.
  /// There available three layers:
  ///   * 0 - lowest FPS;
  ///   * 1 - medium FPS;
  ///   * 2 - highest FPS;
  Future<void> requestPreferredLayerForOpponentStream(
      int opponentId, int layerNumber) {
    return requestPreferredLayersForOpponentsStreams({opponentId: layerNumber});
  }

  /// Allows changing the layer with different FPS for few users using single request.
  /// [config] - is the map where key is the opponent's id and the value is
  ///            the preferred layer of the video stream
  /// There available three layers:
  ///   * 0 - lowest FPS;
  ///   * 1 - medium FPS;
  ///   * 2 - highest FPS;
  Future<void> requestPreferredLayersForOpponentsStreams(Map<int, int> config) {
    return _signaler.requestPreferredLayersForUsersStreams(config);
  }

  @override
  void onEventError(String? error, int? code) {
    notifySessionError(WsException(error));
  }

  @override
  void onGetOnlineParticipants(Map<int?, bool?> participants) {
    // TODO: implement onGetOnlineParticipants
  }

  @override
  void onHangUp(String? reason) {
    notifySessionError(WsHangUpException(reason));
  }

  @override
  Future<void> onJoinEvent(List<int> publishersList, List<int> subscribersList,
      int? senderId) async {
    logTime("onJoinEvent");
    joinSenderId = senderId;
    joinEventPublishers.addAll(publishersList);
    allActivePublishers.addAll(publishersList);
    allActiveSubscribers.addAll(subscribersList);
    selectJoinStrategy();
    notifyJoinedSuccessListeners(publishersList);
  }

  @override
  void onJoiningEvent(int participantId, ConferenceRole? conferenceRole) {
    logTime("onJoiningEvent participantId= $participantId", _TAG);
    if (ConferenceRole.LISTENER == conferenceRole) {
      allActiveSubscribers.add(participantId);
      onSubscriberAttached?.call(participantId);
    }
  }

  @override
  void onLeaveCurrentUserEvent(bool success) {
    logTime("onLeaveCurrentUserEvent success= $success", _TAG);
  }

  @override
  void onLeaveParticipantEvent(int? participantId) {
    logTime("onLeaveParticipantEvent participantId= $participantId", _TAG);
    if (allActivePublishers.contains(participantId)) {
      allActivePublishers.remove(participantId);
      onPublisherLeft?.call(participantId);

      logTime(
          "onLeaveParticipantEvent publisherId= $participantId cleaning all stuff",
          _TAG);
    } else if (allActiveSubscribers.contains(participantId)) {
      allActiveSubscribers.remove(participantId);
      logTime("onLeaveParticipantEvent subscriberId= $participantId");
    } else {
      logTime(
          "onLeaveParticipantEvent publisherId= $participantId already left",
          _TAG);
    }

    _connectionCallback?.onDisconnectedFromUser(this, participantId!);
  }

  @override
  void onMediaReceived(String? type, bool? success) {
    logTime("onMediaReceived", _TAG);
  }

  @override
  void onPacketError(String error) {
    logTime("onPacketError error= $error", _TAG);
  }

  @override
  void onPublishedEvent(List<int> publishersList) {
    logTime("onPublishedEvent publishersList= $publishersList", _TAG);
    allActivePublishers.addAll(publishersList);

    onPublishersReceived?.call(publishersList);

    subscribeToPublishers(publishersList.toSet());
  }

  @override
  void onRemoteSDPEventAnswer(bool fromPublisher, String? sdp) {
    logTime("onRemoteSDPEventAnswer", _TAG);
    ConferencePeerConnection? channel =
        channels[fromPublisher ? publisherId : subscriberId];
    if (channel != null) {
      channel.setRemoteSdpToChannel(RTCSessionDescription(sdp!, "answer"));
    }
  }

  @override
  void onRemoteSDPEventOffer(int? opponentId, String? sdp) {
    logTime("onRemoteSDPEventOffer", _TAG);
    // set CallType.VIDEO_CALL for getting video in any call mode (audio, video)
    if (opponentId == null) opponentId = subscriberId;

    _makeAndAddNewChannelForOpponent(opponentId);
    createAnswer(opponentId, sdp);
  }

  @override
  void onSlowLinkReceived(bool? uplink, int? lost) {
    logTime("onSlowLinkReceived", _TAG);
    onSlowLink?.call(uplink, lost);
  }

  @override
  void onStartedEvent(String? started) {
    logTime("onStartedEvent started= $started", _TAG);
  }

  @override
  void onUnPublishedEvent(int? publisherId) {
    logTime("onUnPublishedEvent publisherID= $publisherId", _TAG);
  }

  @override
  void onVideoRoomEvent(String? event) {
    // TODO: implement onVideoRoomEvent
    logTime("onVideoRoomEvent event= $event", _TAG);
  }

  @override
  void onWebRTCUpReceived(int? senderId) {
    logTime("onWebRTCUpReceived senderId= $senderId", _TAG);
    if (isPublisherEvent(senderId)) {
      logTime("became a publisher");
      autoSubscribeToPublisher(true);
    }
  }

  @override
  void onAttachedAsSubscriber() {
    creatingSubscription = false;
  }

  void notifyJoinedSuccessListeners(List<int?> publishers) {
    _joinCallback(publishers);
  }

  void autoSubscribeToPublisher(bool autoSubscribe) async {
    if (autoSubscribe) {
      logTime("autoSubscribeToPublisher enabled");
      if (joinEventPublishers.isEmpty) return;

      subscribeToPublishers(joinEventPublishers);
    }
  }

  Future<void> selectJoinStrategy() async {
    if (ConferenceRole.PUBLISHER == sessionDescription.conferenceRole) {
      await proceedAsPublisher();
    } else {
      await proceedAsListener();
    }
  }

  Future<void> proceedAsPublisher() async {
    setState(RTCSessionState.RTC_SESSION_CONNECTING);
    _makeAndAddNewChannelForOpponent(publisherId);

    createOffer(publisherId);

    // _signaler.startPublish();
  }

  Future<void> proceedAsListener() async {
    if (joinEventPublishers.isNotEmpty) {
      subscribeToPublishers(joinEventPublishers);
    }
  }

  void _makeAndAddNewChannelForOpponent(int connectionId) {
    if (!channels.containsKey(connectionId)) {
      ConferencePeerConnection newChannel =
          new ConferencePeerConnection(connectionId, this);

      channels[connectionId] = newChannel;
      logTime("Make new channel with id: $connectionId, $newChannel", _TAG);
    } else {
      logTime("Channel with id $connectionId already exists", _TAG);
    }
  }

  void createOffer(int? opponentId) async {
    channels[opponentId]!.startOffer();
  }

  void createAnswer(int? opponentId, String? sdp) {
    ConferencePeerConnection? channel = channels[opponentId];
    if (channel != null) {
      logTime("setRemoteSdpToChannel", _TAG);
      channel.setRemoteSdp(RTCSessionDescription(sdp!, "offer"));
      channel.startAnswer();
    }
  }

  void sendIceCandidateComplete(int userId) async {
    logTime("signaler sendIceCandidateComplete for userId= $userId", _TAG);
    try {
      await _signaler.sendIceCandidateComplete(userId == publisherId);
    } on WsException catch (ex) {
      logTime("sendIceCandidateComplete error: = $ex");
      notifySessionError(ex);
    }
  }

  @override
  Future<MediaStream?> getLocalMediaStream(int userId) {
    if (ConferenceRole.LISTENER == sessionDescription.conferenceRole ||
        userId == subscriberId) {
      return Future.value(null);
    } else if (localStream != null) return Future.value(localStream);

    return initLocalMediaStream();
  }

  @override
  void onRemoteStreamReceive(int userId, MediaStream remoteMediaStream,
      {RTCRtpTransceiver? transceiver, MediaStreamTrack? track}) {
    log('[onRemoteStreamReceive] userId: $userId, trackId: ${track?.id}, trackMid: ${transceiver?.mid}',
        _TAG);
    if (track != null && transceiver != null) {
      trackIdMid[track.id!] = transceiver.mid;
    } else {
      remoteMediaStream.getTracks().forEach((track) {
        if (track.id?.startsWith(JANUS_PREFIX) ?? false) {
          trackIdMid[track.id!] = track.id!.replaceAll(JANUS_PREFIX, '');
        }
      });
    }

    var feedId = _signaler.subStreams[
        transceiver?.mid ?? track?.id?.replaceAll(JANUS_PREFIX, '')];

    if (transceiver == null) {
      onRemoteStreamTrackReceived?.call(this, feedId!, remoteMediaStream,
          trackId: track?.id);
    } else if (track != null) {
      if (kIsWeb) {
        createMediaStream(track.id!).then((mediaStream) {
          mediaStream.addTrack(track);

          remoteMediaStream.getTracks().forEach((remoteTrack) {
            if (remoteTrack.id != track.id) {
              var feedId2 = _signaler
                  .subStreams[remoteTrack.id?.replaceAll(JANUS_PREFIX, '')];

              if (feedId == feedId2) {
                mediaStream.addTrack(remoteTrack);
              }
            }
          });

          onRemoteStreamTrackReceived?.call(this, feedId!, mediaStream,
              trackId: track.id);
        });
      } else {
        if (track.kind == 'video') {
          onRemoteStreamTrackReceived?.call(this, feedId!, remoteMediaStream,
              trackId: track.id);
        }
      }
    }
  }

  @override
  void onRemoteStreamRemove(int userId, MediaStream remoteMediaStream,
      {String? trackId}) {
    if (trackId == null) {
      var feedId;

      remoteMediaStream.getTracks().forEach((track) {
        if (feedId == null) {
          feedId = _signaler.subStreams[track.id?.replaceAll(JANUS_PREFIX, '')];
        }
      });
      super
          .onRemoteStreamRemove
          .call(feedId ?? userId, remoteMediaStream, trackId: trackId);
    } else {
      var feedId =
          _signaler.subStreams[trackId.replaceAll(JANUS_PREFIX, '')] ?? userId;
      super
          .onRemoteStreamRemove
          .call(feedId, remoteMediaStream, trackId: trackId);
    }
  }

  @override
  void onStatsReceived(int userId, List<StatsReport> stats) {
    if (userId == publisherId) {
      statsReportsStreamController.add(CubeStatsReport(currentUserId, stats));

      return;
    }

    stats.forEach((stat) {
      if (stat.type == 'track') {
        trackIdTrackIdentifier[stat.id] = stat.values['trackIdentifier'];
      }
    });

    statsReportsStreamController.add(CubeStatsReport(userId, stats));
  }

  @override
  void onPeerConnectionStateChanged(int userId, PeerConnectionState state) {
    logTime(
        "[onPeerConnectionStateChanged] the connection state of ${userId == publisherId ? 'publisher' : 'subscriber'} changed to $state",
        _TAG);
    switch (state) {
      case PeerConnectionState.RTC_CONNECTION_NEW:
        break;
      case PeerConnectionState.RTC_CONNECTION_PENDING:
        break;
      case PeerConnectionState.RTC_CONNECTION_CONNECTING:
        break;
      case PeerConnectionState.RTC_CONNECTION_CHECKING:
        break;
      case PeerConnectionState.RTC_CONNECTION_CONNECTED:
        break;
      case PeerConnectionState.RTC_CONNECTION_DISCONNECTED:
        break;
      case PeerConnectionState.RTC_CONNECTION_TIMEOUT:
        break;
      case PeerConnectionState.RTC_CONNECTION_CLOSED:
        break;
      case PeerConnectionState.RTC_CONNECTION_FAILED:
        closeConnectionForOpponent(userId, null);
        break;
      case PeerConnectionState.RTC_CONNECTION_RENEGOTIATING:
        break;
      default:
        break;
    }
  }

  @override
  void notifySessionClosed() {
    super.notifySessionClosed();
    _signaler.setJanusResponseEventCallback(null);
    _signaler.stopAutoSendPresence();
  }

  @override
  void onSendAnswer(int userId, RTCSessionDescription sdp) async {
    logTime("onSendAnswer", _TAG);
    try {
      await _signaler.sendAnswer(
          sdp, sessionDescription.conferenceType, userId == publisherId);
    } on WsException catch (ex) {
      logTime("onSendAnswer error: = $ex");
      notifySessionError(ex);
    }
  }

  @override
  void onSendOffer(int userId, RTCSessionDescription sdp) async {
    logTime("onSendOffer", _TAG);
    try {
      await _signaler.sendOffer(
          sdp, sessionDescription.conferenceType, userId == publisherId);
    } on WsException catch (ex) {
      logTime("onSendOffer error: = $ex");
      notifySessionError(ex);
    }
  }

  @override
  void onSendUpdateCall(int userId, RTCSessionDescription sdp) async {
    logTime("onSendUpdateCall", _TAG);
    if (sdp.type == 'offer') {
      onSendOffer(userId, sdp);
    } else if (sdp.type == 'answer') {
      onSendAnswer(userId, sdp);
    }
  }

  @override
  void onSendIceCandidate(int userId, RTCIceCandidate iceCandidate) async {
    logTime("onSendIceCandidate", _TAG);
    if (isConnectionActive()) {
      try {
        await _signaler.sendIceCandidate(iceCandidate, userId == publisherId);
      } on WsException catch (ex) {
        logTime("onSendIceCandidate error: = $ex");
        notifySessionError(ex);
      }
    }
  }

  @override
  void onSendIceCandidates(int userId, List<RTCIceCandidate>? iceCandidates) {
    logTime("onSendIceCandidates", _TAG);
    iceCandidates!.forEach((iceCandidate) {
      onSendIceCandidate(userId, iceCandidate);
    });
  }

  @override
  void onIceGatheringStateChanged(int userId, RTCIceGatheringState state) {
    super.onIceGatheringStateChanged(userId, state);
    if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      sendIceCandidateComplete(userId);
    }
  }

  bool isConnectionActive() {
    return _signaler.isActive();
  }

  @override
  int get callType => sessionDescription.conferenceType;

  @override
  set callType(int callType) => sessionDescription.conferenceType = callType;

  bool isPublisherEvent(int? senderId) {
    return joinSenderId == senderId;
  }

  Future<void> _unsubscribeFromPublishers(Map<int, Set<String>?> publishers) {
    return _signaler.unsubscribeFromPublishers(publishers).then((_) {
      publishers.keys.forEach((publisher) {
        _connectionCallback?.onDisconnectedFromUser(this, publisher);
      });
    });
  }

  @override
  int getUserIdForStream(
    String? trackId,
    String? trackIdentifier,
    int defaultId,
  ) {
    if (defaultId == 1) return currentUserId;

    var mid;

    if (trackIdentifier?.startsWith(JANUS_PREFIX) ?? false) {
      mid = trackIdentifier?.replaceAll(JANUS_PREFIX, '');
    } else {
      var savedTrackId = trackIdTrackIdentifier[trackId];

      mid = trackIdMid[savedTrackId];
    }

    return _signaler.subStreams[mid] ?? defaultId;
  }

  @override
  void onSubStreamChangedForOpponent(int userId, StreamType streamType) {
    if (userId != -1) {
      onSubStreamChanged?.call(userId, streamType);
    }
  }

  @override
  void onLayerChangedForOpponent(int userId, int layer) {
    if (userId != -1 && layer != -1) {
      onLayerChanged?.call(userId, layer);
    }
  }

  @override
  Future<MediaStream> addMediaTrack(MediaStreamTrack track) {
    log('addMediaTrack', _TAG);

    if (localStream == null)
      return Future.error(IllegalStateException(
          'Can\'t add the track cause the local media stream doesn\'t exist'));

    localStream?.addTrack(track);

    return channels[publisherId]?.addTrack(track, localStream).then((value) {
          return localStream!;
        }).whenComplete(() {
          onLocalStreamReceived?.call(localStream!);
        }) ??
        Future.error(IllegalStateException(
            'Can\'t add the track cause the publisher\'s peer connection doesn\'t exist'));
  }

  @override
  Future<MediaStream> removeMediaTrack(String trackId) {
    if (localStream == null)
      return Future.error(IllegalStateException(
          'Can\'t remove the track cause the local media stream doesn\'t exist'));

    var track = localStream?.getTrackById(trackId);

    if (track == null) {
      return Future.error(IllegalStateException(
          'Can\'t remove the track cause it not found in the local media stream'));
    }

    return channels[publisherId]?.removeTrack(trackId).then((_) {
          localStream?.removeTrack(track);
          track.stop();
          onLocalStreamReceived?.call(localStream!);

          return localStream!;
        }) ??
        Future.error(IllegalStateException(
            'Can\'t remove the track cause the publisher\'s peer connection doesn\'t exist'));
  }
}
