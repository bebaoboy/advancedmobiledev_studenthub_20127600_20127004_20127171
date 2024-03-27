import 'package:flutter/foundation.dart';

import '../models/cube_settings.dart';
import 'string_utils.dart';

log(String? message, [String? tag]) {
  if (CubeSettings.instance.isDebugEnabled) {
    debugPrint("CB-SDK: ${!isEmpty(tag) ? tag : ""}: $message");
  }
}

logTime(String message, [String? tag]) {
  if (CubeSettings.instance.isDebugEnabled) {
    debugPrint(
        "${DateTime.now().toIso8601String()}: CB-SDK: ${!isEmpty(tag) ? tag : ""}: $message");
  }
}
