import 'dart:async';

import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/preferences.dart';

/*
{
  "email": "baominkhuynh@gmail.com",
  "password": "12345678Bao+"
} */
String baominkhuynh =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NDgsImZ1bGxuYW1lIjoiYmFvIiwiZW1haWwiOiIxMjMrQG1haWwuY29tIiwicm9sZXMiOlsiMCJdLCJpYXQiOjE3MTE4Nzg0MzcsImV4cCI6MTcxMzA4ODAzN30.I2R9UyKH6aRp_XXSwXxBumUZ78qkKAtuYaGzeijZFOQ";

class SharedPreferenceHelper {
  // shared pref instance
  final SharedPreferences _sharedPreference;

  // constructor
  SharedPreferenceHelper(this._sharedPreference);

  // General Methods: ----------------------------------------------------------
  Future<String?> get authToken async {
    // return Future.value(baominkhuynh);
    return _sharedPreference.getString(Preferences.auth_token);
  }

  Future<bool> saveAuthToken(String authToken) async {
    return _sharedPreference.setString(Preferences.auth_token, authToken);
  }

  Future<bool> removeAuthToken() async {
    return _sharedPreference.remove(Preferences.auth_token);
  }

  // Login:---------------------------------------------------------------------
  Future<bool> get isLoggedIn async {
    return _sharedPreference.getBool(Preferences.is_logged_in) ?? false;
  }

  Future<bool> saveIsLoggedIn(bool value) async {
    return _sharedPreference.setBool(Preferences.is_logged_in, value);
  }

  // Theme:------------------------------------------------------
  bool get isDarkMode {
    return _sharedPreference.getBool(Preferences.is_dark_mode) ?? false;
  }

  Future<void> changeBrightnessToDark(bool value) {
    return _sharedPreference.setBool(Preferences.is_dark_mode, value);
  }

  // Language:---------------------------------------------------
  String? get currentLanguage {
    return _sharedPreference.getString(Preferences.current_language);
  }

  Future<void> changeLanguage(String language) {
    return _sharedPreference.setString(Preferences.current_language, language);
  }

  // user
  Future<void> saveUser(User? user) {
    if (user == null) {
      _sharedPreference.setString(Preferences.current_user_email, '');
      return _sharedPreference.setString(Preferences.current_user_role, '');
    }
    _sharedPreference.setString(Preferences.current_user_email, user.email);
    _sharedPreference.setStringList(
        Preferences.current_user_roleList,
        user.roles!
            .map(
              (e) => e.name,
            )
            .toList());
    return _sharedPreference.setString(
        Preferences.current_user_role, user.type.name.toLowerCase().toString());
  }

  Future<void> saveRolesList(List<UserType> roles) {
    return _sharedPreference.setStringList(
        Preferences.current_user_roleList,
        roles
            .map(
              (e) => e.name,
            )
            .toList());
  }

  Future<User> get user async {
    String userEmail =
        _sharedPreference.getString(Preferences.current_user_email) ?? '';
    String userRole =
        _sharedPreference.getString(Preferences.current_user_role) ?? '';
    var r = _sharedPreference.getStringList(Preferences.current_user_roleList);
    List<UserType> userRoles = (r ?? ["company"])
        .map(
          (e) => e == "company" ? UserType.company : UserType.student,
        )
        .toList();

    UserType userType = getUserType(userRole);

    String name =
        _sharedPreference.getString(Preferences.current_user_name) ?? '';

    int id = _sharedPreference.getInt(Preferences.current_user_id) ?? 0;

    return User(
      email: userEmail,
      type: userType,
      roles: userRoles,
      name: name,
      objectId: id.toString(),
      companyProfile: await companyProfile,
      studentProfile: await studentProfile,
    );
  }

  Future<bool> saveStudentProfile(StudentProfile? studentProfile) async {
    if (studentProfile == null) {
      return false;
    }

    print(studentProfile.toJson().toString());

    return _sharedPreference.setString(
        Preferences.student_profile, studentProfile.toJson());
  }

  Future<bool> saveCompanyProfile(CompanyProfile? companyProfile) async {
    if (companyProfile == null) {
      return false;
    }

    print(companyProfile.toJson().toString());

    return _sharedPreference.setString(
        Preferences.company_profile, companyProfile.toJson());
  }

  Future<StudentProfile?> get studentProfile async {
    var data = _sharedPreference.getString(Preferences.student_profile) ?? '';
    if (isNotBlank(data)) {
      return StudentProfile.fromJson(data);
    } else {
      return null;
    }
  }

  Future<CompanyProfile?> get companyProfile async {
    var data = _sharedPreference.getString(Preferences.company_profile) ?? '';
    if (isNotBlank(data)) {
      return CompanyProfile.fromJson(data);
    } else {
      return null;
    }
  }

  Future<void> deleteProfile() async {
    await _sharedPreference.setString(Preferences.company_profile, '');
    await _sharedPreference.setString(Preferences.student_profile, '');
  }

  Future<List<Profile?>> getCurrentProfile() async {
    final company = await companyProfile.catchError((_) => null);
    final student = await studentProfile.catchError((_) => null);
    return [student, company];
  }

  Future<void> removeUser() async {
    await _sharedPreference.setString(Preferences.current_user_email, "");
    await _sharedPreference.setString(Preferences.current_user_role, "");
    await _sharedPreference
        .setStringList(Preferences.current_user_roleList, []);
    await _sharedPreference.setString(Preferences.current_user_name, "");
  }

  Future saveName(String name) async {
    await _sharedPreference.setString(Preferences.current_user_name, name);
  }

  Future saveId(int id) async {
    await _sharedPreference.setInt(Preferences.current_user_id, id);
  }

  // forget password

  Future<String> get oldPass async {
    int id = _sharedPreference.getInt(Preferences.current_user_id) ?? 0;
    return _sharedPreference.getString("${Preferences.encrypted_pass}_$id") ??
        '';
  }

  Future<bool> get requiredChangePass async {
    int id = _sharedPreference.getInt(Preferences.current_user_id) ?? 0;
    var oldPass =
        _sharedPreference.getString("${Preferences.encrypted_pass}_$id") ?? '';
    return oldPass != '';
  }

  Future saveOldPassEncrypted(String oldPass) async {
    int id = _sharedPreference.getInt(Preferences.current_user_id) ?? 0;
    if (oldPass == '') {
      await _sharedPreference.remove("${Preferences.encrypted_pass}_$id");
    } else {
      await _sharedPreference.setString(
          "${Preferences.encrypted_pass}_$id", oldPass);
    }
  }

  Future saveHasToChangePass(bool value) async {
    int id = _sharedPreference.getInt(Preferences.current_user_id) ?? 0;
    await _sharedPreference.setBool(
        "${Preferences.required_pass_change}_$id", value);
  }
}
