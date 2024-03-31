class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://34.16.137.128";

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints // not needed
  static const String getPosts = "$baseUrl/posts";

  // auth endpoints
  static const String getCurrentUser = "$baseUrl/api/auth/me";
  static const String signUp = "$baseUrl/api/auth/sign-up"; // done

  // user endpoints
  static const String resetPassword = "$baseUrl/api/user/{id}";
  static const String getUsers = "$baseUrl/api/user";

  // profile
  static const String addProfileCompany =
      "$baseUrl/api/profile/company"; // done
  static const String updateProfileCompany =
      "$baseUrl/api/profile/company/{id}";
  static const String getProfileCompany =
      "$baseUrl/api/profile/company/{companyId}";

  static const String addProfileStudent =
      "$baseUrl/api/profile/student"; // semi-done
  static const String updateProfileStudent =
      "$baseUrl/api/profile/student/{id}";
  static const String getProfileStudent =
      "$baseUrl/api/profile/student/{studentId}";
  static const String getProfileStudentTechStack =
      "$baseUrl/api/profile/student/{studentId}/techStack";

  static const String getLanguage =
      "$baseUrl/language/getByStudentId/{studentId}";
  static const String updateLanguage =
      "$baseUrl/language/updateByStudentId/{studentId}";
  static const String getEducation =
      "$baseUrl/education/getByStudentId/{studentId}";
  static const String updateEducation =
      "$baseUrl/education/updateByStudentId/{studentId}";
  static const String getProjectExperience =
      "$baseUrl/experience/getByStudentId/{studentId}";
  static const String updateProjectExperience =
      "$baseUrl/experience/updateByStudentId/{studentId}";

  static const String addTechStack = "$baseUrl/api/techstack/createTechStack";
  static const String addSkillset = "$baseUrl/api/skillset/createSkillSet";
}
