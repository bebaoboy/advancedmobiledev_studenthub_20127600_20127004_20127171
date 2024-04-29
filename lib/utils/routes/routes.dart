import 'package:boilerplate/core/widgets/error_page_widget.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/dashboard.dart';
import 'package:boilerplate/presentation/dashboard/message_screen.dart';
import 'package:boilerplate/presentation/dashboard/project_details.dart';
import 'package:boilerplate/presentation/dashboard/favorite_project.dart';
import 'package:boilerplate/presentation/dashboard/project_details_student.dart';
import 'package:boilerplate/presentation/dashboard/project_post/project_post.dart';
import 'package:boilerplate/presentation/dashboard/project_update/project_update.dart';
import 'package:boilerplate/presentation/dashboard/submit_project_proposal/submit_project_proposal.dart';
import 'package:boilerplate/presentation/dashboard/view_proposal/proposal_swiper.dart';
import 'package:boilerplate/presentation/dashboard/view_proposal/view_student_profile.dart';
import 'package:boilerplate/presentation/dashboard/view_proposal/view_student_profile2.dart';
import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/home/splashscreen.dart';
import 'package:boilerplate/presentation/login/forget_password.dart';
import 'package:boilerplate/presentation/login/forget_password_change_password.dart';
import 'package:boilerplate/presentation/login/forget_password_done.dart';
import 'package:boilerplate/presentation/login/forget_password_sent.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/profile/view_profile_company.dart';
import 'package:boilerplate/presentation/profile/view_profile_student.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_calls.dart';
import 'package:boilerplate/presentation/video_call/preview_meeting.dart';
import 'package:boilerplate/presentation/welcome/welcome.dart';
import 'package:boilerplate/presentation/profile/profile.dart';
import 'package:boilerplate/presentation/profile/profile_student_step2.dart';
import 'package:boilerplate/presentation/profile/profile_student_step3.dart';
import 'package:boilerplate/presentation/setting/setting.dart';
import 'package:boilerplate/presentation/profile/profile_student.dart';
import 'package:boilerplate/presentation/signup/signup.dart';
import 'package:boilerplate/presentation/signup/signup_company.dart';
import 'package:boilerplate/presentation/signup/signup_student.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String signUpCompany = '/signup-company';
  static const String signUpStudent = '/signup-student';
  static const String profileStudent = '/profile-student';
  static const String profileStudentStep2 = '/profile-student-step2';
  static const String profileStudentStep3 = '/profile-student-step3';
  static const String home = '/home';
  static const String welcome = '/welcome';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String viewProfileCompany = '/view-profile-company';
  static const String viewProfileStudent = '/view-profile-student';
  static const String setting = '/settings';
  static const String projectDetails = '/projectDetails';
  static const String projectPost = '/project-post';
  static const String favoriteProject = "/favorite-project";
  static const String projectDetailsStudent = '/projectDetailsStudent';
  static const String forgetPassword = '/forgetPassword';
  static const String forgetPasswordSent = '/forgetPasswordSent';
  static const String forgetPasswordChangePassword =
      '/forgetPasswordChangePassword';
  static const String forgetPasswordDone = '/forgetPasswordDone';
  static const String submitProposal = '/submitProposal';
  static const String message = "/message";
  static const String updateProject = "/updateProject";
  static const String viewProjectProposals = "/viewProjectProposals";
  static const String viewProjectProposalsCard = "/viewProjectProposalsCard";
  static const String companyViewStudentProfile = "/viewStudentProfile";
  static const String companyViewStudentProfile2 = "/viewStudentProfile2";
  static const String previewMeeting = "/previewMeeting";

  static final _route = <String, Widget>{
    splash: const SplashScreen(),
    login: const LoginScreen(),
    signUp: const SignUpScreen(),
    setting: const SettingScreen(),
    profile: const ProfileScreen(),
    viewProfileCompany: const ViewProfileCompany(),
    viewProfileStudent: const ViewProfileStudent(),
    signUpCompany: const SignUpCompanyScreen(),
    signUpStudent: const SignUpStudentScreen(),
    home: const HomeScreen(),
    welcome: const WelcomeScreen(),
    dashboard: const DashBoardScreen(),
    profileStudent: const ProfileStudentScreen(),
    profileStudentStep2: const ProfileStudentStep2Screen(),
    profileStudentStep3: const ProfileStudentStep3Screen(),
    projectDetails: const Placeholder(),
    projectPost: const ProjectPostScreen(),
    favoriteProject: const FavoriteScreen(
      projectList: [],
    ),
    projectDetailsStudent: const Placeholder(),
    forgetPassword: const ForgetPasswordScreen(),
    forgetPasswordSent: const ForgetPasswordSentScreen(),
    forgetPasswordChangePassword: const ForgetPasswordChangePasswordScreen(),
    forgetPasswordDone: const ForgetPasswordDoneScreen(),
    submitProposal: const Placeholder(),
    message: const Placeholder(),
    updateProject: const Placeholder(),
    viewProjectProposalsCard: const Placeholder(),
    viewProjectProposals: const Placeholder(),
    companyViewStudentProfile: const Placeholder(),
    companyViewStudentProfile2: const Placeholder(),
    previewMeeting: const Placeholder(),
  };

  static final routes = <String, WidgetBuilder>{
    // for (var entry in _route.entries)
    //   entry.key: (_) {
    //     if (entry.key == projectDetails) {
    //       // If route is projectDetails, return ProjectDetailsPage with arguments
    //       final Project project =
    //           ModalRoute.of(_)?.settings.arguments as Project;
    //       return ProjectDetailsPage(project: project);
    //     } else {
    //       return entry.value;
    //     }
    //   }
  };
}

