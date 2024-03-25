import 'dart:convert';

import '../../../connectycube_core.dart';

import '../models/cube_whiteboard.dart';

class GetWhiteboardsQuery extends AutoManagedQuery<List<CubeWhiteboard>> {
  String chatDialogId;

  GetWhiteboardsQuery(this.chatDialogId);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.GET);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([WHITEBOARDS_ENDPOINT]));
  }

  @override
  setParams(RestRequest request) {
    Map<String, dynamic> parameters = request.params;

    putValue(parameters, 'chat_dialog_id', chatDialogId);
  }

  @override
  List<CubeWhiteboard> processResult(String response) {
    return List.from(jsonDecode(response))
        .map((element) => CubeWhiteboard.fromJson(element))
        .toList();
  }
}

class CreateWhiteboardQuery extends AutoManagedQuery<CubeWhiteboard> {
  CubeWhiteboard cubeWhiteboard;

  CreateWhiteboardQuery(this.cubeWhiteboard);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.POST);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([WHITEBOARDS_ENDPOINT]));
  }

  @override
  setBody(RestRequest request) {
    if (isValidWhiteboard(cubeWhiteboard)) {
      Map<String, dynamic> parameters = request.params;

      Map<String, dynamic> whiteboardToCreation =
          cubeWhiteboard.toCreateObjectJson();
      for (String key in whiteboardToCreation.keys) {
        parameters[key] = whiteboardToCreation[key];
      }
    }
  }

  @override
  CubeWhiteboard processResult(String response) {
    return CubeWhiteboard.fromJson(jsonDecode(response));
  }
}

class UpdateWhiteboardQuery extends AutoManagedQuery<CubeWhiteboard> {
  final String _whiteboardId;
  final String _newName;

  UpdateWhiteboardQuery(this._whiteboardId, this._newName);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.PUT);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([WHITEBOARDS_ENDPOINT, _whiteboardId]));
  }

  @override
  setBody(RestRequest request) {
    if (!isEmpty(_newName)) {
      Map<String, dynamic> parameters = request.params;
      parameters['name'] = _newName;
    }
  }

  @override
  CubeWhiteboard processResult(String response) {
    return CubeWhiteboard.fromJson(jsonDecode(response));
  }
}

class DeleteWhiteboardQuery extends AutoManagedQuery<void> {
  final String _id;

  DeleteWhiteboardQuery(this._id);

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([WHITEBOARDS_ENDPOINT, _id]));
  }

  @override
  void processResult(String response) {}
}

bool isValidWhiteboard(CubeWhiteboard cubeWhiteboard) {
  var errors = [];
  if (cubeWhiteboard.name?.isEmpty ?? true) {
    errors.add('\'name\' can not be null or empty');
  }

  if (cubeWhiteboard.chatDialogId?.isEmpty ?? true) {
    errors.add('\'chatDialogId\' can not be null or empty');
  }

  if (errors.isNotEmpty) {
    throw IllegalArgumentException('Error(s): ${errors.join(', ')}');
  } else {
    return true;
  }
}
