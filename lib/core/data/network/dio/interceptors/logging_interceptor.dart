// ignore_for_file: deprecated_member_use

library dio_logging_interceptor;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_string_pretty/to_string_pretty.dart';

/// Log Level
enum Level {
  /// No logs.
  none,

  /// Logs request and response lines.
  ///
  /// Example:
  ///  ```
  ///  --> POST /greeting
  ///
  ///  <-- 200 OK
  ///  ```
  basic,

  /// Logs request and response lines and their respective headers.
  ///
  ///  Example:
  /// ```
  /// --> POST /greeting
  /// Host: example.com
  /// Content-Type: plain/text
  /// Content-Length: 3
  /// --> END POST
  ///
  /// <-- 200 OK
  /// Content-Type: plain/text
  /// Content-Length: 6
  /// <-- END HTTP
  /// ```
  headers,

  /// Logs request and response lines and their respective headers and bodies (if present).
  ///
  /// Example:
  /// ```
  /// --> POST /greeting
  /// Host: example.com
  /// Content-Type: plain/text
  /// Content-Length: 3
  ///
  /// Hi?
  /// --> END POST
  ///
  /// <-- 200 OK
  /// Content-Type: plain/text
  /// Content-Length: 6
  ///
  /// Hello!
  /// <-- END HTTP
  /// ```
  body,
}

/// DioLoggingInterceptor
/// Simple logging interceptor for dio.
///
/// Inspired the okhttp-logging-interceptor and referred to pretty_dio_logger.
class LoggingInterceptor extends Interceptor {
  /// Log Level
  final Level level;

  /// Log printer; defaults logPrint! log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  void Function(String)? logPrint;

  /// Print compact json response
  final bool compact;

  final JsonDecoder decoder = const JsonDecoder();
  final JsonEncoder encoder = const JsonEncoder.withIndent('  ');

  LoggingInterceptor({
    this.level = Level.body,
    this.compact = false,
  }) {
    initSp();
    logPrint = (o) {
      debugPrint(o);
    };
  }

  initSp() async {
    sharedPref = await SharedPreferences.getInstance();
    sharedPref!.setStringList("dio", []);
  }

  SharedPreferences? sharedPref;
  sp(String o) async {
    List<String> s = sharedPref!.getStringList("dio") ?? [];
    sharedPref!.setStringList("dio", ["${DateTime.now()}\n$o", ...s]);
  }

  spPrint(String s) {
    sp(toStringPretty(s));
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (level == Level.none) {
      return handler.next(options);
    }
    String s = "";

    logPrint!('--> ${options.method} ${options.uri}');
    s += '--> ${options.method} ${options.uri}';

    if (level == Level.basic) {
      return handler.next(options);
    }

    logPrint!('[DIO][HEADERS]');
    s += '[DIO][HEADERS]';
    options.headers.forEach((key, value) {
      logPrint!('$key:$value');
      s += '$key:$value';
    });

    if (level == Level.headers) {
      logPrint!('[DIO][HEADERS]--> END ${options.method}');
      s += '[DIO][HEADERS]--> END ${options.method}';
      return handler.next(options);
    }
    s += "\n";

    final data = options.data;
    if (data != null) {
      // logPrint!('[DIO]dataType:${data.runtimeType}'); s += '[DIO]dataType:${data.runtimeType}';
      if (data is Map) {
        if (compact) {
          logPrint!('$data');
        } else {
          _prettyPrintJson(data);
        }
        s += '<-- Response payload' '\n${toStringPretty(data)}';
      } else if (data is FormData) {
        // NOT IMPLEMENT
      } else {
        logPrint!(data.toString());
        s += data.toString();
      }
    }

    s += "\n";

    logPrint!('[DIO]--> END ${options.method}');
    s += '[DIO]--> END ${options.method}';
    Future.delayed(Duration.zero, () {
      spPrint(s);
    });
    return handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (level == Level.none) {
      return handler.next(response);
    }
    String s = "";

    logPrint!(
        '<-- ${response.statusCode} ${(response.statusMessage?.isNotEmpty ?? false) ? response.statusMessage : '' '${response.requestOptions.uri}'}');

    if (level == Level.basic) {
      return handler.next(response);
    }

    logPrint!('[DIO][HEADER]');
    s += '[DIO][HEADER]';
    response.headers.forEach((key, value) {
      logPrint!('$key:$value');
      s += '$key:$value';
    });
    logPrint!('[DIO][HEADERS]<-- END ${response.requestOptions.method}');
    s += '[DIO][HEADERS]<-- END ${response.requestOptions.method}';
    if (level == Level.headers) {
      return handler.next(response);
    }
    s += "\n";

    final data = response.data;
    if (data != null) {
      // logPrint!('[DIO]dataType:${data.runtimeType}'); s += '[DIO]dataType:${data.runtimeType}';
      if (data is Map) {
        if (compact) {
          logPrint!('$data');
        } else {
          _prettyPrintJson(data);
        }
        s += '<-- Response payload' '\n${toStringPretty(data)}';
      } else if (data is List) {
        // NOT IMPLEMENT
      } else {
        logPrint!(data.toString());
        s += data.toString();
      }
    }

    s += "\n";

    logPrint!('[DIO]<-- END HTTP');
    s += '[DIO]<-- END HTTP';
    Future.delayed(Duration.zero, () {
      spPrint(s);
    });

    return handler.next(response);
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) {
    String s = "";

    logPrint!('[DIO]<-- HTTP FAILED: $err');
    s += '[DIO]<-- HTTP FAILED: ';
    Future.delayed(Duration.zero, () {
      spPrint("$s\n${toStringPretty(err)}");
    });

    if (level == Level.none) {
      return handler.next(err);
    }

    return handler.next(err);
  }

  void _prettyPrintJson(Object input) {
    String prettyString = encoder.convert(input);
    logPrint!('<-- Response payload');
    if (prettyString.length > 1000) {
      logPrint!(input.toString());
      return;
    }
    // prettyString = prettyString.substring(0, min(prettyString.length, 500));
    prettyString.split('\n').forEach((element) {
      logPrint!(element);
    });
  }
}
