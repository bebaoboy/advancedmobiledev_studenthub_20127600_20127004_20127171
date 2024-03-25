class WsException implements Exception {
  String? cause;

  WsException(this.cause);
}

class WsNoResponseException extends WsException {
  WsNoResponseException(String super.s);
}

class WsHangUpException extends WsException {
  WsHangUpException(super.s);
}
