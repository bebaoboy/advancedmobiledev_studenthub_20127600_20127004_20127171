class WsException implements Exception {
  String? cause;

  WsException(this.cause);
}

class WsNoResponseException extends WsException {
  WsNoResponseException(String s) : super(s);
}

class WsHangUpException extends WsException {
  WsHangUpException(String? s) : super(s);
}
