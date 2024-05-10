// ignore_for_file: deprecated_member_use, unreachable_switch_case

import 'package:dio/dio.dart';

class DioErrorUtil {
  // general methods:-----------------------------------------------------------
  static String handleError(DioError error) {
    String errorDescription = "";
    switch (error.type) {
      case DioErrorType.cancel:
        errorDescription = "Request to API server was cancelled";
        break;
      case DioErrorType.connectionError:
      case DioErrorType.connectionTimeout:
      case DioErrorType.unknown:
        errorDescription = "Connection timeout with API server";
        break;
      case DioErrorType.receiveTimeout:
        errorDescription = "Receive timeout in connection with API server";
        break;
      case DioErrorType.receiveTimeout:
        errorDescription = "Receive timeout in connection with API server";
        break;
      case DioErrorType.badResponse:
        errorDescription =
        "Received invalid status code: ${error.response?.statusCode}";
        break;
      case DioErrorType.sendTimeout:
        errorDescription = "Send timeout in connection with API server";
        break;
      case DioErrorType.badCertificate:
        errorDescription = "Incorrect certificate";
        break;
    }
      return errorDescription;
  }
}