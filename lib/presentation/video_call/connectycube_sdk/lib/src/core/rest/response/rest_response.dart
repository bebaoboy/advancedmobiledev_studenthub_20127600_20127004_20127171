import 'dart:async';

import 'package:http/http.dart';

import '../../cube_exceptions.dart';
import '../../utils/cube_logger.dart';
import '../../utils/string_utils.dart';

class RestResponse {
  Future<Response> _futureResponse;
  String _uuid;

  Response? response;

  RestResponse(this._futureResponse, this._uuid);

  Future<RestResponse> getResponse() {
    Completer<RestResponse> completer = new Completer();

    try {
      _futureResponse.then((response) {
        completer = _handleResponse(response, completer);
      }).catchError((error) {
        completer = _handleError(error, completer);
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Map<String, String>? getHeaders() {
    return response != null ? response!.headers : null;
  }

  String getBody() {
    return response != null ? response!.body : EMPTY_STRING;
  }

  int getResponseCode() {
    return response != null ? response!.statusCode : 0;
  }

  @override
  String toString() {
    return "*********************************************************\n" +
        "*** RESPONSE *** ${getResponseCode()} *** $_uuid ***\n"
            "HEADERS\n  ${getHeaders()}\n"
            "BODY\n  ${getBody()}\n";
  }

  Completer<RestResponse> _handleResponse(
      Response response, Completer<RestResponse> completer) {
    this.response = response;

    log(toString());

    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        completer.complete(this);
        break;

      case 400:
      case 401:
      case 403:
      case 404:
      case 422:
      case 429:
      case 500:
      case 503:
        completer.completeError(ResponseException(
            "ResponseException: ${response.statusCode}: ${response.body}"));
        break;

      default:
        completer.completeError(
            ResponseException("ResponseException: ${response.statusCode}"));
    }

    return completer;
  }

  Completer<RestResponse> _handleError(
      Exception error, Completer<RestResponse> completer) {
    completer.completeError(error);
    return completer;
  }
}
