// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../connectycube_custom_objects.dart';

import 'cube_message.dart';
import '../chat_connection_service.dart';
import '../realtime/managers/chat_managers.dart';

class CubeDialog extends CubeEntity {
  String? dialogId;
  String? lastMessage;
  int? lastMessageDateSent;
  int? lastMessageUserId;
  String? lastMessageId;
  String? photo;
  int? userId;
  String? roomJid;
  int? unreadMessageCount;
  String? name;
  List<int>? occupantsIds;
  bool? isEncrypted;
  bool? isMuted;
  List<String>? pinnedMessagesIds;
  int? type;
  List<int>? adminsIds;

  @Deprecated('Use the field `extensions` instead.')
  CubeDialogCustomData? customData;
  String? description;
  int? occupantsCount;

  /// Last sent message state. Will be 'null' if the last message is sent by another user (not you).
  /// Will be one of the [MessageState.sent], [MessageState.delivered], [MessageState.read] if last message is sent by you.
  MessageState? lastMessageState;

  /// The keys should be specified in the Connectycube admin panel first.
  Map<String, String>? extensions;

  CubeDialog(this.type,
      {this.dialogId,
      this.name,
      this.description,
      this.occupantsIds,
      this.photo,
      this.pinnedMessagesIds,
      this.adminsIds,
      this.customData,
      this.extensions});

  CubeDialog.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    dialogId = json['_id'];
    lastMessage = json['last_message'];
    lastMessageDateSent = json['last_message_date_sent'];
    lastMessageUserId = json['last_message_user_id'];
    photo = json['photo'];
    userId = json['user_id'];
    roomJid = json['xmpp_room_jid'];
    unreadMessageCount = json['unread_messages_count'];
    name = json['name'];
    type = json['type'];
    description = json['description'];
    occupantsCount = json['occupants_count'];

    var occupantsIdsRaw = json['occupants_ids'];
    if (occupantsIdsRaw != null) {
      occupantsIds = List.of(occupantsIdsRaw).map((id) => id as int).toList();
    }

    var pinnedMessagesIdsRaw = json['pinned_messages_ids'];
    if (pinnedMessagesIdsRaw != null) {
      pinnedMessagesIds =
          List.of(pinnedMessagesIdsRaw).map((id) => id.toString()).toList();
    }

    var adminsIdsRaw = json['admins_ids'];
    if (adminsIdsRaw != null) {
      adminsIds = List.of(adminsIdsRaw).map((id) => id as int).toList();
    }

    var customDataRaw = json['data'];
    if (customDataRaw != null) {
      customData = CubeDialogCustomData.fromJson(customDataRaw);
    }

    var extensionsRaw = json['extensions'];
    if (extensionsRaw != null) {
      extensions = Map<String, String>.from(extensionsRaw);
    }

    var lastMessageStatus = json['last_message_status'];
    if (lastMessageStatus != null) {
      lastMessageState = lastMessageStatus.toString().toMessageState();
    }

