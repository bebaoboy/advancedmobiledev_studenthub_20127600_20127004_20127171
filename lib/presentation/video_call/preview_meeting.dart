// ignore_for_file: no_logic_in_create_state, deprecated_member_use

import 'dart:io';

import 'package:boilerplate/core/widgets/toastify.dart';
import 'package:boilerplate/core/widgets/under_text_field_widget.dart';
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
import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:toastification/toastification.dart';
import 'package:web_browser_detect/web_browser_detect.dart';
// import 'package:sembast/sembast.dart';

import 'managers/call_manager.dart';

class PreviewMeetingScreen extends StatefulWidget {
  final CubeUser currentUser;
  final List<CubeUser> users;
  final InterviewSchedule interviewSchedule;
  final P2PSession _callSession;

  @override
  State<PreviewMeetingScreen> createState() =>
      _PreviewMeetingScreenState(_callSession);

  const PreviewMeetingScreen(this.currentUser, this._callSession,
      {super.key, required this.users, required this.interviewSchedule});
}

class _PreviewMeetingScreenState extends State<PreviewMeetingScreen>
    with WidgetsBindingObserver {
  final P2PSession _callSession;
  final codeController = TextEditingController();
  // ignore: unused_field
  static const String TAG = "PREVIEW_SCREEN";

  final floating = Floating();
  final userStore = getIt<UserStore>();
  final chatStore = getIt<ChatStore>();

  _PreviewMeetingScreenState(this._callSession);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      checkSystemAlertWindowPermission(context);
    } catch (e) {
      print("error");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    codeController.dispose();
    try {
      stopBackgroundExecution();
    } catch (e) {
      ///
    }
    super.dispose();
  }

  Widget _buildInterviewInfo() {
    return Column(
      children: [
        Text('Meeting: ${widget.interviewSchedule.title}'),
        Text('Meeting id: ${widget.interviewSchedule.meetingRoomId}'),
        userStore.getCurrentType() == UserType.company
            ? Text('Meeting code: ${widget.interviewSchedule.meetingRoomCode}')
            : SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BorderTextField(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Logged in as ${CubeChatConnection.instance.currentUser!.fullName}',
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(children: [
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: _buildInterviewInfo()),
              Expanded(
                  child: BodyLayout(widget.currentUser, _callSession,
                      users: widget.users,
                      interviewInfo: widget.interviewSchedule)),
            ]);
          } else {
            return Row(
              children: [
                Expanded(
                    child: BodyLayout(widget.currentUser, _callSession,
                        users: widget.users,
                        interviewInfo: widget.interviewSchedule)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildInterviewInfo()),
              ],
            );
          }
        },
      ),
    );
  }
}

class BodyLayout extends StatefulWidget {
  final CubeUser currentUser;
  final List<CubeUser> users;
  final InterviewSchedule interviewInfo;
  final P2PSession _callSession;

  @override
  State<StatefulWidget> createState() => _BodyLayoutState(_callSession);

  const BodyLayout(this.currentUser, this._callSession,
      {super.key, required this.users, required this.interviewInfo});
}

class _BodyLayoutState extends State<BodyLayout> {
  late Set<int> _selectedUsers;

  // ignore: prefer_final_fields
  bool _isCameraEnabled = true;
  bool _isSpeakerEnabled = Platform.isIOS ? false : true;
  bool _isMicMute = false;
  bool _isFrontCameraUsed = true;
  late int _currentUserId;

  final P2PSession _callSession;

  // ToDo: check why this is null
  MapEntry<int, RTCVideoRenderer>? primaryRenderer;
  Map<int, RTCVideoRenderer> minorRenderers = {};
  RTCVideoViewObjectFit primaryVideoFit =
      RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
  final CubeStatsReportsManager _statsReportsManager =
      CubeStatsReportsManager();

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

