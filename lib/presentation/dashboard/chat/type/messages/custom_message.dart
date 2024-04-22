import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../message.dart';
import '../user.dart' show ChatUser;
import 'partial_custom.dart';

part 'custom_message.g.dart';

/// A class that represents custom message. Use [metadata] to store anything
/// you want.
@JsonSerializable()
@immutable
abstract class AbstractCustomMessage extends AbstractChatMessage {
  /// Creates a custom message.
  const AbstractCustomMessage._({
    required super.author,
    super.createdAt,
    required super.id,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    AbstractMessageType? type,
    super.updatedAt,
  }) : super(type: type ?? AbstractMessageType.custom);

  const factory AbstractCustomMessage({
    required ChatUser author,
    int? createdAt,
    required String id,
    Map<String, dynamic>? metadata,
    String? remoteId,
    AbstractChatMessage? repliedMessage,
    String? roomId,
    bool? showStatus,
    Status? status,
    AbstractMessageType? type,
    int? updatedAt,
  }) = _CustomMessage;

  /// Creates a custom message from a map (decoded JSON).
  factory AbstractCustomMessage.fromJson(Map<String, dynamic> json) =>
      _$AbstractCustomMessageFromJson(json);

  /// Creates a full custom message from a partial one.
  factory AbstractCustomMessage.fromPartial({
    required ChatUser author,
    int? createdAt,
    required String id,
    required PartialCustom partialCustom,
    String? remoteId,
    String? roomId,
    bool? showStatus,
    Status? status,
    int? updatedAt,
  }) =>
      _CustomMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        metadata: partialCustom.metadata,
        remoteId: remoteId,
        repliedMessage: partialCustom.repliedMessage,
        roomId: roomId,
        showStatus: showStatus,
        status: status,
        type: AbstractMessageType.custom,
        updatedAt: updatedAt,
      );

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
    int? updatedAt,
  });

  /// Converts a custom message to the map representation,
  /// encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$AbstractCustomMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _CustomMessage extends AbstractCustomMessage {
  const _CustomMessage({
    required super.author,
    super.createdAt,
    required super.id,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
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
    dynamic updatedAt = _Unset,
  }) =>
      _CustomMessage(
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
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
      );
}

class _Unset {}
