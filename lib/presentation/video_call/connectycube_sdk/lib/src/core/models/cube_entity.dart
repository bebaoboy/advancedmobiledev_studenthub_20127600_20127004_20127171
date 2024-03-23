class CubeEntity {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  CubeEntity();

  CubeEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    var createdAtRaw = json['created_at'];
    if (createdAtRaw != null) {
      createdAt = DateTime.parse(createdAtRaw);
    }

    var updatedAtRaw = json['updated_at'];
    if (updatedAtRaw != null) {
      updatedAt = DateTime.parse(updatedAtRaw);
    }
  }
}
