import '../../../connectycube_core.dart';

import '../utils/storage_utils.dart';

class CubeFile extends CubeEntity {
  String? uid;
  String? contentType;
  String? name;
  int? size;
  String? status;
  DateTime? completedAt;
  bool? isPublic = false;
  DateTime? lastReadAccessTime;
  CubeFileObjectAccess? fileObjectAccess;

  CubeFile();

  CubeFile.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    uid = json['uid'];
    contentType = json['content_type'];
    name = json['name'];
    size = json['size'];
    status = json['blob_status'];
    isPublic = json['public'];

    var fileObjectAccessRaw = json['blob_object_access'];
    if (fileObjectAccessRaw != null) {
      fileObjectAccess =
          CubeFileObjectAccess.fromJson(json['blob_object_access']);
    }

    var lastReadAccessTimeRaw = json['last_read_access_ts'];
    if (lastReadAccessTimeRaw != null) {
      lastReadAccessTime = DateTime.parse(lastReadAccessTimeRaw);
    }

    var completedAtRaw = json['set_completed_at'];
    if (completedAtRaw != null) {
      completedAt = DateTime.parse(completedAtRaw);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['uid'] = uid;
    json['content_type'] = contentType;
    json['name'] = name;
    json['size'] = size;
    json['blob_status'] = status;
    json['public'] = isPublic;
    json['last_read_access_ts'] = lastReadAccessTime;
    json['blob_object_access'] = fileObjectAccess;
    json['set_completed_at'] = completedAt;

    return json;
  }

  Map<String, dynamic> toCreateBlobJson() => {
        'content_type': contentType,
        'name': name,
        'public': isPublic,
      };

  Map<String, dynamic> toCompleteBlobJson() => {'size': size};

  Map<String, dynamic> toUpdateBlobJson() => {
        'content_type': contentType,
        'name': name,
      };

  @override
  toString() => toJson().toString();

  String? getPublicUrl() {
    if (!isPublic!) return null;

    return getPublicUrlForUid(uid);
  }

  String? getPrivateUrl() {
    return getPrivateUrlForUid(uid);
  }
}

class CubeFileStatus {
  static const String COMPLETE = "complete";
  static const String UNCOMPLETE = "uncomplete";
}

class CubeFileObjectAccess {
  int? id;
  int? fileId;
  String? expires;

//  DateTime expires;
  String? type;
  String? params;

  CubeFileObjectAccess.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fileId = json['blob_id'];
    type = json['object_access_type'];
    params = json['params'];
    expires = json['expires'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'blob_id': fileId,
        'expires': expires,
        'object_access_type': type,
        'params': params
      };
}
