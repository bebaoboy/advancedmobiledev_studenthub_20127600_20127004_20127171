// ignore_for_file: no_logic_in_create_state, deprecated_member_use

import 'dart:io';

import 'package:boilerplate/core/widgets/main_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/core/widgets/under_text_field_widget.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/dashboard/chat/chat_store.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/presentation/video_call/utils/configs.dart';
import 'package:boilerplate/presentation/video_call/utils/platform_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/core/widgets/floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:web_browser_detect/web_browser_detect.dart';
// import 'package:sembast/sembast.dart';

import 'managers/call_manager.dart';

class PreviewMeetingScreen extends StatefulWidget {
  final CubeUser currentUser;
  final List<CubeUser> users;
  final InterviewSchedule? interviewSchedule;
  final P2PSession _callSession;

  @override
  State<PreviewMeetingScreen> createState() => _PreviewMeetingScreenState();

  const PreviewMeetingScreen(this.currentUser, this._callSession,
      {super.key, required this.users, required this.interviewSchedule});
}

class _PreviewMeetingScreenState extends State<PreviewMeetingScreen>
    with WidgetsBindingObserver {
  // final P2PSession CallManager.instance.currentCall!;
  final codeController = TextEditingController();
  // ignore: unused_field
  static const String TAG = "PREVIEW_SCREEN";

  final floating = Floating();
  final userStore = getIt<UserStore>();
  final chatStore = getIt<ChatStore>();

  _PreviewMeetingScreenState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      checkSystemAlertWindowPermission(context);
    } catch (e) {
      print("error");
    }
    chatStore.meetingCode = "";
    if (widget.interviewSchedule == null) {
      future = Future.value(getIt<SharedPreferenceHelper>().interview).then(
        (value) async {
          CallManager.instance.currentInterview = value;
          if (value != null &&
              CallManager.instance.savedMeetingInfo[value.meetingRoomId] !=
                  null) {
            await getUsers(
                    {"login": "user_${widget._callSession.opponentsIds.first}"})
                .then((cubeUsers) async {
              CubeUser cubeUser;
              if (cubeUsers != null && cubeUsers.items.isNotEmpty) {
                cubeUser = cubeUsers.items.first;
              } else {
                cubeUser = await signUp(CubeUser(
                    login: "user_${widget._callSession.opponentsIds.first}",
                    password: DEFAULT_PASS));
              }
              // ignore: avoid_func
              Set<int> selectedUsers = {};
              selectedUsers.add(cubeUser.id!);
              CallManager.instance.currentCall!.localStream = null;
              CallManager.instance.currentCall!.opponentsIds
                ..clear()
                ..addAll(selectedUsers);
              startCall = true;
              CallManager.instance.startNewCall(
                  fromCallkit: false,
                  NavigationService.navigatorKey.currentContext!,
                  CallType.VIDEO_CALL,
                  selectedUsers,
                  CallManager.instance.currentCall!,
                  value);
            });
            // codeController.text =
            //     CallManager.instance.savedMeetingInfo[value.meetingRoomId]!;
            // chatStore.setCode(codeController.text);
            return value;
          }
          return value;
        },
      );
    } else {
      future = Future.value(widget.interviewSchedule);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    codeController.dispose();
    CallManager.instance.waitingCall = false;

    try {
      stopBackgroundExecution();
      // primaryRenderer?.value.srcObject = null;
      // primaryRenderer?.value.dispose();

      // minorRenderers.forEach((opponentId, renderer) {
      //   log("[dispose] dispose renderer for $opponentId", TAG);
      //   try {
      //     renderer.srcObject?.getTracks().forEach((track) => track.stop());
      //     renderer.srcObject?.dispose();
      //     renderer.srcObject = null;
      //     renderer.dispose();
      //   } catch (e) {
      //     log('Error $e');
      //   }
      // });
    } catch (e) {
      ///
    }
    super.dispose();
  }

  late Future<InterviewSchedule?> future;

  Widget _buildInterviewInfo(interviewSchedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Meeting: ${interviewSchedule!.title}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // Text(
        //   'Meeting id: ${widget.interviewSchedule.meetingRoomId}',
        // ),
        userStore.getCurrentType() == UserType.company
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 300,
                  child: BorderTextField(
                    enabled: !startCall && !waitingCall,
                    icon: Icons.code,
                    errorText: '',
                    textController: codeController,
                    hint: "Enter code",
                    inputAction: TextInputAction.done,
                    label: const Text('Code'),
                    onChanged: (_) {
                      chatStore.setCode(codeController.text);
                    },
                  ),
                ),
              ),
      ],
    );
  }

  bool startCall = false;
  bool waitingCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MainAppBar(
          name:
              'Logged in as ${CubeChatConnection.instance.currentUser!.fullName}',
        ),
        body: FutureBuilder<InterviewSchedule?>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingScreenWidget();
              } else {
                var interviewSchedule = snapshot.data!;
                return OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.portrait) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInterviewInfo(interviewSchedule),
                            Expanded(
                                child: (startCall ||
                                        CallManager.instance.hasEnded)
                                    ? const Center(
                                        child: Text("The meeting has started!"),
                                      )
                                    : BodyLayout(
                                        widget.currentUser,
                                        widget._callSession,
                                        users: widget.users,
                                        interviewInfo: interviewSchedule,
                                        waitingCall, startCallCb: (isStudent) {
                                        if (!isStudent) {
                                          setState(() {
                                            startCall = true;
                                          });
                                        } else {
                                          setState(() {
                                            waitingCall = true;
                                          });
                                        }
                                      })),
                          ]);
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                                child: (startCall ||
                                        CallManager.instance.hasEnded)
                                    ? const Center(
                                        child: Text("The meeting has started!"),
                                      )
                                    : BodyLayout(
                                        widget.currentUser,
                                        widget._callSession,
                                        users: widget.users,
                                        interviewInfo: interviewSchedule,
                                        waitingCall, startCallCb: (isStudent) {
                                        if (!isStudent) {
                                          setState(() {
                                            startCall = true;
                                          });
                                        } else {
                                          setState(() {
                                            waitingCall = true;
                                          });
                                        }
                                      })),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: _buildInterviewInfo(interviewSchedule)),
                          ],
                        ),
                      );
                    }
                  },
                );
              }
            }));
  }
}

