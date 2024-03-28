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

class User {
  final UserType type;
  final String email;
  String name;
  bool isVerified;

  User({required this.type, required this.email, this.name = "", this.isVerified = true});
}
