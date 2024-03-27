import 'dart:async';

import 'package:intl/intl.dart';

import '../../../../connectycube_core.dart';

abstract class AutoManagedQuery<T> extends Query<T> {
  @override
  Future<T> perform() {
    return prepareSessionIfNeed().then((result) => super.perform());
  }

  bool isSessionRequired() {
    return true;
  }

  bool isUserRequired() {
    return true;
  }

  Future<CubeSession?> prepareSessionIfNeed() {
    if (CubeSessionManager.instance.isActiveSessionValid()) {
      return Future.value(null);
    }

    if (isSessionRequired()) {
      if (CubeSettings.instance.onSessionRestore != null) {
        return CubeSettings.instance.onSessionRestore!.call();
      }

      if (!isUserRequired()) {
        return createSession();
      }
    }

    return Future.value(null);
  }
}

abstract class Query<T> {
  Future<T> perform() {
    Completer<T> completer = Completer();

    try {
      RestRequest request = RestRequest();

      setupRequest(request);

      // log(request.toString());

      request.perform().then((response) {
        handleResponse(response);
        completer.complete(processResult(response.getBody()));
      }).catchError((error) {
        handelError(error);
        completer.completeError(error);
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  handleResponse(RestResponse response) {
    updateTokenExpirationDate(response);
  }

  handelError(Object error) {}

  void setupRequest(RestRequest request) {
    setParams(request);
    setBody(request);
    setHeaders(request);
    setMethod(request);
    setUrl(request);

    _setApiVersion(request);
    _setFrameworkVersion(request);
    _setAuthentication(request);
  }

  void setBody(RestRequest request) {}

  void setParams(RestRequest request) {}

  void setHeaders(RestRequest request) {}

  void setMethod(RestRequest request) {}

  void setUrl(RestRequest request) {
    throw IllegalArgumentException("Request 'url' not specified");
  }

  _setApiVersion(RestRequest request) {
    request.headers[HEADER_API_VERSION] = REST_API_VERSION;
  }

  _setFrameworkVersion(RestRequest request) {
    String versionValue = "$HEADER_FRAMEWORK_VERSION_VALUE_PREFIX ${CubeSettings.instance.versionName}";
    request.headers[HEADER_FRAMEWORK_VERSION] = versionValue;
  }

  _setAuthentication(RestRequest request) {
    request.headers[HEADER_TOKEN] = CubeSessionManager.instance.getToken();
  }

  T processResult(String responseBody);

  void putValue(
      Map<String?, dynamic> parametersMap, String key, dynamic value) {
    if (value != null) {
      parametersMap[key] = value;
    }
  }

  // Helps to build final query url, adding common url parts to specific part.
  String buildQueryUrl(List<dynamic> specificParts) {
    StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write(CubeSettings.instance.apiEndpoint);

    for (dynamic part in specificParts) {
      stringBuffer.write("/");
      stringBuffer.write(part.toString());
    }

    return stringBuffer.toString();
  }

  void updateTokenExpirationDate(RestResponse response) {
    DateTime? expirationDate = getTokenExpirationDateFromResponse(response);

    if (expirationDate != null) {
      CubeSessionManager.instance.setTokenExpirationDate(expirationDate);
    }
  }

  DateTime? getTokenExpirationDateFromResponse(RestResponse response) {
    Map<String, String>? headers = response.getHeaders();

    if (headers == null || headers.isEmpty) return null;

    if (headers.containsKey(HEADER_TOKEN_EXPIRATION_DATE.toLowerCase())) {
      try {
        DateFormat format = DateFormat(TOKEN_EXPIRATION_DATE_FORMAT);
        DateTime expirationDate = format.parse(
            headers[HEADER_TOKEN_EXPIRATION_DATE.toLowerCase()]!, true);
        return expirationDate;
      } catch (e) {
        log("Error while parsing 'CB-Token-ExpirationDate', error: $e");
        return null;
      }
    } else {
      return null;
    }
  }
}
