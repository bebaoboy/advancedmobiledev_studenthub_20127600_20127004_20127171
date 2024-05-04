// ignore_for_file: empty_catches

import 'dart:convert';

import 'package:boilerplate/core/widgets/pip/navigatable_pip_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/notification/notification.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:universal_io/io.dart';
import 'package:boilerplate/core/widgets/pip/picture_in_picture.dart';
import 'package:boilerplate/core/widgets/pip/pip_params.dart';
import 'package:boilerplate/core/widgets/pip/pip_view_corner.dart';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';

import 'call_kit_manager.dart';
import '../conversation_screen.dart';
import '../incoming_call_screen.dart';
import '../utils/configs.dart';
import '../utils/consts.dart';

class CallManager {
  static String TAG = "BEBAOBOY";

  static CallManager get instance => _getInstance();
  static CallManager? _instance;

  static CallManager _getInstance() {
    return _instance ??= CallManager._internal();
  }

  factory CallManager() => _getInstance();

  CallManager._internal();

  P2PClient? _callClient;
  P2PSession? currentCall;
  BuildContext? context;
  MediaStream? localMediaStream;
  InterviewSchedule? currentInterview;
  Map<int, MediaStream> remoteStreams = {};
  Function(bool, String)? onMicMuted;
  bool isCameraEnabled = true;
  bool isSpeakerEnabled = !kIsWeb
      ? Platform.isIOS
          ? false
          : true
      : true;
  bool isMicMute = false;
  bool isFrontCameraUsed = true;
  String? cameraId;
  bool waitingCall = false;
  @observable
  bool hasEnded = false;
  Map<String, String> savedMeetingInfo = {};

  init(BuildContext context) {
    this.context = context;

    _initCustomMediaConfigs();

    if (CubeChatConnection.instance.isAuthenticated()) {
      _initCalls();
    } else {
      _initChatConnectionStateListener();
    }

    _initCallKit();
  }

  destroy() {
    _callClient?.destroy();
    _callClient = null;
  }

  void _initCustomMediaConfigs() {
    RTCMediaConfig mediaConfig = RTCMediaConfig.instance;
    mediaConfig.minHeight = 720;
    mediaConfig.minWidth = 1280;
    mediaConfig.minFrameRate = 30;

    RTCConfig.instance.statsReportsInterval = 200;
  }

  void _initCalls() {
    if (_callClient == null) {
      _callClient = P2PClient.instance;

      _callClient!.init();
    }

    log("init call manager");

    _callClient!.onReceiveNewSession = (callSession) async {
      // if (currentCall != null &&
      //     currentCall!.sessionId != callSession.sessionId) {
      //   log("reject call, sessionId mismatch", "BEBAOBOY");
      //   callSession.reject();
      //   return;
      // }
      currentCall = callSession;
      log("incoming call ${currentCall?.sessionId}");

      var callState = await _getCallState(currentCall!.sessionId);
      log("incoming call $callState");

      if (callState == CallState.REJECTED) {
        reject(currentCall!.sessionId, false);
      } else if (callState == CallState.ACCEPTED) {
        acceptCall(currentCall!.sessionId, false);
      } else if (callState == CallState.UNKNOWN ||
          callState == CallState.PENDING) {
        if (callState == CallState.UNKNOWN &&
            !kIsWeb &&
            (Platform.isIOS || Platform.isAndroid)) {
          ConnectycubeFlutterCallKit.setCallState(
              sessionId: currentCall!.sessionId, callState: CallState.PENDING);
        }

        _showIncomingCallScreen(currentCall!);
      }

      currentCall?.onLocalStreamReceived = (localStream) {
        localMediaStream = localStream;
      };

      currentCall?.onRemoteStreamReceived = (session, userId, stream) {
        remoteStreams[userId] = stream;
      };

      currentCall?.onRemoteStreamRemoved = (session, userId, stream) {
        remoteStreams.remove(userId);
      };
    };

    _callClient!.onSessionClosed = (callSession) async {
      if (currentCall != null &&
          currentCall!.sessionId == callSession.sessionId) {
        currentCall = null;
        CallManager.instance.hasEnded = true;
        localMediaStream?.getTracks().forEach((track) async {
          await track.stop();
        });
        await localMediaStream?.dispose();
        localMediaStream = null;

        try {
          remoteStreams.forEach((key, value) async {
            await value.dispose();
          });
        } catch (e) {
          log("error");
        }

        remoteStreams.clear();
        CallKitManager.instance.processCallFinished(callSession.sessionId);
        if (PictureInPicture.isActive) {
          PictureInPicture.stopPiP(false);
        }
      }
    };
  }

  @observable
  static bool inAppPip = false;

