import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:uuid/uuid.dart';

import '../auth/models/cube_session.dart';
import '../utils/consts.dart';
import '../utils/string_utils.dart';

class CubeSettings {
  final String _versionName = "2.11.2";
  String? applicationId;
  String? authorizationKey;
  String? accountKey;

  String? authorizationSecret;

  String chatDefaultResource = "";

  bool isDebugEnabled = true;
  bool isJoinEnabled = false;
  bool autoMarkDelivered = true;

  String apiEndpoint = "https://api.connectycube.com";
  String chatEndpoint = "chat.connectycube.com";
  String whiteboardUrl = "https://whiteboard.connectycube.com";

  static final CubeSettings _instance = CubeSettings._internal();

  Future<CubeSession> Function()? onSessionRestore;

  CubeSettings._internal();

  static CubeSettings get instance => _instance;

  String get versionName => _versionName;

  init(
      String applicationId, String authorizationKey, String authorizationSecret,
      {Future<CubeSession> Function()? onSessionRestore}) async {
    this.applicationId = applicationId;
    this.authorizationKey = authorizationKey;
    this.authorizationSecret = authorizationSecret;
    this.onSessionRestore = onSessionRestore;

    await _initDefaultParams();
  }

  setEndpoints(String apiEndpoint, String chatEndpoint) {
    if (isEmpty(apiEndpoint) || isEmpty(chatEndpoint)) {
      throw ArgumentError(
          "'apiEndpoint' and(or) 'chatEndpoint' can not be empty or null");
    }

    if (!apiEndpoint.startsWith("http")) {
      apiEndpoint = "https://$apiEndpoint";
    }

    this.apiEndpoint = apiEndpoint;
    this.chatEndpoint = chatEndpoint;
  }

  Future<void> _initResourceId() async {
    var deviceInfoPlugin = DeviceInfoPlugin();

    String? resourceId;

    if (kIsWeb) {
      var webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
      resourceId = webBrowserInfo.userAgent;
    } else if (Platform.isAndroid) {
      var androidInfo = await deviceInfoPlugin.androidInfo;
      resourceId = androidInfo.id;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfoPlugin.iosInfo;
      resourceId = iosInfo.identifierForVendor;
    } else if (Platform.isMacOS) {
      var macOsInfo = await deviceInfoPlugin.macOsInfo;
      resourceId = macOsInfo.computerName;
    } else if (Platform.isWindows) {
      var windowsInfo = await deviceInfoPlugin.windowsInfo;
      resourceId = windowsInfo.deviceId;
    } else if (Platform.isLinux) {
      var linuxInfo = await deviceInfoPlugin.linuxInfo;
      resourceId = linuxInfo.machineId ?? linuxInfo.id;
    }

    if (resourceId == null) {
      resourceId = const Uuid().v4();
    } else {
      resourceId = base64Encode(utf8.encode(resourceId));
    }

    chatDefaultResource = "${PREFIX_CHAT_RESOURCE}_$resourceId";
  }

  Future<void> _initDefaultParams() async {
    await _initResourceId();
  }
}
