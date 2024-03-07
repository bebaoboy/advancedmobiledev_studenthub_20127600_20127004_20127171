import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/home/splashscreen.dart';
import 'package:boilerplate/presentation/login/login.dart';
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
  static const String home = '/post';

  static final _route = <String, Widget>{
    splash: SplashScreen(),
    login: LoginScreen(),
    signUp: SignUpScreen(),
    signUpCompany: SignUpCompanyScreen(),
    signUpStudent: SignUpStudentScreen(),
    home: HomeScreen(),
  };

  static final routes = <String, WidgetBuilder>{};
}

getRoute(name) {
  return Routes._route[name] ?? HomeScreen();
}
