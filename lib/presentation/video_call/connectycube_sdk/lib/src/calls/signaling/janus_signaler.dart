import 'dart:async';
import 'dart:collection';

import '../../../connectycube_calls.dart';
import 'web_socket_connection.dart';
import 'web_socket_packets.dart';
import 'web_socket_packets.dart' as web_socket_packets;

const String JOIN_JANUS_ROLE_PUBLISHER = "publisher";
const String JOIN_JANUS_ROLE_SUBSCRIBER = "subscriber";

const String STREAM_KIND_AUDIO = "audio";
const String STREAM_KIND_VIDEO = "video";

class JanusSignaler implements WsPacketListener {
  static const String TAG = "JanusSignaler";
  static const KEEP_ALIVE_PERIOD = Duration(seconds: 30);

  int? _currentUserId;
  int? _publisherHandleId;
  int? _subscriberHandleId;
  String? _meetingId;
  late WebSocketConnection _socketConnection;
  JanusResponseEventCallback? _janusResponseCallback;
  Timer? _keepAliveTimer;
  Map<String, int> subStreams = {};
  Map<String, String> streamTypes = {};
  Map<int, Set<String>?> activePublisherStreams = {};

  JanusSignaler(
      String url, String protocol, int socketTimeOutMs, int keepAliveValueSec) {
    _socketConnection = WebSocketConnection(url, protocol);
    _socketConnection.addPacketListener(this);
  }

  void setJanusResponseEventCallback(JanusResponseEventCallback? callback) {
    _janusResponseCallback = callback;
  }

  Future<void> startSession() {
    Completer completer = Completer<void>();
    _socketConnection.connect();
    _socketConnection.authenticate(completer);
    return completer.future;
  }

  void startAutoSendPresence() {
    logTime("startAutoSendPresence", TAG);
    _keepAliveTimer ??= Timer.periodic(KEEP_ALIVE_PERIOD, (Timer t) => sendKeepAlive());
  }

  void stopAutoSendPresence() {
    if (_keepAliveTimer?.isActive ?? false) _keepAliveTimer?.cancel();
  }

