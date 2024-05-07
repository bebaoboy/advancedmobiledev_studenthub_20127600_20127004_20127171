import 'package:boilerplate/presentation/dashboard/chat/widgets/chat_emoji.dart';
import 'package:boilerplate/presentation/dashboard/chat/widgets/message/schedule_message.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'messages/audio_message.dart';
import 'messages/custom_message.dart';
import 'messages/file_message.dart';
import 'messages/image_message.dart';
import 'messages/system_message.dart';
import 'messages/text_message.dart';
import 'messages/unsupported_message.dart';
import 'messages/video_message.dart';
import 'user.dart' show ChatUser;

/// All possible message types.
enum AbstractMessageType {
  audio,
  custom,
  file,
  image,
  system,
  text,
  unsupported,
  video,
  schedule,
}

/// All possible statuses message can have.
enum Status { delivered, error, seen, sending, sent }

/// An abstract class that contains all variables and methods
/// every message will have.
@immutable
abstract class AbstractChatMessage extends Equatable {
  AbstractChatMessage({
    required this.author,
    this.createdAt,
    required this.id,
    this.metadata,
    this.remoteId,
    this.repliedMessage,
    this.roomId,
    this.showStatus,
    this.status,
    required this.type,
    this.updatedAt,
  });

  /// Creates a particular message from a map (decoded JSON).
  /// Type is determined by the `type` field.
  factory AbstractChatMessage.fromJson(Map<String, dynamic> json) {
    final type = AbstractMessageType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => AbstractMessageType.unsupported,
    );

    switch (type) {
      case AbstractMessageType.audio:
        return AbstractAudioMessage.fromJson(json);
      case AbstractMessageType.custom:
        return AbstractCustomMessage.fromJson(json);
      case AbstractMessageType.file:
        return AbstractFileMessage.fromJson(json);
      case AbstractMessageType.image:
        return AbstractImageMessage.fromJson(json);
      case AbstractMessageType.system:
        return AbstractSystemMessage.fromJson(json);
      case AbstractMessageType.text:
        return AbstractTextMessage.fromJson(json);
      case AbstractMessageType.unsupported:
        return AbstractUnsupportedMessage.fromJson(json);
      case AbstractMessageType.video:
        return AbstractVideoMessage.fromJson(json);
      case AbstractMessageType.schedule:
        return ScheduleMessageType.fromJson(json);
    }
  }

  /// User who sent this message.
  final ChatUser author;

  /// Created message timestamp, in ms.
  final int? createdAt;

  /// Unique ID of the message.
  final String id;

  /// Additional custom metadata or attributes related to the message.
  final Map<String, dynamic>? metadata;

  /// Unique ID of the message received from the backend.
  final String? remoteId;

  /// Message that is being replied to with the current message.
  final AbstractChatMessage? repliedMessage;

  /// ID of the room where this message is sent.
  final String? roomId;

  /// Show status or not.
  final bool? showStatus;

  /// Message [Status].
  final Status? status;

  /// [AbstractMessageType].
  final AbstractMessageType type;

  /// Updated message timestamp, in ms.
  final int? updatedAt;

  final CubeMessageReactions? reactions = CubeMessageReactions();

  /// Creates a copy of the message with an updated data.
  AbstractChatMessage copyWith({
    ChatUser? author,
    int? createdAt,
    String? id,
    Map<String, dynamic>? metadata,
    String? remoteId,
    AbstractChatMessage? repliedMessage,
    String? roomId,
    bool? showStatus,
    Status? status,
    int? updatedAt,
  });

  /// Converts a particular message to the map representation, serializable to JSON.
  Map<String, dynamic> toJson() {
    return {
      "user": author.toJson(),
      "createdAt": createdAt,
      "metadata": metadata,
      "remoteId": remoteId,
      "repliedMessage": repliedMessage?.toJson(),
      "roomId": roomId,
      "showStatus": showStatus == true ? 1 : 0,
      "updatedAt": updatedAt,
      "status": status?.index ?? 0
    };
  }
}
