import 'package:boilerplate/core/data/network/dio/configs/dio_configs.dart';
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:boilerplate/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:interpolator/interpolator.dart';
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

  static final DioClient _dioClient = _initializeDioClient();

  WorkMangerHelper._internal();

  static DioClient _initializeDioClient() {
    getIt
        .registerFactory(() => DioClient(dioConfigs: WorkMangerHelper.dioConfig)
          ..addInterceptors([
            AuthInterceptor(accessToken: () async {
              return (await SharedPreferences.getInstance())
                  .getString(Preferences.auth_token);
            }),
            LoggingInterceptor(),
          ]));
    return getIt<DioClient>();
  }

  // frequency
  static const Duration LOW_FREQUENCY = Duration(minutes: 120);
  static const Duration MEDIUM_FREQUENCY = Duration(minutes: 30);
  static const Duration NORMAL_FREQUENCY = Duration(minutes: 15);
  static const Duration HIGH_FREQUENCY = Duration(minutes: 5);
  static const Duration SUPER_HIGH_FREQUENCY = Duration(seconds: 10);

  // delay
  static const Duration SHORT_DELAY = Duration(seconds: 10);
  static const Duration MEDIUM_DELAY = Duration(minutes: 3);
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
      initialDelay: NO_DELAY,
      frequency: NORMAL_FREQUENCY,
      backoffPolicy: BackoffPolicy.exponential,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<List<NotificationObject>> fetchRecentNotification() async {
    try {
      var sharePref = await SharedPreferences.getInstance();
      var receiverId = sharePref.get(Preferences.current_user_id) ?? -1;
      int? lastRead = sharePref.getInt(Preferences.lastRead);
      if (lastRead == null) {
        print("no last read ");
        lastRead = DateTime.now().millisecondsSinceEpoch;
      }
      print("last read ${DateTime.fromMillisecondsSinceEpoch(lastRead)}");
      if (receiverId == -1) return [];
      var response = await WorkMangerHelper._dioClient.dio
          .get(Interpolator(Endpoints.getNoti)({"receiverId": receiverId}));

      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        List data = response.data["result"];
        List<NotificationObject> res = List.empty(growable: true);

        for (var element in data) {
          var e = <String, dynamic>{
            ...element,
            'id': element['id'].toString(),
            'title': element["title"].toString(),
            "content": element["content"].toString(),
            'messageContent': element["message"] != null
                ? element["message"]['content'].toString()
                : element["content"].toString(),
            'type': element['typeNotifyFlag'],
            'createdAt': DateTime.parse(element['createdAt']).toLocal(),
            'receiver': {
              "id": element['receiver']['id'].toString(),
              "fullname": element['receiver']['fullname'].toString(),
            },
            'sender': {
              "id": element['sender']['id'].toString(),
              "fullname": element['sender']['fullname'].toString(),
            },
            'projectId': element["message"] != null ? element["message"]["projectId"] : "-1",
            'metadata': (element["message"] != null &&
                    element["message"]["interview"] != null)
                ? <String, dynamic>{
                    ...element["message"]["interview"],
                    "meetingRoom": element["message"]["interview"]
                        ["meetingRoom"]
                  }
                : element["proposal"] != null
                    ? <String, dynamic>{...element["proposal"]}
                    : null,
          };
          // print(e);
          var acm = NotificationObject.fromJson(e);
          // res.add(acm);
          if (lastRead <= acm.createdAt!.toUtc().millisecondsSinceEpoch) {
            res.add(acm);
          }
        }
        await sharePref.setInt(
            Preferences.lastRead, DateTime.now().millisecondsSinceEpoch);
        await sharePref.setStringList(
            "noti",
            res
                .map(
                  (e) => e.toJson(),
                )
                .toList());
        return res;
      } else {
        print("fetch error ${response.data.toString()}");
        return [];
      }
    } catch (e) {
      print("fetch error catch $e");
      return [];
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

//   Future<List<NotificationObject>> fetchRecentNotification() async {
//     return [
//       NotificationObject(
//           type: NotificationType.proposal,
//           id: "",
//           receiver: StudentProfile(objectId: "", fullName: "student 1"),
//           sender: CompanyProfile(
//             objectId: "",
//             companyName: "company 1",
//           ),
//           content: 'You have submitted to join project "Javis - AI Copilot',
//           createdAt: DateTime.now()),
//       NotificationObject(
//           id: "",
//           receiver: StudentProfile(objectId: "", fullName: "student 1"),
//           sender: CompanyProfile(
//             objectId: "",
//             companyName: "company 1",
//           ),
//           type: NotificationType.joinInterview,
//           content:
//               'You have invited to interview for project "Javis - AI Copilot" at 14:00 March 20, Thursday',
//           createdAt: DateTime.now().subtract(const Duration(days: 7))),
//       OfferNotification(
//           projectId: "",
//           id: "",
//           receiver: StudentProfile(objectId: "", fullName: "student 1"),
//           sender: CompanyProfile(
//             objectId: "",
//             companyName: "company 1",
//           ),
//           content: 'You have submitted to join project "Javis - AI Copilot',
//           createdAt: DateTime.now()),
//       NotificationObject(
//           type: NotificationType.message,
//           id: "",
//           receiver: StudentProfile(objectId: "", fullName: "student 1"),
//           sender: CompanyProfile(
//             objectId: "",
//             companyName: "Alex Jor",
//           ),
//           content:
//               'I have read your requirement but I dont seem to...?\n6/6/2024',
//           createdAt: DateTime.now()),
//       NotificationObject(
//           type: NotificationType.message,
//           id: "",
//           receiver: StudentProfile(objectId: "", fullName: "student 1"),
//           sender: CompanyProfile(
//             objectId: "",
//             companyName: "Alex Jor",
//           ),
//           content: 'Finish your project?',
//           createdAt: DateTime.now()),
//       NotificationObject(
//           type: NotificationType.message,
//           id: "",
//           receiver: StudentProfile(objectId: "", fullName: "student 1"),
//           sender: CompanyProfile(
//             objectId: "",
//             companyName: "Alex Jor",
//           ),
//           content: 'How are you doing?',
//           createdAt: DateTime.now()),
//       OfferNotification(
//           projectId: "",
//           id: "",
//           receiver: StudentProfile(objectId: "", fullName: "student 1"),
//           sender: CompanyProfile(
//             objectId: "",
//             companyName: "company 1",
//           ),
//           content: 'You have an offer to join project "HCMUS - Administration"',
//           createdAt: DateTime.now()),
//       OfferNotification(
//           projectId: "",
//           id: "",
//           receiver: StudentProfile(objectId: "", fullName: "student 1"),
//           sender: CompanyProfile(
//             objectId: "",
//             companyName: "company 1",
//           ),
//           content: 'You have an offer to join project "Quantum Physics"',
//           createdAt: DateTime.now()),
//     ];
  }

  static Future<bool> fetchProfile() async {
    try {
      var sharePref = await SharedPreferences.getInstance();
      var response =
          await WorkMangerHelper._dioClient.dio.get(Endpoints.getProfile);
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
          await sharePref.setString(
              Preferences.company_profile, companyProfile.toJson());
        }
        if (studentProfile != null) {
          await sharePref.setString(
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