class BodyLayout extends StatefulWidget {
  final CubeUser currentUser;
  final List<CubeUser> users;
  final InterviewSchedule interviewInfo;
  final P2PSession _callSession;
  final Function startCallCb;
  final bool waitingCall;

  @override
  State<StatefulWidget> createState() => _BodyLayoutState(_callSession);

  const BodyLayout(this.currentUser, this._callSession, this.waitingCall,
      {super.key,
      required this.users,
      required this.interviewInfo,
      required this.startCallCb});
}

class _BodyLayoutState extends State<BodyLayout> {
  late Set<int> _selectedUsers;

  // ignore: prefer_final_fields
  bool _isCameraEnabled = true;
  bool _isSpeakerEnabled = !kIsWeb
      ? Platform.isIOS
          ? false
          : true
      : true;
  bool _isMicMute = false;
  bool _isFrontCameraUsed = true;
  late int _currentUserId;

  // ignore: unused_field
  final P2PSession _callSession;

  // ToDo: check why this is null
  MapEntry<int, RTCVideoRenderer>? primaryRenderer;
  Map<int, RTCVideoRenderer> minorRenderers = {};
  RTCVideoViewObjectFit primaryVideoFit =
      RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
  // final CubeStatsReportsManager _statsReportsManager =
  //     CubeStatsReportsManager();

  late final Future<bool> future;
  final userStore = getIt<UserStore>();
  final chatStore = getIt<ChatStore>();

