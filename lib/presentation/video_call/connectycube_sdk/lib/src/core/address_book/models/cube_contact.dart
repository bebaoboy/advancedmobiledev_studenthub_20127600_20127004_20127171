class CubeContact {
  String? name;
  String? phone;
  bool? destroy;

  CubeContact(this.name, this.phone, {this.destroy});

  CubeContact.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    destroy = json['destroy'] != null && json['destroy'] == 1;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'name': name, 'phone': phone};
    if (destroy != null && destroy!) {
      json['destroy'] = 1;
    }

    return json;
  }

  @override
  toString() => toJson().toString();
}
