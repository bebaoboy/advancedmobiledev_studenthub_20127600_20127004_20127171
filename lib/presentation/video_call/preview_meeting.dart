// ignore_for_file: no_logic_in_create_state

import 'dart:io';

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/video_call/utils/platform_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

  // ignore: unused_field
  static const String TAG = "PREVIEW_SCREEN";

  final floating = Floating();

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
    try {
      stopBackgroundExecution();
    } catch (e) {}
    super.dispose();
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
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Column(
                  children: [
                    Text('Meeting: ${widget.interviewSchedule.title}'),
                    Text(
                        'Meeting id: ${widget.interviewSchedule.meetingRoomId}'),
                    Text(
                        'Meeting code: ${widget.interviewSchedule.meetingRoomCode}'),
                  ],
                ),
              ),
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
                  child: Column(
                    children: [
                      Text('Meeting: ${widget.interviewSchedule.title}'),
                      Text(
                          'Meeting id: ${widget.interviewSchedule.meetingRoomId}'),
                      Text(
                          'Meeting code: ${widget.interviewSchedule.meetingRoomCode}'),
                    ],
                  ),
                ),
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

  _BodyLayoutState(this._callSession);

  @override
  void initState() {
    super.initState();
    _selectedUsers = {};
    _currentUserId = widget.currentUser.id!;

    _callSession.onLocalStreamReceived = _addLocalMediaStream;
    _callSession.onRemoteStreamReceived = _addRemoteMediaStream;
    _callSession.onSessionClosed = _onSessionClosed;
    _statsReportsManager.init(_callSession);
    print("init");
  }

  @override
  void dispose() {
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
    } catch (e) {}

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

  Future<void> _addLocalMediaStream(MediaStream stream) async {
    // log("_addLocalMediaStream, stream Id: ${stream.id}", TAG);

    _addMediaStream(_currentUserId, stream);
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
    return Container(
        padding:
            const EdgeInsets.only(top: 48, left: 48, right: 48, bottom: 12),
        child: Column(
          children: [
            Stack(
              children: [
                RTCVideoView(primaryRenderer!.value,
                    objectFit: primaryVideoFit, mirror: _isFrontCameraUsed),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _getActionsPanel(),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton(
                    heroTag: "VideoCall",
                    backgroundColor: Colors.blue,
                    onPressed: () => CallManager.instance.startNewCall(
                        context, CallType.VIDEO_CALL, _selectedUsers),
                    child: const Icon(
                      Icons.videocam,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
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
