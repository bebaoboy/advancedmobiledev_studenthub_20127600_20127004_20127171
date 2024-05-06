// ignore_for_file: prefer_typing_uninitialized_variables, deprecated_member_use

import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';

import 'managers/call_manager.dart';

class IncomingCallScreen extends StatefulWidget {
  static const String TAG = "BEBAOBOY";
  final P2PSession _callSession;
  final String callerName;

  const IncomingCallScreen(this._callSession, this.callerName, {super.key});

  @override
  State<IncomingCallScreen> createState() => IncomingCallScreenState();
}

class IncomingCallScreenState extends State<IncomingCallScreen> {
  @override
  Widget build(BuildContext context) {
    widget._callSession.onSessionClosed = (callSession) {
      log("_onSessionClosed", IncomingCallScreen.TAG);
    };

    log("incoming call screen");

    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            body: Container(
              color: Colors.redAccent.shade100,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(36),
                      child: Text(_getCallTitle(),
                          style: const TextStyle(fontSize: 28)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 36, bottom: 8),
                      child: Text(Lang.get('from'),
                          style: const TextStyle(fontSize: 20)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 86),
                      child: Text(widget.callerName,
                          style: const TextStyle(fontSize: 18)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: FloatingActionButton(
                            heroTag: "RejectCall",
                            backgroundColor: Colors.red,
                            onPressed: () =>
                                _rejectCall(context, widget._callSession),
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: FloatingActionButton(
                            heroTag: "AcceptCall",
                            backgroundColor: Colors.green,
                            onPressed: () =>
                                _acceptCall(context, widget._callSession),
                            child: const Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }

  _getCallTitle() {
    var callType;

    switch (widget._callSession.callType) {
      case CallType.VIDEO_CALL:
        callType = "Video";
        break;
      case CallType.AUDIO_CALL:
        callType = "Audio";
        break;
    }

    return "You have an interview call $callType call <3";
  }

  void _acceptCall(BuildContext context, P2PSession callSession) {
    if (mounted) Navigator.pop(context);
    CallManager.instance.acceptCall(callSession.sessionId, false);
  }

  void _rejectCall(BuildContext context, P2PSession callSession) {
    CallManager.instance.reject(callSession.sessionId, false);
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _onBackPressed(BuildContext context) {
    return Future.value(false);
  }
}
