// ignore_for_file: prefer_final_fields

class ResponseException implements Exception {
  String? _message = "";

  ResponseException([this._message]);

  @override
  String toString() {
    return _message!;
  }
}

class IllegalArgumentException implements Exception {
  String? _message = "";

  IllegalArgumentException([this._message]);

  @override
  String toString() {
    return "IllegalArgumentException: $_message";
  }
}

class IllegalStateException implements Exception {
  String? _message = "";

  IllegalStateException([this._message]);

  @override
  String toString() {
    return "IllegalStateException: $_message";
  }
}