  resetPreview() {
    isCameraEnabled = true;
    isSpeakerEnabled = !kIsWeb
        ? Platform.isIOS
            ? false
            : true
        : true;
    isMicMute = false;
    isFrontCameraUsed = false;
    cameraId = null;
    hasEnded = false;
  }

  void startPreviewMeeting(BuildContext context, int callType,
      Set<int> opponents, InterviewSchedule interviewSchedule,
      {bool useInAppPip = true}) async {
    if (CubeSessionManager.instance.activeSession == null ||
        CubeSessionManager.instance.activeSession!.user == null) return;
    if (opponents.isEmpty) return;
    resetPreview();
    waitingCall = false;

    if (!kIsWeb && Platform.isIOS) {
      Helper.setAppleAudioIOMode(AppleAudioIOMode.localAndRemote);
    }
    P2PSession callSession =
        _callClient!.createCallSession(callType, opponents);
    currentCall = callSession;
    log(CubeSessionManager.instance.activeSession.toString());
    currentInterview = null;
    if (getIt<UserStore>().user!.type == UserType.student) {
      waitingCall = true;
    }

    Navigator.of(context).push(MaterialPageRoute2(
        routeName:
            "${Routes.previewMeeting}/${CubeSessionManager.instance.activeSession!.user!.id}",
        arguments: [users, interviewSchedule, currentCall]));
  }

  void startPreviewMeetingIncomingCall(BuildContext context, int callType,
      Set<int> opponents, P2PSession? currentCall,
      {required bool fromCallkit, bool useInAppPip = true}) async {
    if (opponents.isEmpty || currentCall == null) return;
    if (!waitingCall) resetPreview();

    if (!kIsWeb && Platform.isIOS) {
      Helper.setAppleAudioIOMode(AppleAudioIOMode.localAndRemote);
    }

    if (currentInterview == null) {
      log("interview is null");
    } else {
      log("interview: ${currentInterview!.toJson()}");
    }
    Navigator.of(context).push(MaterialPageRoute2(
        routeName:
            "${Routes.previewMeeting}/${CubeSessionManager.instance.activeSession!.user!.id}",
        arguments: [users, null, currentCall]));
  }

  void startNewCall(BuildContext context, int callType, Set<int> opponents,
      P2PSession callSession2, InterviewSchedule interviewSchedule,
      {bool incoming = false, required bool fromCallkit}) async {
    if (opponents.isEmpty) return;

    if (!kIsWeb && Platform.isIOS) {
      Helper.setAppleAudioIOMode(AppleAudioIOMode.localAndRemote);
    }

    // P2PSession callSession =
    //     _callClient!.createCallSession(callType, opponents);

    if (currentInterview != null) {
      currentInterview = null;
      incoming = true;
    }

    log("device info enableCam=$isCameraEnabled, muteMic=$isMicMute, frontCam=$isFrontCameraUsed, speaker=$isSpeakerEnabled");

    if (incoming) {
      // TODO: put 2 of this somewhere else
      if (AppLifecycleState.resumed != WidgetsBinding.instance.lifecycleState) {
        currentCall?.acceptCall();
      }
      if (!fromCallkit) {
        ConnectycubeFlutterCallKit.reportCallAccepted(
            sessionId: currentCall!.sessionId);
      }
      users.add(CubeUser(
          id: currentCall!.callerId,
          fullName: "Caller name ${currentCall!.callerId}"));
    } else {
      // this is CRUCIAL dont delete it //
      //
      // TODO: lưu camera nào, speaker hay k bật, bật mic hay k

      P2PSession callSession =
          _callClient!.createCallSession(callType, opponents);
      currentCall = callSession;
      //
      ////////////////////////////////////
      ///
      ///
      bool isProduction = const bool.fromEnvironment('dart.vm.product');

      CreateEventParams params = CreateEventParams();
      params.parameters = {
        'message': "You have an interview 💌", // 'message' field is required
        'title': "You have an interview 💌", // 'message' field is required
        'session_id': currentCall!.sessionId,
        'opponents': json.encode([
          ...opponents,
          CubeSessionManager.instance.activeSession!.user!.id
        ]),
        'ios_voip': 1, // to send VoIP push notification to iOS
        'type': "interview",
        "android_fcm_notification": {
          "title": "debug",
          "body": json.encode(interviewSchedule.toJson()),
          "sticky": true,
          "channel_id": NotificationChannelEnum.basicChannel.key,
          "color": "#FF0000"
        },
        "extra_body": {
          "title": "debug",
          "body": json.encode(interviewSchedule.toJson()),
          "sticky": true,
          "channel_id": NotificationChannelEnum.interviewChannel.key,
          "color": "#FF0000"
        },
        // "expiration": "1714662049"
        "expiration": DateTime.now()
            .add(const Duration(seconds: 20))
            .millisecondsSinceEpoch,
        //more standard parameters you can found by link https://developers.connectycube.com/server/push_notifications?id=universal-push-notifications
      };
      log("background message ${params.parameters}");

      params.notificationType = CubeNotificationType.PUSH;
      params.environment = isProduction
          ? CubeEnvironment.PRODUCTION
          : CubeEnvironment.DEVELOPMENT;
      params.usersIds = [
        ...opponents,
        CubeSessionManager.instance.activeSession!.user!.id
      ];
      log("done incoming call event $opponents");

      createEvent(params.getEventForRequest())
          .then((cubeEvent) {})
          .catchError((error) {});
      log("done event for call $params");
    }

    if (inAppPip) {
      PictureInPicture.updatePiPParams(
        pipParams: PiPParams(
          pipWindowHeight: MediaQuery.of(context).size.height * 0.95,
          pipWindowWidth: MediaQuery.of(context).size.width * 0.95,
          bottomSpace: 64,
          leftSpace: 64,
          rightSpace: 64,
          topSpace: 64,
          minSize: Size((MediaQuery.of(context).size.width * 0.95) * 0.3,
              (MediaQuery.of(context).size.height * 0.95) * 0.4),
          maxSize: MediaQuery.of(context).size,
          movable: true,
          resizable: true,
          initialCorner: PIPViewCorner.topLeft,
          openWidgetOnClose: false,
        ),
      );
      PictureInPicture.startPiP(
          pipWidget: NavigatablePiPWidget(
              onPiPClose: () {
                //Handle closing events e.g. dispose controllers.
                // _enableScreenSharing = false;
                // _toggleScreenSharing();
                hungUp();
              },
              elevation: 10, //Optional
              pipBorderRadius: 10,
              builder: (context) =>
                  ConversationCallScreen(currentCall!, incoming)));
    } else {
      Navigator.push(
        NavigationService.navigatorKey.currentContext ?? context,
        MaterialPageRoute(
          builder: (context) => ConversationCallScreen(currentCall!, incoming),
        ),
      );
    }

    waitingCall = false;

    _sendStartCallSignalForOffliners(currentCall!);
  }

