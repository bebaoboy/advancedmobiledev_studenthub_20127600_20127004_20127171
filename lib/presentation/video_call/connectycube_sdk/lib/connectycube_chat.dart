export 'connectycube_core.dart';

export 'src/chat/chat_connection_service.dart';

export 'src/chat/models/cube_message.dart';
export 'src/chat/models/cube_dialog.dart';
export 'src/chat/models/message_reaction_model.dart';
export 'src/chat/models/message_status_model.dart';
export 'src/chat/models/typing_status_model.dart';

export 'src/chat/query/dialogs_query.dart';
export 'src/chat/query/global_search.dart';
export 'src/chat/query/messages_query.dart';

export 'src/chat/realtime/extentions.dart';

export 'src/chat/realtime/managers/chat_messages_manager.dart';
export 'src/chat/realtime/managers/global_messages_manager.dart';
export 'src/chat/realtime/managers/messages_reactions_manager.dart';
export 'src/chat/realtime/managers/messages_statuses_manager.dart';
export 'src/chat/realtime/managers/privacy_lists_manager.dart';
export 'src/chat/realtime/managers/system_messages_manager.dart';
export 'src/chat/realtime/managers/typing_statuses_manager.dart';

export 'src/chat/realtime/utils/chat_constants.dart';
export 'src/chat/realtime/utils/jid_utils.dart';

import 'connectycube_core.dart';

import 'src/chat/models/cube_dialog.dart';
import 'src/chat/models/cube_message.dart';
import 'src/chat/query/dialogs_query.dart';
import 'src/chat/query/global_search.dart';
import 'src/chat/query/messages_query.dart';

Future<PagedResult<CubeDialog>?> getDialogs([Map<String, dynamic>? params]) {
  return GetDialogsQuery(params).perform();
}

Future<CubeDialog> createDialog(CubeDialog newDialog) {
  return CreateDialogQuery(newDialog).perform();
}

/// [params] - additional parameters for request. Use class-helper [UpdateDialogParams] to simple config request.
///
Future<CubeDialog> updateDialog(String dialogId, Map<String, dynamic> params) {
  return UpdateDialogQuery(dialogId, params).perform();
}

Future<void> deleteDialog(String dialogId, [bool? force]) {
  return DeleteDialogQuery(dialogId, force).perform();
}

Future<DeleteItemsResult?> deleteDialogs(Set<String> dialogsIds,
    [bool? force]) {
  return DeleteDialogsQuery(dialogsIds, force).perform();
}

Future<CubeDialog> subscribeToDialog(String dialogId) {
  return SubscribeToDialogQuery(dialogId).perform();
}

Future<void> unSubscribeFromDialog(String dialogId) {
  return UnSubscribeFromDialogQuery(dialogId).perform();
}

Future<CubeDialog> addRemoveAdmins(String dialogId,
    {Set<int>? toAddIds, Set<int>? toRemoveIds}) {
  return AddRemoveAdminsQuery(dialogId,
          addedIds: toAddIds, removedIds: toRemoveIds)
      .perform();
}

Future<bool> updateDialogNotificationsSettings(String dialogId, bool enable) {
  return UpdateNotificationsSettingsQuery(dialogId, enable).perform();
}

Future<bool> getDialogNotificationsSettings(String dialogId) {
  return GetNotificationsSettingsQuery(dialogId).perform();
}

Future<PagedResult<CubeUser>?> getDialogOccupants(String dialogId) {
  return GetDialogOccupantsQuery(dialogId).perform();
}

Future<int> getDialogsCount() {
  return GetDialogsCountQuery().perform();
}

/// [params] - additional parameters for request. Use class-helper [GlobalSearchParams] to simple config search request
///
Future<GlobalSearchResult> searchText(String searchText,
    [Map<String, dynamic>? params]) {
  return GlobalSearchQuery(searchText, params).perform();
}

Future<CubeMessage> createMessage(CubeMessage message, [bool sendToChat = false]) {
  return CreateMessageQuery(message, sendToChat).perform();
}

/// [params] - additional parameters for request. Use class-helper [GetMessagesParameters] to simple config request
///
Future<PagedResult<CubeMessage>?> getMessages(String dialogId,
    [Map<String, dynamic>? params]) {
  return GetMessageQuery(dialogId, params).perform();
}

Future<int> getMessagesCount(String dialogId) {
  return GetMessagesCountQuery(dialogId).perform();
}

Future<Map<String, int>> getUnreadMessagesCount([List<String>? dialogsIds]) {
  return GetUnreadMessagesCountQuery(dialogsIds).perform();
}

/// [params] - additional parameters for request. Use class-helper [UpdateMessageParameters] to simple config request
///
Future<void> updateMessage(String messageId, String dialogId,
    [Map<String, dynamic>? params]) {
  return UpdateMessageQuery(messageId, dialogId, params).perform();
}

/// [params] - additional parameters for request. Use class-helper [UpdateMessageParameters] to simple config request
///
Future<void> updateMessages(String dialogId, Map<String, dynamic> params,
    [Set<String>? messagesIds]) {
  String msgIdsString = "";
  if (messagesIds?.isNotEmpty ?? false) {
    msgIdsString = messagesIds!.join(',');
  }

  return UpdateMessageQuery(msgIdsString, dialogId, params).perform();
}

/// Adds the reaction on the message with [messageId]
/// [messageId] - the ID of the message you reacted on
/// [reaction] - the reaction you want to add
Future<void> addMessageReaction(String messageId, String reaction) {
  return updateMessageReactions(messageId, addReaction: reaction);
}

/// Removes the reaction on the message with [messageId] what was added before
/// [messageId] - the ID of the message you want to delete reaction of
/// [reaction] - the reaction you want to remove
Future<void> removeMessageReaction(String messageId, String reaction) {
  return updateMessageReactions(messageId, removeReaction: reaction);
}

/// Adds and/or removes reaction on the message with [messageId]
/// [messageId] - the ID of the message you reacted on
/// [addReaction] - the new reaction you want to add
/// [removeReaction] - the reaction you added before and want to delete
Future<void> updateMessageReactions(String messageId,
    {String? addReaction, String? removeReaction}) {
  return UpdateMessageReactionQuery(
    messageId,
    addReaction: addReaction,
    removeReaction: removeReaction,
  ).perform();
}

/// Returns reactions associated with message with [messageId]
/// Result contains the map where key is the reaction and value is the list of
/// users' ids who reacted with this reaction
/// [messageId] - the ID of the message you want to get reactions
Future<Map<String, List<int>>> getMessageReactions(String messageId) {
  return GetMessageReactionsQuery(messageId).perform();
}

/// Sends the System message to the [recipientId] via API request
/// The recipient will receive this system message through the chat connection as
/// the common system message.
/// [properties] - the additional parameters that the recipient will receive in the [CubeMessage.properties]
Future<CubeMessage> sendSystemMessage(int recipientId, Map<String, String>? properties) {
  return SendSystemMessageQuery(recipientId, properties).perform();
}

Future<DeleteItemsResult> deleteMessages(List<String> messagesIds,
    [bool? force]) {
  return DeleteMessagesQuery(messagesIds, force).perform();
}