    lastMessageId = json['last_message_id'];
    isEncrypted = json['is_e2ee'];
    isMuted = json['is_muted'];
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      '_id': dialogId,
      'last_message': lastMessage,
      'last_message_date_sent': lastMessageDateSent,
      'last_message_user_id': lastMessageUserId,
      'photo': photo,
      'user_id': userId,
      'xmpp_room_jid': roomJid,
      'unread_messages_count': unreadMessageCount,
      'name': name,
      'type': type,
      'description': description,
      'occupants_count': occupantsCount,
      'occupants_ids': occupantsIds,
      'pinned_messages_ids': pinnedMessagesIds,
      'admins_ids': adminsIds,
      'data': customData,
      'extensions': extensions,
      'last_message_status': lastMessageState?.value,
      'last_message_id': lastMessageId,
      'is_e2ee': isEncrypted,
      'is_muted': isMuted,
    };

    json.addAll(super.toJson());

    return json;
  }

  @override
  toString() => toJson().toString();

  int getRecipientId() {
    if (CubeDialogType.PRIVATE != type || isEmptyList(occupantsIds)) {
      return -1;
    }

    CubeChatConnection chatConnection = CubeChatConnection.instance;

    if (chatConnection.currentUser == null) return -1;

    for (int occupantId in occupantsIds!) {
      if (occupantId != chatConnection.currentUser!.id) return occupantId;
    }

    return -1;
  }

  Future<void> sendText(String text) {
    CubeMessage message = CubeMessage();
    message.body = text;

    return sendMessage(message);
  }

  Future<CubeMessage> sendMessage(CubeMessage message) {
    Completer<CubeMessage> completer = Completer();

    checkInit().then((chat) {
      message.dialogId = dialogId;
      completer.complete(chat.sendMessage(message));
    }).catchError((onError) {
      completer.completeError(onError);
    });

    return completer.future;
  }

  Future<void> deliverMessage(CubeMessage message) {
    Completer<void> completer = Completer();

    checkInit().then((chat) {
      message.dialogId = dialogId;
      chat.deliverMessage(message);
      completer.complete();
    }).catchError((onError) {
      completer.completeError(onError);
    });

    return completer.future;
  }

  Future<void> readMessage(CubeMessage message) {
    Completer<void> completer = Completer();

    checkInit().then((chat) {
      message.dialogId = dialogId;
      chat.readMessage(message);
      completer.complete();
    }).catchError((onError) {
      completer.completeError(onError);
    });

    return completer.future;
  }

  void sendIsTypingStatus() {
    checkInit().then((chat) {
      chat.sendIsTypingNotification();
    });
  }

  void sendStopTypingStatus() {
    checkInit().then((chat) {
      chat.sendStopTypingNotification();
    });
  }

  /// Deletes the message using chat connection. Opponent(s) will receive event about it to
  /// the listener:
  /// ```dart
  /// CubeChatConnection.instance.messagesStatusesManager!.deletedStream.listen((status) {
  ///     // the message was deleted, update your UI
  /// });
  /// ```
  ///
  /// [message] - the original message to delete. This message should contain `messageId` and `dialogId`.
  ///
  /// Throws an [IllegalArgumentException] if `messageId` or `dialogId` is empty.
  Future<void> deleteMessage(CubeMessage message) {
    Completer<void> completer = Completer();

    checkInit().then((chat) {
      completer.complete(chat.deleteMessage(message));
    }).catchError((onError) {
      completer.completeError(onError);
    });

    return completer.future;
  }

  /// Edits the message using chat connection. Opponent(s) will receive event about it to
  /// the listener:
  /// ```dart
  /// CubeChatConnection.instance.messagesStatusesManager!.editedStream.listen((status) {
  ///     // the message was edited, update your UI
  /// });
  /// ```
  ///
  /// [message] - the original message to update. This message should contain `body`(updated body), `messageId` and `dialogId`.
  ///
  /// Throws an [IllegalArgumentException] if `body` or `messageId` or `dialogId` is empty.
  Future<void> editMessage(CubeMessage message, bool isLast) {
    Completer<void> completer = Completer();

    checkInit().then((chat) {
      completer.complete(chat.editMessage(message, isLast));
    }).catchError((onError) {
      completer.completeError(onError);
    });

    return completer.future;
  }

  Future<AbstractChat> checkInit() {
    Completer<AbstractChat> completer = Completer();

    if (CubeDialogType.PRIVATE == type) {
      int recipientId = getRecipientId();
      if (recipientId == -1) {
        completer.completeError(IllegalStateException(
            "Check you set participant and login to the chat"));
        return completer.future;
      }

      PrivateChatManager? privateChatManager =
          CubeChatConnection.instance.privateChatManager;
      if (privateChatManager == null) {
        completer.completeError(IllegalStateException(
            "Need login to the chat before perform chat related operations"));
        return completer.future;
      }

      PrivateChat privateChat = privateChatManager.getChat(recipientId);

      completer.complete(privateChat);
    } else {
      if (isEmpty(dialogId)) {
        completer.completeError(IllegalStateException(
            "'dialog_id' can't be empty or null for this dialog type"));
        return completer.future;
      }

      GroupChatManager? groupChatManager =
          CubeChatConnection.instance.groupChatManager;
      if (groupChatManager == null) {
        completer.completeError(IllegalStateException(
            "Need login to the chat before perform chat related operations"));
        return completer.future;
      }

      GroupChat groupChat = groupChatManager.getChat(dialogId);

      if (CubeSettings.instance.isJoinEnabled) {
        _joinInternal(groupChat).then((groupChat) {
          completer.complete(groupChat);
        }).catchError((error) {
          completer.completeError(error);
        });
      } else {
        completer.complete(groupChat);
      }
    }

    return completer.future;
  }

  Future<GroupChat> _joinInternal(GroupChat groupChat) {
    Completer<GroupChat> completer = Completer();

    if (CubeDialogType.PRIVATE == type) {
      completer.completeError(
          IllegalStateException('Unavailable operation for \'PRIVATE\' chat'));
    } else {
      groupChat.join().then((groupChat) {
        completer.complete(groupChat);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  Future<CubeDialog> join() {
    Completer<CubeDialog> completer = Completer();

    checkInit().then((currentChat) {
      completer.complete(this);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<void> leave() {
    Completer completer = Completer();

    if (CubeDialogType.PRIVATE == type) {
      completer.complete(null);
    } else {
      checkInit().then((abstractChat) {
        (abstractChat as GroupChat).leave().then((result) {
          completer.complete((null));
        }).catchError((error) {
          completer.completeError(error);
        });
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }
}

class CubeDialogType {
  static const int BROADCAST = 1;
  static const int GROUP = 2;
  static const int PRIVATE = 3;
  static const int PUBLIC = 4;
}

@Deprecated('Use the field `CubeDialog.extensions` instead.')
class CubeDialogCustomData extends CubeBaseCustomObject {
  CubeDialogCustomData(String super.className);

  CubeDialogCustomData.fromJson(super.json)
      : super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['class_name'] = className;

    return json;
  }

  @override
  toString() => toJson().toString();
}

enum MessageState { sent, delivered, read }

extension MessageStatusExt on MessageState {
  String get value => describeEnum(this);
}

extension MessageStateString on String {
  MessageState toMessageState() =>
      MessageState.values.firstWhere((d) => describeEnum(d) == toLowerCase());
}
