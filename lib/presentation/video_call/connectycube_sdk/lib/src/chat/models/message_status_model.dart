class CubeMessageStatus {
  int userId;
  String messageId;
  String? dialogId;

  CubeMessageStatus(this.userId, this.messageId, this.dialogId);
}

class EditedMessageStatus extends CubeMessageStatus {
  String updatedBody;

  EditedMessageStatus(
      super.userId, super.messageId, super.dialogId, this.updatedBody);
}
