import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

bool get isMobile {
  return Platform.isAndroid || Platform.isIOS;
}

bool get isWeb {
  return kIsWeb;
}

bool get isDesktop =>
    !isWeb &&
    (Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS);
