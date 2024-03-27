import '../../models/cube_custom_object_permissions.dart';

class CustomObjectPermissionsResult {
  CubeCustomObjectPermissions? permissions;
  String? recordId;

  CustomObjectPermissionsResult.fromJson(Map<String, dynamic> json) {
    permissions =
        CubeCustomObjectPermissions.fromJson(json['permissions']);
    recordId = json['record_id'];
  }

  Map<String, dynamic> toJson() {
    return {'permissions': permissions, 'record_id': recordId};
  }

  @override
  String toString() => toJson().toString();
}
