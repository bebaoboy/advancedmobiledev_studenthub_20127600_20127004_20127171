import 'cube_base_custom_object.dart';
import 'cube_custom_object_permissions.dart';

class CubeCustomObject extends CubeBaseCustomObject {
  String? id;
  int? userId;
  int? createdAt;
  int? updatedAt;
  dynamic parentId;
  CubeCustomObjectPermissions? permissions;

  CubeCustomObject(String className) : super(className);

  CubeCustomObject.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.id = json.remove('_id');
    this.userId = json.remove('user_id');
    this.parentId = json.remove('_parent_id');
    this.createdAt = json.remove('created_at');
    this.updatedAt = json.remove('updated_at');
    var permissions = json.remove('permissions');
    if (permissions != null) {
      this.permissions = CubeCustomObjectPermissions.fromJson(permissions);
    }

    fields.addAll(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    if (permissions != null) {
      json['permissions'] = permissions;
    }

    return json;
  }

  @override
  String toString() {
    Map<String, dynamic> json = toJson();
    json['class_name'] = className;

    if (permissions == null) {
      json['permissions'] = null;
    }

    return json.toString();
  }
}
