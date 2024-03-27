import '../../../connectycube_core.dart';

class CubeWhiteboard extends CubeEntity {
  String? whiteboardId;
  String? name;
  String? chatDialogId;
  int? userId;

  CubeWhiteboard({this.name, this.chatDialogId});

  CubeWhiteboard.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    whiteboardId = json['_id'];
    name = json['name'];
    chatDialogId = json['chat_dialog_id'];
    userId = json['user_id'];
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['_id'] = whiteboardId;
    json['name'] = name;
    json['chat_dialog_id'] = chatDialogId;
    json['user_id'] = userId;

    return json;
  }

  Map<String, dynamic> toCreateObjectJson() => {
        'name': name,
        'chat_dialog_id': chatDialogId,
      };

  @override
  toString() => toJson().toString();

  /// Returns the URL for using it in the WebView for displaying Whiteboard
  /// [userName] - the name of the user who connects to the Whiteboard. Should contain only Latin symbols.
  String getUrlForUser(String userName) {
    String whiteboardParams = getUriQueryString({
      'whiteboardid': whiteboardId,
      'username': userName,
      'title': name,
    });

    String whiteboardUrl =
        '${CubeSettings.instance.whiteboardUrl}?$whiteboardParams';
    return whiteboardUrl;
  }
}
