import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/src/whiteboard/models/cube_whiteboard.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/src/whiteboard/query/whiteboards_query.dart';

export 'connectycube_core.dart';

/// Creates new `CubeWhiteboard` model on the backend.
/// More details about required parameters by [link](https://developers.connectycube.com/server/whiteboar?id=parameters)
///
/// [whiteboard] - the instance of `CubeWhiteboard` which will be created on the backend.
Future<CubeWhiteboard> createWhiteboard(CubeWhiteboard whiteboard) {
  return CreateWhiteboardQuery(whiteboard).perform();
}

/// Returns whiteboards related to particular chat dialog with id [chatDialogId].
Future<List<CubeWhiteboard>> getWhiteboards(String chatDialogId) {
  return GetWhiteboardsQuery(chatDialogId).perform();
}

/// Updates the exist whiteboard.
///
/// [whiteboardId] - the id of the whiteboard which you want to update.
/// [newName] - the new name which you want to set for your whiteboard.
Future<CubeWhiteboard> updateWhiteboard(String whiteboardId, String newName) {
  return UpdateWhiteboardQuery(whiteboardId, newName).perform();
}

/// Deletes the whiteboard record by [whiteboardId] on the backend.
Future<void> deleteWhiteboard(String whiteboardId) {
  return DeleteWhiteboardQuery(whiteboardId).perform();
}
