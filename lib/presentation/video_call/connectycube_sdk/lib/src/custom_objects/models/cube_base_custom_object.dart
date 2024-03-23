class CubeBaseCustomObject {
  String? className;

  Map<String, dynamic> fields = Map();

  CubeBaseCustomObject(this.className);

  CubeBaseCustomObject.fromJson(Map<String, dynamic> json) {
    className = json.remove('class_name');

    fields.addAll(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map();
    json.addAll(fields);

    return json;
  }

  @override
  String toString() {
    Map<String, dynamic> json = toJson();
    json['class_name'] = className;

    return json.toString();
  }
}
