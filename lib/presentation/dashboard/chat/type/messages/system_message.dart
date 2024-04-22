import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../message.dart';
import '../user.dart' show ChatUser;

part 'system_message.g.dart';

/// A class that represents a system message (anything around chat management). Use [metadata] to store anything
/// you want.
@JsonSerializable()
@immutable
abstract class AbstractSystemMessage extends AbstractChatMessage {
  /// Creates a custom message.
  const AbstractSystemMessage._({
    super.author = const ChatUser(id: 'system'),
    super.createdAt,
    required super.id,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    required this.text,
    AbstractMessageType? type,
    super.updatedAt,
  }) : super(type: type ?? AbstractMessageType.system);

  const factory AbstractSystemMessage({
    ChatUser author,
    int? createdAt,
    required String id,
    Map<String, dynamic>? metadata,
    String? remoteId,
    AbstractChatMessage? repliedMessage,
    String? roomId,
    bool? showStatus,
    Status? status,
    required String text,
    AbstractMessageType? type,
    int? updatedAt,
  }) = _SystemMessage;

  /// Creates a custom message from a map (decoded JSON).
  factory AbstractSystemMessage.fromJson(Map<String, dynamic> json) =>
      _$SystemMessageFromJson(json);

  /// System message content (could be text or translation key).
  final String text;

  /// Equatable props.
  @override
  List<Object?> get props => [
        author,
        createdAt,
        id,
        metadata,
        remoteId,
        repliedMessage,
        roomId,
        showStatus,
        status,
        text,
        updatedAt,
      ];

  @override
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
    String? text,
    int? updatedAt,
  });

  /// Converts a custom message to the map representation,
  /// encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$SystemMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _SystemMessage extends AbstractSystemMessage {
  const _SystemMessage({
    super.author,
    super.createdAt,
    required super.id,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    required super.text,
    super.type,
    super.updatedAt,
  }) : super._();

  @override
  AbstractChatMessage copyWith({
    ChatUser? author,
    dynamic createdAt = _Unset,
    String? id,
    dynamic metadata = _Unset,
    dynamic remoteId = _Unset,
    dynamic repliedMessage = _Unset,
    dynamic roomId,
    dynamic showStatus = _Unset,
    dynamic status = _Unset,
    String? text,
    dynamic updatedAt = _Unset,
  }) =>
      _SystemMessage(
        author: author ?? this.author,
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        id: id ?? this.id,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        remoteId: remoteId == _Unset ? this.remoteId : remoteId as String?,
        repliedMessage: repliedMessage == _Unset
            ? this.repliedMessage
            : repliedMessage as AbstractChatMessage?,
        roomId: roomId == _Unset ? this.roomId : roomId as String?,
        showStatus:
            showStatus == _Unset ? this.showStatus : showStatus as bool?,
        status: status == _Unset ? this.status : status as Status?,
        text: text ?? this.text,
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
      );
}

class _Unset {}
