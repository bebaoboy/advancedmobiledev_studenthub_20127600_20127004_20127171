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

  //auth endpoints
  static const String signUp = "$baseUrl/api/auth/sign-up";
  static const String login = "$baseUrl/api/auth/sign-in";
  static const String getProfile = "$baseUrl/api/auth/me";
  static const String logout = "$baseUrl/api/auth/logout";

  //user endpoints
  static const String resetPassword = "$baseUrl/api/user"; // require an id
  static const String getUsers = "$baseUrl/api/user";
  static const String changePassword = "$baseUrl/api/user/changePassword";
  static const String forgetPassword = "$baseUrl/api/user/forgotPassword";
}
