import 'package:boilerplate/core/data/network/dio/configs/dio_configs.dart';
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:boilerplate/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:workmanager/workmanager.dart';

class WorkMangerHelper {
  static final WorkMangerHelper _singleton = WorkMangerHelper._internal();

  factory WorkMangerHelper() {
    return _singleton;
  }

  static const DioConfigs dioConfig = DioConfigs(
    baseUrl: Endpoints.baseUrl,
    connectionTimeout: Endpoints.connectionTimeout,
    receiveTimeout: Endpoints.receiveTimeout,
  );

  static late final SharedPreferences _sharedPreferences;
  static final DioClient _dioClient = _initializeDioClient();
  // static final ProjectApi _projectApi = _initializeProjectApi();

  WorkMangerHelper._internal() {
    SharedPreferences.getInstance().then((prefs) {
      _sharedPreferences = prefs;
    });
  }

  static DioClient _initializeDioClient() {
    getIt.registerFactory( () => DioClient(dioConfigs: WorkMangerHelper.dioConfig)
      ..addInterceptors([
        AuthInterceptor(accessToken: () async {
          return WorkMangerHelper._sharedPreferences
              .getString(Preferences.auth_token);
        }),
        LoggingInterceptor(),
      ]));
    return getIt<DioClient>();
  }

  // static ProjectApi _initializeProjectApi() {
  //   return ProjectApi(WorkMangerHelper._dioClient);
  // }

  // frequency
  static const Duration LOW_FREQUENCY = Duration(minutes: 120);
  static const Duration MEDIUM_FREQUENCY = Duration(minutes: 30);
  static const Duration NORMAL_FREQUENCY = Duration(minutes: 15);
  static const Duration HIGH_FREQUENCY = Duration(minutes: 5);

  // delay
  static const Duration SHORT_DELAY = Duration(seconds: 3);
  static const Duration LONG_DELAY = Duration(minutes: 30);
  static const Duration NO_DELAY = Duration(seconds: 0);

