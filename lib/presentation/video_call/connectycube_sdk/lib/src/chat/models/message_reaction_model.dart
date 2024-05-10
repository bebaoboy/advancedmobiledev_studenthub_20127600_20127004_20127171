class MessageReaction {
  int userId;
  String messageId;
  String dialogId;
  String? addReaction;
  String? removeReaction;

  MessageReaction(this.userId, this.dialogId, this.messageId,
      {this.addReaction, this.removeReaction});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'message_id': messageId,
        'dialog_id': dialogId,
        'add': addReaction,
        'remove': removeReaction
      };

  @override
  String toString() => toJson().toString();
}
