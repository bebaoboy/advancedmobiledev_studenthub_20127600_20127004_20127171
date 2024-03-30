class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://34.16.137.128";

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints
  static const String getPosts = "$baseUrl/posts";

  // auth endpoints
  static const String getCurrentUser = "$baseUrl/api/auth/me";
  static const String signUp = "$baseUrl/api/auth/sign-up";

  // user endpoints
  static const String resetPassword = "$baseUrl/api/user/{id}"; // require an id
  static const String getUsers = "$baseUrl/api/user";

  // profile
  static const String addProfileCompany = "$baseUrl/api/profile/company";
  static const String updateProfileCompany =
      "$baseUrl/api/profile/company/{id}"; // required an id
  static const String getProfileCompany =
      "$baseUrl/api/profile/company/{companyId}"; // required an id

  static const String addProfileStudent = "$baseUrl/api/profile/student";
  static const String updateProfileStudent =
      "$baseUrl/api/profile/student/{id}"; // required an id
  static const String getProfileStudent =
      "$baseUrl/api/profile/student/{studentId}"; // required an id
  static const String getProfileStudentTechStack =
      "$baseUrl/api/profile/student/{studentId}/techStack"; // required an id
}
