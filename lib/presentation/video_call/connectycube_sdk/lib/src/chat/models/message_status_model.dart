class MessageStatus {
  int userId;
  String messageId;
  String? dialogId;

  MessageStatus(this.userId, this.messageId, this.dialogId);
}

class EditedMessageStatus extends MessageStatus {
  String updatedBody;

  EditedMessageStatus(
      super.userId, super.messageId, super.dialogId, this.updatedBody);
}