  Future<void> leave(int? userId, bool asPublisher) {
    WsRoomPacket requestPacket = WsRoomPacket();
    requestPacket.messageType = Type.message;
    requestPacket.handleId =
        asPublisher ? _publisherHandleId : _subscriberHandleId;
    requestPacket.body = Body()
      ..room = _meetingId
      ..userId = userId
      ..request = WsRoomPacketType.leave;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> detachPlugin(int? handleId) {
    WsDetach packet = WsDetach();
    packet.messageType = Type.detach;
    packet.handleId = handleId;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(packet, Type.success, completer);
    return completer.future;
  }

  Future<void> attachPlugin(String pluginId, bool asPublisher) {
    WsPluginPacket packet = WsPluginPacket();
    packet.messageType = Type.attach;
    packet.plugin = pluginId;
    Completer<void> result = Completer();
    Completer<WsDataPacket> completer = Completer();
    _socketConnection.createCollectorAndSend(packet, Type.success, completer);
    completer.future.then((wsDataPacket) {
      logTime("attachPlugin wsDataPacket= $wsDataPacket", TAG);
      int? handleId = wsDataPacket.getData().id;
      if (asPublisher) {
        _publisherHandleId = handleId;
      } else {
        _subscriberHandleId = handleId;
      }
      result.complete();
    });
    return result.future;
  }

  Future<void> joinDialog(String dialogId, int currentUserId, String janusRole,
      ConferenceRole conferenceRole, bool asPublisher) {
    _currentUserId = currentUserId;
    _meetingId = dialogId;
    WsRoomPacket requestPacket = joinPacket(janusRole, asPublisher);
    requestPacket.body!.display = conferenceRole.name.toLowerCase();
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> startPublish() {
    WsRoomPacket requestPacket = WsRoomPacket();
    requestPacket.messageType = Type.message;
    requestPacket.handleId = _publisherHandleId;
    requestPacket.body = Body()..request = WsRoomPacketType.publish;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> joinDialogAsSubscriber(Set<int> feeds) {
    WsRoomPacket requestPacket = joinSubscriberPacket(feeds);
    requestPacket.body!.display = ConferenceRole.LISTENER.name.toLowerCase();
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> subscribe(Set<int> feeds) {
    WsRoomPacket requestPacket = WsRoomPacket();
    requestPacket.messageType = Type.message;
    requestPacket.handleId = _subscriberHandleId;
    requestPacket.body = Body()
      ..room = _meetingId
      ..request = WsRoomPacketType.subscribe
      ..feeds = Map.fromEntries(feeds.map((userId) {
        return MapEntry(userId, activePublisherStreams[userId]);
      }))
      ..userId = _currentUserId;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  // Temporary unused but can be used later
  Future<void> updateStreamSubscriptions(
      int feedId, List<Stream>? added, List<Stream>? removed) {
    logTime(
        '[updateStreamSubscriptions] subscriberHandleId: $_subscriberHandleId, publisherHandleId: $_publisherHandleId',
        TAG);
    _meetingId = _meetingId;
    WsUpdateStreamSubscription requestPacket =
        WsUpdateStreamSubscription(added: added, removed: removed);
    requestPacket.messageType = Type.message;
    requestPacket.handleId = _subscriberHandleId;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> sendIceCandidate(
      RTCIceCandidate iceCandidate, bool asPublisher) {
    WsCandidate requestPacket = WsCandidate();
    requestPacket.messageType = Type.trickle;
    requestPacket.handleId =
        asPublisher ? _publisherHandleId : _subscriberHandleId;
    requestPacket.candidate = web_socket_packets.Candidate();
    requestPacket.candidate.candidate = iceCandidate.candidate;
    requestPacket.candidate.sdpMLineIndex = iceCandidate.sdpMLineIndex;
    requestPacket.candidate.sdpMid = iceCandidate.sdpMid;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> sendIceCandidateComplete(bool asPublisher) {
    WsCandidate requestPacket = WsCandidate();
    requestPacket.messageType = Type.trickle;
    requestPacket.handleId =
        asPublisher ? _publisherHandleId : _subscriberHandleId;
    requestPacket.candidate = web_socket_packets.Candidate();
    requestPacket.candidate.completed = true;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> sendOffer(
      RTCSessionDescription rtcSdp, int callType, bool asPublisher) {
    bool isVideoType = callType == CallType.VIDEO_CALL;
    WsOffer requestPacket = WsOffer();
    requestPacket.messageType = Type.message;
    requestPacket.handleId =
        asPublisher ? _publisherHandleId : _subscriberHandleId;
    requestPacket.body = WsOfferBody();
    requestPacket.body.audio = true;
    requestPacket.body.video = isVideoType;
    requestPacket.body.request = WsOfferAnswerType.configure;
    requestPacket.jsep = Jsep();
    requestPacket.jsep.type = rtcSdp.type;
    requestPacket.jsep.sdp = rtcSdp.sdp;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> sendAnswer(
      RTCSessionDescription rtcSdp, int callType, bool asPublisher) {
    WsAnswer requestPacket = WsAnswer();
    requestPacket.messageType = Type.message;
    requestPacket.handleId =
        asPublisher ? _publisherHandleId : _subscriberHandleId;
    requestPacket.body = WsAnswerBody();
    requestPacket.body.room = _meetingId;
    requestPacket.body.request = WsOfferAnswerType.start;
    requestPacket.jsep = Jsep();
    requestPacket.jsep.type = rtcSdp.type;
    requestPacket.jsep.sdp = rtcSdp.sdp;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  void destroySession() {
    _socketConnection.closeSession();
  }

  Future<void> sendKeepAlive() {
    WsKeepAlive requestPacket = WsKeepAlive();
    requestPacket.messageType = Type.keepalive;
    Completer completer = Completer<void>();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> sendBitrateConfig(int userId, int bitrate) {
    WsStreamConfig requestPacket = WsStreamConfig({'bitrate': bitrate * 1000});
    requestPacket.messageType = Type.message;
    requestPacket.handleId = _publisherHandleId;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> requestPreferredStreamsForUsers(Map<int, StreamType> configs) {
    WsStreamConfig requestPacket =
        WsStreamConfig({'streams': prepareSubStreamsConfig(configs)});
    requestPacket.messageType = Type.message;
    requestPacket.handleId = _subscriberHandleId;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  Future<void> requestPreferredLayersForUsersStreams(Map<int, int> configs) {
    WsStreamConfig requestPacket =
        WsStreamConfig({'streams': prepareLayersConfig(configs)});
    requestPacket.messageType = Type.message;
    requestPacket.handleId = _subscriberHandleId;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }

  List<Map<String, dynamic>> prepareSubStreamsConfig(
      Map<int, StreamType> configs) {
    List<Map<String, dynamic>> result = [];

    configs.forEach((userId, streamType) {
      result.add({
        'mid': getVideoMidForUser(userId),
        'substream': streamTypeToInt(streamType),
      });
    });

    return result;
  }

  List<Map<String, dynamic>> prepareLayersConfig(Map<int, int> configs) {
    List<Map<String, dynamic>> result = [];

    configs.forEach((userId, layer) {
      result.add({
        'mid': getVideoMidForUser(userId),
        'temporal': layer,
      });
    });

    return result;
  }

  String getVideoMidForUser(int userId) {
    var videoMid = '';

    subStreams.forEach((mid1, value) {
      if (value == userId) {
        streamTypes.forEach((mid2, type) {
          if (mid1 == mid2 && type == STREAM_KIND_VIDEO) {
            videoMid = mid2;
          }
        });
      }
    });

    return videoMid;
  }

  bool isActive() {
    return _socketConnection.isActiveSession();
  }

  WsRoomPacket joinPacket(String janusRole, bool asPublisher) {
    WsRoomPacket requestPacket = WsRoomPacket();
    requestPacket.messageType = Type.message;
    requestPacket.handleId =
        asPublisher ? _publisherHandleId : _subscriberHandleId;
    requestPacket.body = Body()
      ..request = WsRoomPacketType.join
      ..ptype = janusRole
      ..room = _meetingId
      ..userId = _currentUserId;
    return requestPacket;
  }

  WsRoomPacket joinSubscriberPacket(Set<int> feeds) {
    WsRoomPacket requestPacket = WsRoomPacket();
    requestPacket.messageType = Type.message;
    requestPacket.handleId = _subscriberHandleId;
    requestPacket.body = Body()
      ..request = WsRoomPacketType.join
      ..ptype = JOIN_JANUS_ROLE_SUBSCRIBER
      ..room = _meetingId
      ..feeds = Map.fromEntries(feeds.map((userId) {
        return MapEntry(userId, activePublisherStreams[userId]);
      }));
    return requestPacket;
  }

  void packetParser(WsPacket packet) {
    if (packet is WsEvent) {
      eventParser(packet);
    } else if (packet is WsWebRTCUp) {
      logTime("WsWebRTCUp packet sender= ${packet.sender.toString()}", TAG);
      _janusResponseCallback?.onWebRTCUpReceived(packet.sender);
    } else if (packet is WsMedia) {
      logTime(
          "WsMedia packet type= ${packet.type}, receiving= ${packet.receiving.toString()}",
          TAG);
      _janusResponseCallback?.onMediaReceived(packet.type, packet.receiving);
    } else if (packet is WsHangUp) {
      logTime("WsHangUp packet reason= ${packet.reason!}", TAG);
      _janusResponseCallback?.onHangUp(packet.reason);
    } else if (packet is WsSlowLink) {
      logTime("WsSlowLink packet uplink= ${packet.uplink}", TAG);
      _janusResponseCallback?.onSlowLinkReceived(packet.uplink, packet.lost);
    } else if (packet is WsDataPacket) {
      if (packet.isGetParticipant()) {
        List<Map<String, Object>> participants =
            packet.plugindata!.data.participants;
        _janusResponseCallback?.onGetOnlineParticipants(
            convertParticipantListToArray(participants));
      } else if (packet.isVideoRoomEvent()) {
        _janusResponseCallback?.onVideoRoomEvent(packet.plugindata!.data.error);
      }
    } else if (packet is WsError) {
      _janusResponseCallback?.onEventError(
          packet.error.reason, packet.error.code);
    }
  }

  Map<int?, bool?> convertParticipantListToArray(
      List<Map<String, Object>> participants) {
    Map<int?, bool?> publishersMap = HashMap<int?, bool?>();
    for (var element in participants) {
      int? id = element["id"] as int?;
      bool? isPublisher = element["publisher"] as bool?;
      publishersMap[id] = isPublisher;
    }

    return publishersMap;
  }

  List<int> convertPublishersToArray(List<Publisher>? publishers) {
    List<int> publishersArray = [];

    if (publishers == null) return publishersArray;

    for (var publisher in publishers) {
      publishersArray.add(publisher.id!);
    }

    return publishersArray;
  }

  List<int> convertSubscribersToArray(List<Subscriber>? subscribers) {
    List<int> subscribersArray = [];

    if (subscribers == null) return subscribersArray;

    for (var subscriber in subscribers) {
      subscribersArray.add(subscriber.id!);
    }

    return subscribersArray;
  }

  void eventParser(WsEvent wsEvent) {
    if (wsEvent.isRemoteSDPEventAnswer()) {
      logTime(
          "RemoteSDPEventAnswer wsEvent with sdp type= ${wsEvent.jsep!.type}",
          TAG);
      _janusResponseCallback?.onRemoteSDPEventAnswer(
          wsEvent.sender == _publisherHandleId, wsEvent.jsep!.sdp);
    } else if (wsEvent.isRemoteSDPEventOffer()) {
      int? opponentId = wsEvent.plugindata!.data.id;
      logTime(
          "RemoteSDPEventOffer wsEvent with sdp type= ${wsEvent.jsep!.type}, opponentId= $opponentId",
          TAG);

      if (wsEvent.plugindata?.data.streams != null) {
        wsEvent.plugindata?.data.streams?.forEach((stream) {
          if (stream.mid != null && stream.feedId != null) {
            subStreams[stream.mid!] = int.parse(stream.feedId.toString());
            streamTypes[stream.mid!] = stream.type!;
          }
        });
      }

      _janusResponseCallback?.onRemoteSDPEventOffer(
          opponentId, wsEvent.jsep?.sdp);

      if (wsEvent.plugindata?.data.videoroom == 'attached') {
        _janusResponseCallback?.onAttachedAsSubscriber();
      }
    } else if (wsEvent.isJoiningEvent()) {
      int? participantId = wsEvent.plugindata!.data.participant!.id;
      String? displayRole = wsEvent.plugindata!.data.participant!.display;
      ConferenceRole? conferenceRole;
      if (displayRole != null) {
        conferenceRole = ConferenceRole.values.firstWhere((e) =>
            e.toString() == 'ConferenceRole.${displayRole.toUpperCase()}');
      }
      logTime(
          "isJoiningEvent participantId= $participantId , conferenceRole= $displayRole",
          TAG);
      _janusResponseCallback?.onJoiningEvent(participantId!, conferenceRole);
    } else if (wsEvent.isJoinEvent()) {
      List<Publisher>? publishers = wsEvent.plugindata!.data.publishers;
      List<Subscriber>? subscribers = wsEvent.plugindata!.data.subscribers;
      logTime(
          "JoinEvent publishers= $publishers , subscribers= $subscribers", TAG);

      publishers?.forEach((publisher) {
        publisher.streams?.forEach((stream) {
          if (!stream.disabled!) {
            if (activePublisherStreams[publisher.id] == null) {
              activePublisherStreams[publisher.id!] = {};
            }
            activePublisherStreams[publisher.id]!.add(stream.mid!);
          }
        });
      });

      List<int> publishersList = convertPublishersToArray(publishers);
      List<int> subscribersList = convertSubscribersToArray(subscribers);
      _janusResponseCallback?.onJoinEvent(
          publishersList, subscribersList, wsEvent.sender!);
    } else if (wsEvent.isEventError()) {
      _janusResponseCallback?.onEventError(
          wsEvent.plugindata!.data.error, wsEvent.plugindata!.data.errorCode);
    } else if (wsEvent.isPublisherEvent()) {
      List<Publisher>? publishers = wsEvent.plugindata!.data.publishers;
      logTime("PublisherEvent wsEvent publishers= $publishers", TAG);

      publishers?.forEach((publisher) {
        publisher.streams?.forEach((stream) {
          if (!stream.disabled!) {
            if (activePublisherStreams[publisher.id] == null) {
              activePublisherStreams[publisher.id!] = {};
            }
            activePublisherStreams[publisher.id]!.add(stream.mid!);
          }
        });
      });

      _janusResponseCallback
          ?.onPublishedEvent(convertPublishersToArray(publishers));
    } else if (wsEvent.isUnPublishedEvent()) {
      int? usedId = wsEvent.plugindata!.data.unpublished;
      logTime("UnPublishedEvent  unpublished usedId= $usedId", TAG);
      _janusResponseCallback?.onUnPublishedEvent(usedId);
    } else if (wsEvent.isStartedEvent()) {
      logTime(
          "StartedEvent subscribed started= ${wsEvent.plugindata!.data.started}",
          TAG);
      _janusResponseCallback?.onStartedEvent(wsEvent.plugindata!.data.started);
    } else if (wsEvent.isLeaveParticipantEvent()) {
      final leaving = wsEvent.plugindata!.data.leaving;
      int? userId = leaving is String ? int.tryParse(leaving) : leaving;
      logTime("LeavePublisherEvent left userId= ${userId.toString()}", TAG);
      _janusResponseCallback?.onLeaveParticipantEvent(userId);
    } else if (wsEvent.isLeaveCurrentUserEvent() ||
        wsEvent.isLeftCurrentUserEvent()) {
      bool leavingOk = wsEvent.plugindata!.data.leaving == "ok" ||
          wsEvent.plugindata!.data.left == "ok";
      logTime("isLeaveCurrentUserEvent leavingOk? $leavingOk", TAG);
      _janusResponseCallback?.onLeaveCurrentUserEvent(leavingOk);
    } else if (wsEvent.isStreamChangedEvent()) {
      var userId = subStreams[wsEvent.plugindata?.data.mId];
      var streamType = intToStreamType(wsEvent.plugindata?.data.subStream);
      logTime(
          "isStreamChangedEvent userId: $userId, streamType: $streamType", TAG);
      _janusResponseCallback?.onSubStreamChangedForOpponent(
          userId ?? -1, streamType);
    } else if (wsEvent.isLayerChangedEvent()) {
      var userId = subStreams[wsEvent.plugindata?.data.mId];
      var layer = wsEvent.plugindata?.data.layer;
      logTime("isLayerChangedEvent userId: $userId, layer: $layer", TAG);
      _janusResponseCallback?.onLayerChangedForOpponent(
          userId ?? -1, layer ?? -1);
    }
  }

  @override
  onPacketReceived(WsPacket packet) {
    log("_onPacketReceived= $packet");
    packetParser(packet);
  }

  @override
  onPacketError(WsPacket packet, String error) {
    log("onPacketError= $packet, error=$error");
  }

  Future<void> unsubscribeFromPublishers(Map<int, Set<String>?> publishers) {
    WsRoomPacket requestPacket = WsRoomPacket();
    requestPacket.messageType = Type.message;
    requestPacket.handleId = _subscriberHandleId;
    requestPacket.body = Body()
      ..room = _meetingId
      ..request = WsRoomPacketType.unsubscribe
      ..feeds = publishers
      ..userId = _currentUserId;
    Completer completer = Completer();
    _socketConnection.createCollectorAndSend(
        requestPacket, Type.ack, completer);
    return completer.future;
  }
}

int streamTypeToInt(StreamType type) {
  switch (type) {
    case StreamType.high:
      return 2;
    case StreamType.medium:
      return 1;
    case StreamType.low:
      return 0;
  }
}

StreamType intToStreamType(int? type) {
  switch (type) {
    case 2:
      return StreamType.high;
    case 1:
      return StreamType.medium;
    case 0:
      return StreamType.low;
    default:
      return StreamType.low;
  }
}

abstract class JanusResponseEventCallback {
  void onRemoteSDPEventAnswer(bool fromPublisher, String? sdp);

  void onRemoteSDPEventOffer(int? opponentId, String? sdp);

  void onJoiningEvent(int participantId, ConferenceRole? conferenceRole);

  void onJoinEvent(
      List<int> publishersList, List<int> subscribersList, int senderID);

  void onPublishedEvent(List<int> publishersList);

  void onUnPublishedEvent(int? publisherID);

  void onStartedEvent(String? started);

  void onLeaveParticipantEvent(int? publisherID);

  void onLeaveCurrentUserEvent(bool success);

  void onWebRTCUpReceived(int? senderID);

  void onMediaReceived(String? type, bool? success);

  void onSlowLinkReceived(bool? uplink, int? lost);

  void onHangUp(String? reason);

  void onEventError(String? error, int? code);

  void onPacketError(String error);

//    returns map with ids participants and boolean is this participant a publisher
  void onGetOnlineParticipants(Map<int?, bool?> participants);

  void onVideoRoomEvent(String? event);

  void onAttachedAsSubscriber();

  void onSubStreamChangedForOpponent(int userId, StreamType streamType);

  void onLayerChangedForOpponent(int userId, int layer);
}

enum ConferenceRole { PUBLISHER, LISTENER }

enum StreamType { high, medium, low }
