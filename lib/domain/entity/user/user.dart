import 'package:json_annotation/json_annotation.dart';

enum UserType { student, company, naught }

UserType getUserType(String value) {
  if (value == 'student') {
    return UserType.student;
  }
  if (value == 'company') {
    return UserType.company;
  } else {
    return UserType.naught;
  }
}

@JsonSerializable()
class User {
  final UserType type;
  final String email;
  String name;
  bool isVerified;

  User(
      {required this.type,
      required this.email,
      this.name = "",
      this.isVerified = true});

  User.fromJson(Map<String, dynamic> json)
      : type = json["type"] == "0" ? UserType.student : UserType.company,
        email = json["email"] ?? "",
        name = json["name"] ?? "",
        isVerified = json["isVerified"] ?? false;

  Map<String, dynamic> toJson() => {
        "type": type.name,
        "email": email,
        "name": name,
        "isVerified": isVerified
      };
}