getRoute(String name, context, {arguments}) {
  try {
    name = name.split(RegExp('(?=[/])'))[0];
    // print("route = $name, BEBAOBOY");
    log("route = $name, BEBAOBOY");
    if (name == "/") {
      name = Routes.splash;
    }
    if (name.startsWith(Routes.projectDetails)) {
      // If route is projectDetails, return ProjectDetailsPage with arguments
      if (arguments != null) {
        return ProjectDetailsPage(
            project: arguments["project"] as Project,
            initialIndex:
                arguments["index"] != null ? arguments["index"]! as int : null);
      }
    }
    if (name == Routes.submitProposal) {
      if (arguments != null) {
        return SubmitProjectProposal(project: arguments as Project);
      }
    }

    if (name.startsWith(Routes.message)) {
      // If route is projectDetails, return ProjectDetailsPage with arguments
      if (arguments != null) {
        return MessageScreen(chatObject: arguments as WrapMessageList);
      }
    }
    if (name.startsWith(Routes.projectDetailsStudent)) {
      // If route is projectDetails, return ProjectDetailsPage with arguments
      if (arguments != null) {
        return ProjectDetailsStudentScreen(
            project: arguments["project"] as StudentProject);
      }
    }

    if (name == Routes.welcome) {
      if (arguments != null) {
        var b = arguments as bool;
        return WelcomeScreen(
          newRole: b,
        );
      }
    }

    if (name == Routes.updateProject) {
      if (arguments != null) {
        var b = arguments as Project;
        return ProjectUpdateScreen(project: b);
      }
    }

    if (name == Routes.viewProjectProposalsCard) {
      if (arguments != null) {
        var b = arguments as Project;
        return ProposalSwiper(project: b);
      }
    }

    if (name == Routes.companyViewStudentProfile) {
      if (arguments != null) {
        var b = arguments as StudentProfile;
        return ViewStudentProfile(studentProfile: b);
      }
    }

    if (name == Routes.companyViewStudentProfile2) {
      if (arguments != null) {
        var b = arguments as StudentProfile;
        return ViewStudentProfile2(studentProfile: b);
      }
    }

    if (name.startsWith(Routes.previewMeeting)) {
      if (arguments != null) {
        var users = arguments[0] as List<CubeUser>;
        var interviewSchedule = arguments[1] as InterviewSchedule;
        var callSession = arguments[2] as P2PSession;
        return PreviewMeetingScreen(
            CubeSessionManager.instance.activeSession!.user!, callSession,
            interviewSchedule: interviewSchedule,
            users: users
                .where((user) =>
                    user.id !=
                    CubeSessionManager.instance.activeSession!.user!.id)
                .toList());
      }
    }

    // TODO: if name has /suffix, tách cái root name ra, vd: /message/150-34-94
    return Routes._route[name] ??
        ErrorPage(
          errorDetails: FlutterErrorDetails(exception: {
            "summary": Lang.get('404'),
            "stack": "Page: name=$name"
          }),
        );
  } catch (e) {
    return ErrorPage(
        errorDetails: FlutterErrorDetails(exception: {
      "summary": Lang.get('error_text'),
      "stack": e.toString()
    }));
  }
}