  void _showIncomingCallScreen(P2PSession callSession) async {
    if (waitingCall) {
      log("accept incoming call fast");
      acceptCall(callSession.sessionId, false);
      return;
    }
    CallEvent callEvent = CallEvent(
        sessionId: callSession.sessionId,
        callType: callSession.callType,
        callerId: callSession.callerId,
        callerName: 'Caller Name',
        opponentsIds: callSession.opponentsIds,
        userInfo: const {'customParameter1': 'value1'});
    log("show incomin call screen $callSession");
    await ConnectycubeFlutterCallKit.showCallNotification(callEvent);
    if (NavigationService.navigatorKey.currentContext != null) {
      Navigator.push(
        NavigationService.navigatorKey.currentContext!,
        MaterialPageRoute2(
          child: IncomingCallScreen(callSession),
        ),
      );
    }
  }

  void acceptCall(String sessionId, bool fromCallkit) {
    log('acceptCall, from callKit: $fromCallkit', TAG);
    ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);

    if (currentCall != null) {
      if (context != null) {
        // if (AppLifecycleState.resumed !=
        //     WidgetsBinding.instance.lifecycleState) {
        //   _currentCall?.acceptCall();
        // }

        // if (!fromCallkit) {
        //   ConnectycubeFlutterCallKit.reportCallAccepted(sessionId: sessionId);
        // }
        if (NavigationService.navigatorKey.currentContext != null) {
          // Navigator.pushReplacement(
          //   NavigationService.navigatorKey.currentContext!,
          //   MaterialPageRoute2(
          //     child: ConversationCallScreen(_currentCall!, true),
          //   ),
          // );
          var context = NavigationService.navigatorKey.currentContext!;
          startPreviewMeetingIncomingCall(context, CallType.VIDEO_CALL,
              currentCall?.opponentsIds ?? {}, currentCall,
              fromCallkit: fromCallkit);
          // PictureInPicture.updatePiPParams(
          //   pipParams: PiPParams(
          //     pipWindowHeight: MediaQuery.of(context).size.height * 0.95,
          //     pipWindowWidth: MediaQuery.of(context).size.width * 0.95,
          //     bottomSpace: 64,
          //     leftSpace: 64,
          //     rightSpace: 64,
          //     topSpace: 64,
          //     minSize: Size((MediaQuery.of(context).size.width * 0.95) / 2,
          //         (MediaQuery.of(context).size.height * 0.95) / 2),
          //     maxSize: MediaQuery.of(context).size,
          //     movable: true,
          //     resizable: true,
          //     initialCorner: PIPViewCorner.topLeft,
          //     openWidgetOnClose: false,
          //   ),
          // );
          // PictureInPicture.startPiP(
          //     pipWidget: NavigatablePiPWidget(
          //         onPiPClose: () {
          //           //Handle closing events e.g. dispose controllers.
          //           // _enableScreenSharing = false;
          //           // _toggleScreenSharing();
          //           hungUp();
          //         },
          //         elevation: 10, //Optional
          //         pipBorderRadius: 10,
          //         builder: (context) =>
          //             ConversationCallScreen(_currentCall!, true)));
        }
      }

      if (!kIsWeb && Platform.isIOS) {
        Helper.setAppleAudioIOMode(AppleAudioIOMode.localAndRemote);
      }
    }
  }

  void reject(String sessionId, bool fromCallkit) {
    if (currentCall != null) {
      if (fromCallkit) {
        ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: false);
      } else {
        CallKitManager.instance.processCallFinished(currentCall!.sessionId);
      }

      currentCall!.reject();
      _sendEndCallSignalForOffliners(currentCall);
    } else {
      // Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
    }
  }

  void hungUp() {
    hasEnded = true;
    if (currentCall != null) {
      CallKitManager.instance.processCallFinished(currentCall!.sessionId);
      currentCall!.hungUp();
      _sendEndCallSignalForOffliners(currentCall);
    } else {
      // Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
    }
  }

  CreateEventParams _getCallEventParameters(P2PSession currentCall) {
    String? callerName = users
        .where((cubeUser) => cubeUser.id == currentCall.callerId)
        .first
        .fullName;

    CreateEventParams params = CreateEventParams();
    params.parameters = {
      'message':
          "Hello my cutie pie, this is an incoming ${currentCall.callType == CallType.VIDEO_CALL ? "Video" : "Audio"} call",
      PARAM_CALL_TYPE: currentCall.callType,
      PARAM_SESSION_ID: currentCall.sessionId,
      PARAM_CALLER_ID: currentCall.callerId,
      PARAM_CALLER_NAME: callerName,
      PARAM_CALL_OPPONENTS: currentCall.opponentsIds.join(','),
    };

    params.notificationType = CubeNotificationType.PUSH;
    params.environment = CubeEnvironment.DEVELOPMENT;
    params.usersIds = currentCall.opponentsIds.toList();

    return params;
  }

  void _sendStartCallSignalForOffliners(P2PSession currentCall) {
    CreateEventParams params = _getCallEventParameters(currentCall);
    params.parameters[PARAM_SIGNAL_TYPE] = SIGNAL_TYPE_START_CALL;
    params.parameters[PARAM_IOS_VOIP] = 1;
    params.parameters[PARAM_EXPIRATION] = 0;
    params.parameters['ios_push_type'] = 'voip';

    createEvent(params.getEventForRequest()).then((cubeEvent) {
      log("Event for offliners created: $cubeEvent", "BEBAOBOY");
    }).catchError((error) {
      log("ERROR occurs during create event: ${error.toString()}", "BEBAOBOY");
    });
  }

  void _sendEndCallSignalForOffliners(P2PSession? currentCall) {
    if (currentCall == null) return;

    CubeUser? currentUser = CubeChatConnection.instance.currentUser;
    if (currentUser == null || currentUser.id != currentCall.callerId) return;

    CreateEventParams params = _getCallEventParameters(currentCall);
    params.parameters[PARAM_SIGNAL_TYPE] = SIGNAL_TYPE_END_CALL;

    createEvent(params.getEventForRequest()).then((cubeEvent) {
      log("Event for offliners created");
    }).catchError((error) {
      log("ERROR occurs during create event");
    });
  }

  void _initCallKit() {
    CallKitManager.instance.init(
      onCallAccepted: (uuid) {
        acceptCall(uuid, true);
      },
      onCallEnded: (uuid) {
        reject(uuid, true);
      },
      onMuteCall: (mute, uuid) {
        onMicMuted?.call(mute, uuid);
      },
    );
  }

  void _initChatConnectionStateListener() {
    CubeChatConnection.instance.connectionStateStream.listen((state) {
      if (CubeChatConnectionState.Ready == state) {
        _initCalls();
      }
    });
  }

  Future<String> _getCallState(String sessionId) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      var callState =
          ConnectycubeFlutterCallKit.getCallState(sessionId: sessionId);
      return callState;
    }

    return Future.value(CallState.UNKNOWN);
  }

  void muteCall(String sessionId, bool mute) {
    CallKitManager.instance.muteCall(sessionId, mute);
  }
}
