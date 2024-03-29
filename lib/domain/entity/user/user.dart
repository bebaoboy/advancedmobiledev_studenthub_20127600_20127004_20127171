import 'package:boilerplate/domain/entity/project/entities.dart';
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
class User extends MyObject {
  // current login role
  UserType type;
  final String email;
  String name;
  bool isVerified;
  // all roles of user: student and company
  List<UserType>? roles = [UserType.company];
  StudentProfile? studentProfile;
  CompanyProfile? companyProfile;

  User(
      {super.objectId,
      this.type = UserType.naught,
      required this.email,
      this.name = "",
      this.isVerified = false,
      this.studentProfile,
      this.companyProfile,
      required this.roles});

  User.fromJson(Map<String, dynamic> json)
      : type = json["type"] == "0" ? UserType.student : UserType.company,
        email = json["email"] ?? "",
        name = json["name"] ?? "",
        isVerified = json["isVerified"] ?? false,
        studentProfile = null,
        companyProfile = null,
        roles = json["roles"] ?? [UserType.company];

// <<<<<<< sprint4-signup_accountActivation_forgetPassword
//   User(
//       {required this.type,
//       required this.email,
//       this.name = "",
//       this.isVerified = true});

//   User.fromJson(Map<String, dynamic> json)
//       : type = json["type"] == "0" ? UserType.student : UserType.company,
//         email = json["email"] ?? "",
//         name = json["name"] ?? "",
//         isVerified = json["isVerified"] ?? false;

// =======
  Map<String, dynamic> toJson() => {
        "type": type.name,
        "email": email,
        "name": name,
// <<<<<<< sprint4-signup_accountActivation_forgetPassword
//         "isVerified": isVerified
// =======
        "isVerified": isVerified,
        "studentProfile": studentProfile,
        "companyProfile": companyProfile,
        "role": roles,
      };
}
