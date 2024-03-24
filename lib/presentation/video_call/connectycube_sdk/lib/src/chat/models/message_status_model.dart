class MessageStatus {
  int userId;
  String messageId;
  String? dialogId;

  MessageStatus(this.userId, this.messageId, this.dialogId);
}

class EditedMessageStatus extends MessageStatus {
  String updatedBody;

  EditedMessageStatus(
      int userId, String messageId, String? dialogId, this.updatedBody)
      : super(userId, messageId, dialogId);
}