    // _callSession.onLocalStreamReceived = _addLocalMediaStream;
    _callSession.onRemoteStreamReceived = _addRemoteMediaStream;
    _callSession.onSessionClosed = _onSessionClosed;
    _statsReportsManager.init(_callSession);
    print("init");
  }

  @override
  void dispose() {
    try {
      CallManager.instance.hungUp();

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
                padding: const EdgeInsets.only(right: 4),
                child: FloatingActionButton(
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
              SpeedDial(
                heroTag: "Options",
                icon: Icons.more_vert,
                activeIcon: Icons.close,
                backgroundColor: Colors.black38,
                switchLabelPosition: true,
                overlayColor: Colors.black,
                elevation: 0,
                overlayOpacity: 0.5,
                children: [
                  SpeedDialChild(
                    elevation: 0,
                    visible: !(kIsWeb &&
                        (Browser().browserAgent == BrowserAgent.Safari ||
                            Browser().browserAgent == BrowserAgent.Firefox)),
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
              ),
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
    var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _callSession.localStream = stream;
    _addMediaStream(_currentUserId, stream);
    return Future.value(true);
  }

  void _addRemoteMediaStream(session, int userId, MediaStream stream) {
    // log("_addRemoteMediaStream for user $userId", TAG);

    _addMediaStream(userId, stream);
  }

  void _onSessionClosed(session) {
    // log("_onSessionClosed", TAG);

    _statsReportsManager.dispose();

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LoginScreen(),
    //   ),
    // );
  }

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
                            child: FloatingActionButton(
                              heroTag: "VideoCall",
                              backgroundColor: Colors.blue,
                              onPressed: () async {
                                // TODO: truyền userid ng cần gọi vào
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
                                    if (chatStore.canCall &&
                                        await chatStore
                                            .checkMeetingAvailability(
                                                widget.interviewInfo, "")) {
                                      // _selectedUsers.add(_currentUserId);
                                      _selectedUsers.add(cubeUser.id!);
                                      Navigator.pop(context);
                                      CallManager.instance.startNewCall(
                                          NavigationService
                                              .navigatorKey.currentContext!,
                                          CallType.VIDEO_CALL,
                                          _selectedUsers);
                                    } else {
                                      Toastify.show(
                                          context,
                                          '',
                                          chatStore.errorStore.errorMessage,
                                          ToastificationType.error,
                                          () {});
                                    }
                                  } else {
                                    // _selectedUsers.add(_currentUserId);
                                    _selectedUsers.add(cubeUser.id!);
                                    Navigator.pop(context);
                                    CallManager.instance.startNewCall(
                                        NavigationService
                                            .navigatorKey.currentContext!,
                                        CallType.VIDEO_CALL,
                                        _selectedUsers);
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
                Visibility(
                    visible: chatStore.isChecking,
                    child: const Center(
                      child: LoadingScreenWidget(
                        size: 80,
                      ),
                    )),
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
            future: _callSession.getAudioOutputs(),
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
              _callSession.selectAudioOutput(deviceId);
            }
          });
        }
      });
    } else {
      setState(() {
        _isSpeakerEnabled = !_isSpeakerEnabled;
        _callSession.enableSpeakerphone(_isSpeakerEnabled);
      });
    }
  }

  bool _isVideoCall() {
    return CallType.VIDEO_CALL == _callSession.callType;
  }

  bool _isVideoEnabled() {
    return _isVideoCall() && _isCameraEnabled;
  }

  _switchCamera() {
    if (!_isVideoEnabled()) return;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _callSession.switchCamera().then((isFrontCameraUsed) {
        setState(() {
          _isFrontCameraUsed = isFrontCameraUsed;
        });
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<MediaDeviceInfo>>(
            future: _callSession.getCameras(),
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
        if (deviceId != null) _callSession.switchCamera(deviceId: deviceId);
      });
    }
  }

  _muteMic() {
    setState(() {
      _isMicMute = !_isMicMute;
      _callSession.setMicrophoneMute(_isMicMute);
      CallManager.instance.muteCall(_callSession.sessionId, _isMicMute);
    });
  }

  _switchAudioInput() {
    if (kIsWeb || WebRTC.platformIsDesktop) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<MediaDeviceInfo>>(
            future: _callSession.getAudioInputs(),
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
            _callSession.selectAudioInput(deviceId);
          });
        }
      });
    }
  }
}
