import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/home/splashscreen.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/profile/profile.dart';
import 'package:boilerplate/presentation/profile/profile_step2.dart';
import 'package:boilerplate/presentation/profile/profile_student_step2.dart';
import 'package:boilerplate/presentation/profile/profile_student_step3.dart';
import 'package:boilerplate/presentation/setting/setting.dart';
import 'package:boilerplate/presentation/profile/profile_student.dart';
import 'package:boilerplate/presentation/signup/signup.dart';
import 'package:boilerplate/presentation/signup/signup_company.dart';
import 'package:boilerplate/presentation/signup/signup_student.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._() {
    _route.forEach((key, value) {
      routes[key] = (BuildContext context) => value;
    });
  }

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String signUpCompany = '/signup-company';
  static const String signUpStudent = '/signup-student';
  static const String profileStudent = '/profile-student';
  static const String profileStudentStep2 = '/profile-student-step2';
  static const String profileStudentStep3 = '/profile-student-step3';
  static const String home = '/post';
  static const String profile = '/profile';
  static const String profileStep2 = '/profile-step2';
  static const String setting = '/settings';

  static final _route = <String, Widget>{
    splash: SplashScreen(),
    login: LoginScreen(),
    signUp: SignUpScreen(),
    setting: SettingScreen(),
    profile: ProfileScreen(),
    profileStep2: ProfileStep2Screen(),
    signUpCompany: SignUpCompanyScreen(),
    signUpStudent: SignUpStudentScreen(),
    home: HomeScreen(),
    profileStudent: ProfileStudentScreen(),
    profileStudentStep2: ProfileStudentStep2Screen(),
    profileStudentStep3: ProfileStudentStep3Screen(),
  };

  static final routes = <String, WidgetBuilder>{};
}

getRoute(name) {
  return Routes._route[name] ?? HomeScreen();
}
