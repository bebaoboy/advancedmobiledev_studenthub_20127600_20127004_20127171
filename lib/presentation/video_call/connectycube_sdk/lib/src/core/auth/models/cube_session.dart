import '../../models/cube_entity.dart';
import '../../users/models/cube_user.dart';

class CubeSession extends CubeEntity {
  String? token;
  int? appId;
  int? userId;
  CubeUser? user;
  int? deviceId;
  int? timestamp;
  int? nonce;
  DateTime? tokenExpirationDate;

  CubeSession.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    userId = json['user_id'];

    var userRaw = json['user'];
    if (userRaw != null) {
      user = CubeUser.fromJson(userRaw);
    }

    appId = json['application_id'];
    nonce = json['nonce'];
    token = json['token'];
    timestamp = json['ts'];

    var tokenExpirationDateRaw = json['token_expiration_date'];
    if (tokenExpirationDateRaw != null) {
      tokenExpirationDate = DateTime.parse(tokenExpirationDateRaw);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'user_id': userId,
      'user': user,
      'application_id': appId,
      'nonce': nonce,
      'token': token,
      'ts': timestamp,
      'token_expiration_date': tokenExpirationDate?.toIso8601String()
    };

    json.addAll(super.toJson());

    return json;
  }

  @override
  String toString() => toJson().toString();
}
