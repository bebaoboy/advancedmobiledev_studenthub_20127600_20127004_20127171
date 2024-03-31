import 'dart:async';

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/preferences.dart';

class SharedPreferenceHelper {
  // shared pref instance
  final SharedPreferences _sharedPreference;

  // constructor
  SharedPreferenceHelper(this._sharedPreference);

  // General Methods: ----------------------------------------------------------
  Future<String?> get authToken async {
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
        roles!
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
    List<UserType> userRoles =
        (_sharedPreference.getStringList(Preferences.current_user_roleList) ??
                ["company"])
            .map(
              (e) => e == "company" ? UserType.company : UserType.student,
            )
            .toList();

    UserType userType = getUserType(userRole);

    return User(email: userEmail, type: userType, roles: userRoles);
  }

  Future<bool> saveStudentProfile(StudentProfile? studentProfile) async {
    if (studentProfile != null) {
      return false;
    }

    return _sharedPreference.setString(
        Preferences.student_profile, studentProfile!.toJson());
  }

  Future<bool> saveCompanyProfile(CompanyProfile? companyProfile) async {
    if (companyProfile != null) {
      return false;
    }

    return _sharedPreference.setString(
        Preferences.company_profile, companyProfile!.toJson());
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
    return [student, company].toList();
  }
}
