import 'package:boilerplate/core/data/network/dio/configs/dio_configs.dart';
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:boilerplate/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:boilerplate/data/network/apis/user/user_api.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:workmanager/workmanager.dart';

class WorkMangerHelper {
  static final WorkMangerHelper _singleton = WorkMangerHelper._internal();

  factory WorkMangerHelper() {
    return _singleton;
  }

  final DioConfigs dioConfig = const DioConfigs(
    baseUrl: Endpoints.baseUrl,
    connectionTimeout: Endpoints.connectionTimeout,
    receiveTimeout: Endpoints.receiveTimeout,
  );

  static late final SharedPreferences _sharedPreferences;
  static final DioClient _dioClient = _initializeDioClient();
  static final UserApi _userApi = _initializeUserApi();

  WorkMangerHelper._internal(){
     SharedPreferences.getInstance().then((prefs) {
      _sharedPreferences = prefs;
    });
  }

  static DioClient _initializeDioClient() {
    return DioClient(dioConfigs: WorkMangerHelper().dioConfig)
      ..addInterceptors([
        AuthInterceptor(accessToken: () async {
          return WorkMangerHelper
              ._sharedPreferences
              .getString(Preferences.auth_token);
        }),
        LoggingInterceptor(),
      ]);
  }

  static UserApi _initializeUserApi() {
    return UserApi(dioClient: WorkMangerHelper._dioClient);
  }

  // frequency
  static const Duration LOW_FREQUENCY = Duration(minutes: 60);
  static const Duration MEDIUM_FREQUENCY = Duration(minutes: 30);
  static const Duration NORMAL_FREQUENCY = Duration(minutes: 15);
  static const Duration HIGH_FREQUENCY = Duration(minutes: 5);

  // delay
  static const Duration SHORT_DELAY = Duration(seconds: 30);
  static const Duration LONG_DELAY = Duration(minutes: 3);

  static registerProfileFetch() async {
    Workmanager().registerPeriodicTask(
      WorkerTask.fetchProfile.identifier,
      WorkerTask.fetchProfile.name,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: LONG_DELAY,
      frequency: LOW_FREQUENCY,
      backoffPolicy: BackoffPolicy.exponential,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<bool> fetchProfile() async {
    var response = await WorkMangerHelper._userApi.getProfile();
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

      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }
}

enum WorkerTask {
  fetchProfile("periodic-profile-fetch", "profileFetchTask"),
  purgeProjectsData("periodic-projects-purge", "purgeProjectsTask"),
  defaultTask("simple-identifier", 'simpleTask');

  const WorkerTask(this.identifier, this.name);
  final String identifier;
  final String name;
}

WorkerTask getWorkerTaskFromString(String task) {
  switch (task) {
    case "profileFetchTask":
      return WorkerTask.fetchProfile;
    case "purgeProjectsTask":
      return WorkerTask.purgeProjectsData;
    default:
      return WorkerTask.defaultTask;
  }
}
