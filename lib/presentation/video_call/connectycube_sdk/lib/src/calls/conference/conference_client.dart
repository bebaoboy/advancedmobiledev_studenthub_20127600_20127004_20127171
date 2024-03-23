import 'dart:async';

import '../../../connectycube_sdk.dart';
import 'ws_exeptions.dart';

class ConferenceClient {
  static final ConferenceClient _instance =
      ConferenceClient._privateConstructor();

  ConferenceClient._privateConstructor();

  static ConferenceClient get instance => _instance;

  int currentUserId = -1;

  /// Creates the instance of [ConferenceSession].
  /// [userId] - the id of current user
  /// [callType] - can be [CallType.VIDEO_CALL] (by default) or [CallType.AUDIO_CALL].
  /// [startScreenSharing] - set `true` if want to initialize the call with Screen sharing feature.
  /// [desktopCapturerSource] - the desktop capturer source, if it is `null` the
  ///  default Window/Screen will be captured. Use only for desktop platforms.
  ///  Use [ScreenSelectDialog] to give the user a choice of the shared Window/Screen.
  /// [useIOSBroadcasting] - set `true` if the `Broadcast Upload Extension` was
  /// added to your iOS project for implementation Screen Sharing feature, otherwise
  /// set `false` and `in-app` Screen Sharing will be started. Used for iOS platform only.
  /// See our [step-by-step guide](https://developers.connectycube.com/flutter/videocalling?id=ios-screen-sharing-using-the-screen-broadcasting-feature)
  /// on how to integrate the Screen Broadcasting feature into your iOS app.
  Future<ConferenceSession> createCallSession(
    int userId, {
    int callType = CallType.VIDEO_CALL,
    bool startScreenSharing = false,
    DesktopCapturerSource? desktopCapturerSource,
    bool useIOSBroadcasting = false,
  }) async {
    log("createSession userId= $userId");
    currentUserId = userId;
    var signaler = new JanusSignaler(
        ConferenceConfig.instance.url,
        ConferenceConfig.instance.protocol,
        ConferenceConfig.instance.socketTimeOutMs,
        ConferenceConfig.instance.keepAliveValueSec);
    Completer<ConferenceSession> completer = Completer<ConferenceSession>();
    try {
      await signaler.startSession();
      signaler.startAutoSendPresence();
      ConferenceSession session = ConferenceSession(
        this,
        signaler,
        callType,
        startScreenSharing: startScreenSharing,
        desktopCapturerSource: desktopCapturerSource,
        useIOSBroadcasting: useIOSBroadcasting,
      );
      completer.complete(session);
    } on WsException catch (ex) {
      completer.completeError(ex);
    }
    return completer.future;
  }
}
