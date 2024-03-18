import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/dashboard.dart';
import 'package:boilerplate/presentation/dashboard/project_details.dart';
import 'package:boilerplate/presentation/dashboard/favorite_project.dart';
import 'package:boilerplate/presentation/dashboard/project_post/project_post.dart';
import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/home/splashscreen.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/welcome/welcome.dart';
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
  Routes._();

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
  static const String welcome = '/welcome';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String profileStep2 = '/profile-step2';
  static const String setting = '/settings';
  static const String projectDetails = '/projectDetails';
  static const String project_post = '/project-post';
  static const String favortie_project = "/favortie-project";

  static final _route = <String, Widget>{
    splash: const SplashScreen(),
    login: const LoginScreen(),
    signUp: const SignUpScreen(),
    setting: const SettingScreen(),
    profile: const ProfileScreen(),
    profileStep2: ProfileStep2Screen(),
    signUpCompany: const SignUpCompanyScreen(),
    signUpStudent: const SignUpStudentScreen(),
    home: const HomeScreen(),
    welcome: const WelcomeScreen(),
    dashboard: const DashBoardScreen(),
    profileStudent: ProfileStudentScreen(),
    profileStudentStep2: const ProfileStudentStep2Screen(),
    profileStudentStep3: const ProfileStudentStep3Screen(),
    projectDetails: const Placeholder(),
    project_post: const ProjectPostScreen(),
    favortie_project: const FavoriteScreen(),
  };

  static final routes = <String, WidgetBuilder>{
    for (var entry in _route.entries)
      entry.key: (_) {
        if (entry.key == projectDetails) {
          // If route is projectDetails, return ProjectDetailsPage with arguments
          final Project project =
              ModalRoute.of(_)?.settings.arguments as Project;
          return ProjectDetailsPage(project: project);
        } else {
          return entry.value;
        }
      }
  };
}

getRoute(name) {
  return Routes._route[name] ?? const HomeScreen();
}
