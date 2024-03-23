class CubeCustomObjectPermissions {
  CubeCustomObjectPermission? readPermission;
  CubeCustomObjectPermission? updatePermission;
  CubeCustomObjectPermission? deletePermission;

  CubeCustomObjectPermissions(
      {this.readPermission, this.updatePermission, this.deletePermission});

  CubeCustomObjectPermissions.fromJson(Map<String, dynamic> json) {
    this.readPermission = CubeCustomObjectPermission.fromJson(json['read']);
    this.updatePermission = CubeCustomObjectPermission.fromJson(json['update']);
    this.deletePermission = CubeCustomObjectPermission.fromJson(json['delete']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map();

    if (readPermission != null) {
      json['read'] = readPermission!.toJson();
    }

    if (updatePermission != null) {
      json['update'] = updatePermission!.toJson();
    }

    if (deletePermission != null) {
      json['delete'] = deletePermission!.toJson();
    }

    return json;
  }

  @override
  toString() => toJson().toString();
}

class CubeCustomObjectPermission {
  String? level;
  List<int>? ids;
  List<String>? tags;

  ///[ids] required for [level] `open_for_users_ids`
  ///[tags] required for [level] `open_for_groups`
  CubeCustomObjectPermission(this.level, {this.ids, this.tags});

  CubeCustomObjectPermission.fromJson(Map<String, dynamic> json) {
    this.level = json['access'];

    if (Level.OPEN_FOR_USERS_IDS == level) {
      this.ids = List.from(json['users_ids']);
    } else if (Level.OPEN_FOR_GROUPS == level) {
      this.tags = List.from(json['users_groups']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> accessParams = {'access': level};

    if (Level.OPEN_FOR_USERS_IDS == level) {
      accessParams['ids'] = ids!.map((intId) => intId.toString()).toList();
    } else if (Level.OPEN_FOR_GROUPS == level) {
      accessParams['groups'] = tags;
    }

    return accessParams;
  }

  @override
  toString() => toJson().toString();
}

class Level {
  static const String OPEN = "open";
  static const String OWNER = "owner";
  static const String NOT_ALLOWED = "not_allowed";
  static const String OPEN_FOR_GROUPS = "open_for_groups";
  static const String OPEN_FOR_USERS_IDS = "open_for_users_ids";
}

class Action {
  static const String CREATE = "create";
  static const String READ = "read";
  static const String UPDATE = "update";
  static const String DELETE = "delete";
}