  _BodyLayoutState(this._callSession);

  @override
  void initState() {
    super.initState();
    _selectedUsers = {};
    _currentUserId = widget.currentUser.id!;
    future = _addLocalMediaStream();

    // CallManager.instance.currentCall!.onLocalStreamReceived = _addLocalMediaStream;
    // CallManager.instance.currentCall!.onRemoteStreamReceived = _addRemoteMediaStream;
    // CallManager.instance.currentCall!.onSessionClosed = _onSessionClosed;
    // _statsReportsManager.init(CallManager.instance.currentCall!);
    print("init");
  }

  @override
  void dispose() {
    try {
      stream?.getTracks().forEach(
            (element) => element.stop(),
          );
      stream?.dispose();
      // CallManager.instance.hungUp();

      primaryRenderer?.value.srcObject = null;
      primaryRenderer?.value.dispose();

      minorRenderers.forEach((opponentId, renderer) {
        // log("[dispose] dispose renderer for $opponentId", TAG);
        try {
          renderer.srcObject?.dispose();
          renderer.srcObject = null;
          renderer.dispose();
        } catch (e) {
          log('Error $e');
        }
      });
    } catch (e) {
      ///
    }

    super.dispose();
  }

  Widget _getActionsPanel() {
    return Container(
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 8,
          left: MediaQuery.of(context).padding.left + 8,
          right: MediaQuery.of(context).padding.right + 8),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32)),
        child: Container(
          padding: const EdgeInsets.all(4),
          color: Colors.black26,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  elevation: 0,
                  heroTag: "Mute",
                  onPressed: () => _muteMic(),
                  backgroundColor: Colors.black38,
                  child: Icon(
                    _isMicMute ? Icons.mic_off : Icons.mic,
                    color: _isMicMute ? Colors.grey : Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  elevation: 0,
                  tooltip: "Enable In-app Pip",
                  heroTag: "Pip",
                  onPressed: () => setState(() {
                    CallManager.inAppPip = !CallManager.inAppPip;
                  }),
                  backgroundColor: Colors.black38,
                  child: Icon(
                    CallManager.inAppPip
                        ? Icons.picture_in_picture_alt
                        : Icons.tv_off,
                    color: _isMicMute ? Colors.grey : Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  elevation: 0,
                  tooltip: "Camera",
                  heroTag: "Camerais",
                  onPressed: () => _toggleCamera(),
                  backgroundColor: Colors.black38,
                  child: Icon(
                    _isVideoEnabled() ? Icons.videocam : Icons.videocam_off,
                    color: _isVideoEnabled() ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                  child: SpeedDial(
                    heroTag: "Options",
                    icon: Icons.more_vert,
                    activeIcon: Icons.close,
                    backgroundColor: Colors.black38,
                    switchLabelPosition: true,
                    overlayColor: Colors.white,
                    elevation: 0,
                    foregroundColor: Colors.white,
                    overlayOpacity: 0.5,
                    children: [
                      SpeedDialChild(
                        elevation: 0,
                        visible: !(kIsWeb &&
                            (Browser().browserAgent == BrowserAgent.Safari ||
                                Browser().browserAgent ==
                                    BrowserAgent.Firefox)),
                        child: Icon(
                          kIsWeb || WebRTC.platformIsDesktop
                              ? Icons.surround_sound
                              : _isSpeakerEnabled
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                          color: _isSpeakerEnabled ? Colors.white : Colors.grey,
                        ),
                        backgroundColor: Colors.black38,
                        foregroundColor: Colors.white,
                        label:
                            'Switch ${kIsWeb || WebRTC.platformIsDesktop ? 'Audio output' : 'Speakerphone'}',
                        onTap: () => _switchSpeaker(),
                      ),
                      SpeedDialChild(
                        elevation: 0,
                        visible: kIsWeb || WebRTC.platformIsDesktop,
                        child: const Icon(
                          Icons.record_voice_over,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.black38,
                        foregroundColor: Colors.white,
                        label: 'Switch Audio Input device',
                        onTap: () => _switchAudioInput(),
                      ),
                      SpeedDialChild(
                        elevation: 0,
                        visible: true,
                        child: Icon(
                          Icons.cameraswitch,
                          color: _isVideoEnabled() ? Colors.white : Colors.grey,
                        ),
                        backgroundColor: Colors.black38,
                        foregroundColor: Colors.white,
                        label: 'Switch Camera',
                        onTap: () => _switchCamera(),
                      ),
                    ],
                  )),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addMediaStream(int userId, MediaStream stream) async {
    if (primaryRenderer == null) {
      primaryRenderer = MapEntry(userId, RTCVideoRenderer());
      await primaryRenderer!.value.initialize();

      setState(() {
        primaryRenderer?.value.srcObject = stream;
      });

      return;
    }

    if (minorRenderers[userId] == null) {
      minorRenderers[userId] = RTCVideoRenderer();
      await minorRenderers[userId]?.initialize();
    }
    try {
      setState(() {
        minorRenderers[userId]?.srcObject = stream;

        if (primaryRenderer?.key == _currentUserId ||
            primaryRenderer?.key == userId) {
          _replacePrimaryRenderer(userId);
        }
      });
    } catch (e) {
      ///
    }
  }

  void _replacePrimaryRenderer(int newPrimaryUser) {
    if (primaryRenderer?.key != newPrimaryUser) {
      minorRenderers.addEntries([primaryRenderer!]);
    }

    primaryRenderer =
        MapEntry(newPrimaryUser, minorRenderers.remove(newPrimaryUser)!);
  }

  Future<bool> _addLocalMediaStream() async {
    // log("_addLocalMediaStream, stream Id: ${stream.id}", TAG);
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '300', // Provide your own width, height and frame rate here
          //     'maxWidth': '1080',
          // 'maxHeight': '600',
          'minHeight': '400',
          'minFrameRate': '24',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
// You can request multiple permissions at once.
    await Permission.camera.request().isGranted;
    await Permission.microphone.request().isGranted;

    stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    CallManager.instance.currentCall!.localStream = stream;
    _addMediaStream(_currentUserId, stream!);
    return Future.value(true);
  }

  MediaStream? stream;
  // void _addRemoteMediaStream(session, int userId, MediaStream stream) {
  //   // log("_addRemoteMediaStream for user $userId", TAG);

  //   _addMediaStream(userId, stream);
  // }

  // void _onSessionClosed(session) {
  //   // log("_onSessionClosed", TAG);

  //   _statsReportsManager.dispose();

  //   // Navigator.pushReplacement(
  //   //   context,
  //   //   MaterialPageRoute(
  //   //     builder: (context) => LoginScreen(),
  //   //   ),
  //   // );
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        try {
          primaryRenderer?.value.srcObject = null;
          primaryRenderer?.value.dispose();

          minorRenderers.forEach((opponentId, renderer) {
            // log("[dispose] dispose renderer for $opponentId", TAG);
            try {
              renderer.srcObject?.dispose();
              renderer.srcObject = null;
              renderer.dispose();
            } catch (e) {
              log('Error $e');
            }
          });
        } catch (e) {
          ///
        }
        return Future.value(true);
      },
      child: FutureBuilder<bool>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Stack(children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 0, left: 48, right: 48, bottom: 12),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 400,
                        height: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? MediaQuery.of(context).size.height * 0.6
                            : MediaQuery.of(context).size.height * 0.53,
                        child: Stack(
                          children: [
                            RTCVideoView(primaryRenderer!.value,
                                objectFit: primaryVideoFit,
                                mirror: _isFrontCameraUsed),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: _getActionsPanel(),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: widget.waitingCall
                                ? const Center(
                                    child: Text("Waiting for company..."),
                                  )
                                : FloatingActionButton(
                                    heroTag: "VideoCall",
                                    backgroundColor: Colors.blue,
                                    onPressed: () async {
                                      await getUsers({
                                        "login":
                                            "user_${widget._callSession.opponentsIds.first}"
                                      }).then((cubeUsers) async {
                                        CubeUser cubeUser;
                                        if (cubeUsers != null &&
                                            cubeUsers.items.isNotEmpty) {
                                          cubeUser = cubeUsers.items.first;
                                        } else {
                                          cubeUser = await signUp(CubeUser(
                                              login:
                                                  "user_${widget._callSession.opponentsIds.first}",
                                              password: DEFAULT_PASS));
                                        }
                                        // ignore: avoid_func
                                        if (userStore.getCurrentType() ==
                                            UserType.student) {
                                          if (await chatStore
                                              .checkMeetingAvailability(
                                                  widget.interviewInfo, "")) {
                                            // _selectedUsers.add(_currentUserId);
                                            CallManager
                                                    .instance.savedMeetingInfo[
                                                widget.interviewInfo
                                                    .meetingRoomId] = widget
                                                .interviewInfo.meetingRoomCode;
                                            _selectedUsers.add(cubeUser.id!);
                                            CallManager.instance.currentCall!
                                                .localStream = null;
                                            CallManager.instance.currentCall!
                                                .opponentsIds
                                              ..clear()
                                              ..addAll(_selectedUsers);
                                            // Navigator.pop(context);
                                            Toastify.show(
                                                context,
                                                '',
                                                "Saved meeting info",
                                                ToastificationType.success,
                                                () {});
                                            widget.startCallCb(true);
                                            // CallManager.instance.waitingCall =
                                            //     true;
                                            if (!CallManager
                                                .instance.waitingCall) {
                                              CallManager.instance.startNewCall(
                                                  fromCallkit: false,
                                                  NavigationService.navigatorKey
                                                      .currentContext!,
                                                  CallType.VIDEO_CALL,
                                                  _selectedUsers,
                                                  CallManager
                                                      .instance.currentCall!,
                                                  widget.interviewInfo);
                                            }
                                          } else {
                                            Toastify.show(
                                                context,
                                                '',
                                                chatStore
                                                    .errorStore.errorMessage,
                                                ToastificationType.error,
                                                () {});
                                          }
                                        } else {
                                          _selectedUsers.add(cubeUser.id!);
                                          CallManager.instance.currentCall!
                                              .localStream = null;
                                          CallManager.instance.currentCall!
                                              .opponentsIds
                                            ..clear()
                                            ..addAll(_selectedUsers);
                                          widget.startCallCb(false);
                                          CallManager.instance.startNewCall(
                                              fromCallkit: false,
                                              NavigationService
                                                  .navigatorKey.currentContext!,
                                              CallType.VIDEO_CALL,
                                              _selectedUsers,
                                              CallManager.instance.currentCall!,
                                              widget.interviewInfo);
                                        }
                                      });
                                    },
                                    child: const Icon(
                                      Icons.videocam,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Observer(builder: (context) {
                  return Visibility(
                      visible: chatStore.isChecking,
                      child: const Center(
                        child: LoadingScreenWidget(
                          size: 80,
                        ),
                      ));
                }),
              ]);
            } else {
              return const LoadingScreenWidget();
            }
          }),
    );
  }

  _switchSpeaker() {
    if (kIsWeb || WebRTC.platformIsDesktop) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<MediaDeviceInfo>>(
            future: CallManager.instance.currentCall!.getAudioOutputs(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return AlertDialog(
                  content: Text(Lang.get('no_sound')),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: Text(Lang.get('ok')),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              } else {
                return SimpleDialog(
                  title: Text(Lang.get('select_sound')),
                  children: snapshot.data?.map(
                    (mediaDeviceInfo) {
                      return SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, mediaDeviceInfo.deviceId);
                        },
                        child: Text(mediaDeviceInfo.label),
                      );
                    },
                  ).toList(),
                );
              }
            },
          );
        },
      ).then((deviceId) {
        // log("onAudioOutputSelected deviceId: $deviceId", TAG);
        if (deviceId != null) {
          setState(() {
            if (kIsWeb) {
              primaryRenderer?.value.audioOutput(deviceId);
              minorRenderers.forEach((userId, renderer) {
                renderer.audioOutput(deviceId);
              });
            } else {
              CallManager.instance.currentCall!.selectAudioOutput(deviceId);
            }
          });
        }
      });
    } else {
      setState(() {
        _isSpeakerEnabled = !_isSpeakerEnabled;
        CallManager.instance.currentCall!.enableSpeakerphone(_isSpeakerEnabled);
      });
    }
  }

  bool _isVideoCall() {
    return true;
  }

  bool _isVideoEnabled() {
    return _isVideoCall() && _isCameraEnabled;
  }

  _toggleCamera() {
    if (!_isVideoCall()) return;

    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
      CallManager.instance.isCameraEnabled =
          !CallManager.instance.isCameraEnabled;
      CallManager.instance.currentCall!.setVideoEnabled(_isCameraEnabled);
    });
  }

  _switchCamera() {
    if (!_isVideoEnabled()) return;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      CallManager.instance.currentCall!
          .switchCamera()
          .then((isFrontCameraUsed) {
        setState(() {
          _isFrontCameraUsed = isFrontCameraUsed;
          CallManager.instance.isFrontCameraUsed = _isFrontCameraUsed;
        });
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<MediaDeviceInfo>>(
            future: CallManager.instance.currentCall!.getCameras(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return AlertDialog(
                  content: Text(Lang.get('no_camera')),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: Text(Lang.get('ok')),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              } else {
                return SimpleDialog(
                  title: Text(Lang.get('select_camera')),
                  children: snapshot.data?.map(
                    (mediaDeviceInfo) {
                      return SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, mediaDeviceInfo.deviceId);
                        },
                        child: Text(mediaDeviceInfo.label),
                      );
                    },
                  ).toList(),
                );
              }
            },
          );
        },
      ).then((deviceId) {
        // log("onCameraSelected deviceId: $deviceId", TAG);
        if (deviceId != null) {
          CallManager.instance.cameraId = deviceId;
          CallManager.instance.currentCall!.switchCamera(deviceId: deviceId);
        }
      });
    }
  }

  _muteMic() {
    setState(() {
      _isMicMute = !_isMicMute;
      CallManager.instance.isMicMute = _isMicMute;
      CallManager.instance.currentCall!.setMicrophoneMute(_isMicMute);
      CallManager.instance
          .muteCall(CallManager.instance.currentCall!.sessionId, _isMicMute);
    });
  }

  _switchAudioInput() {
    if (kIsWeb || WebRTC.platformIsDesktop) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<MediaDeviceInfo>>(
            future: CallManager.instance.currentCall!.getAudioInputs(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return AlertDialog(
                  content: Text(Lang.get('no_mic')),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: Text(Lang.get('ok')),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              } else {
                return SimpleDialog(
                  title: Text(Lang.get('select_mic')),
                  children: snapshot.data?.map(
                    (mediaDeviceInfo) {
                      return SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, mediaDeviceInfo.deviceId);
                        },
                        child: Text(mediaDeviceInfo.label),
                      );
                    },
                  ).toList(),
                );
              }
            },
          );
        },
      ).then((deviceId) {
        // log("onAudioOutputSelected deviceId: $deviceId", TAG);
        if (deviceId != null) {
          setState(() {
            CallManager.instance.currentCall!.selectAudioInput(deviceId);
          });
        }
      });
    }
  }
}
