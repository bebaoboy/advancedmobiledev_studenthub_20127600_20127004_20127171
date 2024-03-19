enum UserType { student, company }

UserType getUserType(String value) {
  if (value == 'student') {
    return UserType.student;
  } else {
    return UserType.company;
  }
}

class User {
  final UserType type;
  final String email;

  User({required this.type, required this.email});
}
