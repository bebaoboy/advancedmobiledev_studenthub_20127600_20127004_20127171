import 'models/cube_error_packet.dart';

class ChatConnectionException implements Exception {
  String? message = "";
  ErrorPacket? error;

  ChatConnectionException({this.message, this.error});

  @override
  String toString() {
    return "ChatConnectionException: $message ${error != null ? error.toString() : ""}";
  }
}

const String CHAT_NOT_CONNECTED_ERROR =
    "Something went wrong, check login to the chat and try again";