  static registerProfileFetch() async {
    if (kIsWeb) return;
    Workmanager().registerPeriodicTask(
      WorkerTask.fetchProfile.identifier,
      WorkerTask.fetchProfile.name,
      tag: WorkerTask.fetchProfile.identifier,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: SHORT_DELAY,
      frequency: LOW_FREQUENCY,
      backoffPolicy: BackoffPolicy.exponential,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static registerNotificationFetch() async {
    if (kIsWeb) return;
    Workmanager().registerPeriodicTask(
      WorkerTask.fetchNotification.identifier,
      WorkerTask.fetchNotification.name,
      tag: WorkerTask.fetchNotification.identifier,
      existingWorkPolicy: ExistingWorkPolicy.update,
      initialDelay: NORMAL_FREQUENCY,
      frequency: NORMAL_FREQUENCY,
      backoffPolicy: BackoffPolicy.exponential,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  // static registerProjectFetch() async {
  //   Workmanager().registerPeriodicTask(
  //     WorkerTask.fetchProject.identifier,
  //     WorkerTask.fetchProject.name + const Uuid().v4(),
  //     existingWorkPolicy: ExistingWorkPolicy.replace,
  //     initialDelay: SHORT_DELAY,
  //     // frequency: NORMAL_FREQUENCY,
  //     backoffPolicy: BackoffPolicy.exponential,
  //     constraints: Constraints(
  //         requiresDeviceIdle: true, networkType: NetworkType.connected),
  //   );
  // }

  Future<List<NotificationObject>> fetchRecentNotification() async {
    return [
      NotificationObject(
          type: NotificationType.text,
          id: "",
          receiver: StudentProfile(objectId: "", fullName: "student 1"),
          sender: CompanyProfile(
            objectId: "",
            companyName: "company 1",
          ),
          content: 'You have submitted to join project "Javis - AI Copilot',
          createdAt: DateTime.now()),
      NotificationObject(
          id: "",
          receiver: StudentProfile(objectId: "", fullName: "student 1"),
          sender: CompanyProfile(
            objectId: "",
            companyName: "company 1",
          ),
          type: NotificationType.joinInterview,
          content:
              'You have invited to interview for project "Javis - AI Copilot" at 14:00 March 20, Thursday',
          createdAt: DateTime.now().subtract(const Duration(days: 7))),
      OfferNotification(
          projectId: "",
          id: "",
          receiver: StudentProfile(objectId: "", fullName: "student 1"),
          sender: CompanyProfile(
            objectId: "",
            companyName: "company 1",
          ),
          content: 'You have submitted to join project "Javis - AI Copilot',
          createdAt: DateTime.now()),
      NotificationObject(
          type: NotificationType.message,
          id: "",
          receiver: StudentProfile(objectId: "", fullName: "student 1"),
          sender: CompanyProfile(
            objectId: "",
            companyName: "Alex Jor",
          ),
          content:
              'I have read your requirement but I dont seem to...?\n6/6/2024',
          createdAt: DateTime.now()),
      NotificationObject(
          type: NotificationType.message,
          id: "",
          receiver: StudentProfile(objectId: "", fullName: "student 1"),
          sender: CompanyProfile(
            objectId: "",
            companyName: "Alex Jor",
          ),
          content: 'Finish your project?',
          createdAt: DateTime.now()),
      NotificationObject(
          type: NotificationType.message,
          id: "",
          receiver: StudentProfile(objectId: "", fullName: "student 1"),
          sender: CompanyProfile(
            objectId: "",
            companyName: "Alex Jor",
          ),
          content: 'How are you doing?',
          createdAt: DateTime.now()),
      OfferNotification(
          projectId: "",
          id: "",
          receiver: StudentProfile(objectId: "", fullName: "student 1"),
          sender: CompanyProfile(
            objectId: "",
            companyName: "company 1",
          ),
          content: 'You have an offer to join project "HCMUS - Administration"',
          createdAt: DateTime.now()),
      OfferNotification(
          projectId: "",
          id: "",
          receiver: StudentProfile(objectId: "", fullName: "student 1"),
          sender: CompanyProfile(
            objectId: "",
            companyName: "company 1",
          ),
          content: 'You have an offer to join project "Quantum Physics"',
          createdAt: DateTime.now()),
    ];
  }

  Future<bool> fetchProfile() async {
    try {
      var response = await WorkMangerHelper._dioClient.dio
          .get(Endpoints.getProfile)
          .onError((exception, stackTrace) {
        print("$exception \n$stackTrace");
        return Response(
          requestOptions: RequestOptions(data: "$exception \n$stackTrace"),
          statusCode: 400,
        );
      });
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        var studentData = response.data["result"]["student"];
        StudentProfile? studentProfile;
        if (studentData != null) {
          studentProfile = StudentProfile.fromMap(studentData);
        } else {
          studentProfile = null;
        }

        var companyData = response.data["result"]["company"];
        CompanyProfile? companyProfile;

        if (companyData != null) {
          companyProfile = CompanyProfile.fromMap(companyData);
        } else {
          companyProfile = null;
        }

        if (companyProfile != null) {
          await _sharedPreferences.setString(
              Preferences.company_profile, companyProfile.toJson());
        }
        if (studentProfile != null) {
          await _sharedPreferences.setString(
              Preferences.student_profile, studentProfile.toJson());
        }

        print("fetch ${response.data}");

        return Future.value(true);
      } else {
        print("fetch error ${response.data.toString()}");
        return Future.value(false);
      }
    } catch (e) {
      print("fetch error $e");
      return Future.value(false);
    }
  }
}

enum WorkerTask {
  fetchProfile("periodic-profile-fetch", "profileFetchTask"),
  // fetchProject("periodic-project-fetch", "projectFetchTask"),
  purgeProjectsData("periodic-projects-purge", "purgeProjectsTask"),
  fetchNotification("periodic-notification-fetch", "notificationFetchTask"),
  defaultTask("simple-identifier", 'simpleTask');

  const WorkerTask(this.identifier, this.name);
  final String identifier;
  final String name;
}

WorkerTask getWorkerTaskFromString(String task) {
  switch (task) {
    case "profileFetchTask":
      return WorkerTask.fetchProfile;
    // case "projectFetchTask":
    //   return WorkerTask.fetchProject;
    case "purgeProjectsTask":
      return WorkerTask.purgeProjectsData;
    case "notificationFetchTask":
      return WorkerTask.fetchNotification;
    default:
      return WorkerTask.defaultTask;
  }
}
