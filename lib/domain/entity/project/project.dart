import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

class MyObject {
  String objectId = const Uuid().v4();

  // MyObject({required this.objectId});
}

// ------------------- STUDENT PROFILE ------------------------------
class TechStack extends MyObject {
  final String name;
  TechStack(
    this.name,
    // {
    // super.objectId = "",

    // }
  );
}

class Skill extends MyObject {
  final String name;
  final String description;
  final String imageUrl;

  Skill(
    this.name,
    this.description,
    this.imageUrl,
    // {
    // super.objectId = "",

    // }
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Profile{$name}';
  }
}

class Language extends MyObject {
  String name;
  String proficiency;
  bool readOnly = true;
  bool enabled = true;

  Language(this.name, this.proficiency,
      { // super.objectId = "",
      this.readOnly = true,
      this.enabled = true});
}

class Education extends MyObject {
  String name;
  String year;
  bool readOnly = true;
  bool enabled = true;

  Education(this.name, this.year,
      { // super.objectId = "",
      this.readOnly = true,
      this.enabled = true});
}

class ProjectExperience extends MyObject {
  String name;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime endDate = DateTime.now();
  String description = "";
  String link = "";
  bool readOnly = true;
  bool enabled = true;
  List<String>? skills = [];

  ProjectExperience(this.name,
      { // super.objectId = "",

      this.description = "...",
      this.link = "",
      required this.startDate,
      required this.endDate,
      this.readOnly = true,
      this.enabled = true,
      this.skills});
}

// ------------------- PROFILE ACCOUNT ------------------------------
class UserObject extends MyObject {
  // UserObject({super.objectId = ""});
}

class Student extends UserObject {
  String name;
  // String userId;
  String education;
  String introduction;
  int yearOfExperience;
  String title; // job
  String review; // maybe enum
  List<Skill>? skillSet;
  List<Language>? languages;
  List<Education>? educations;

  Student(
      { // super.objectId = "",

      required this.name,
      required this.education,
      required this.introduction,
      required this.title,
      required this.review,
      this.yearOfExperience = 0,
      this.skillSet});
}

enum CompanyScope { solo, small, medium, large, enterprise }

extension CompanyScopeTitle on CompanyScope {
  String get title {
    switch (this) {
      case CompanyScope.solo:
        return "It's just me";
      case CompanyScope.small:
        return '2-9 employess';
      case CompanyScope.medium:
        return '10-99 employees';
      case CompanyScope.large:
        return '100-1000 employees';
      default:
        return 'More than 1000 employees';
    }
  }
}

class Company extends UserObject {
  String userId;
  String name;
  String email;
  String website;
  String description;
  CompanyScope scope = CompanyScope.solo;

  Company({
    // super.objectId = "",

    required this.userId,
    required this.name,
    required this.email,
    required this.website,
    required this.description,
    this.scope = CompanyScope.solo,
  });
}

//
// ------------------- PROJECT ------------------------------
//
// tight: less 1 month, short: 1-3 months, long: 3-6 months, extended: > 6 months
enum Scope { tight, short, long, extended }

extension ScopeTitle on Scope {
  String get title {
    switch (this) {
      case Scope.tight:
        return 'Less than 1 month';
      case Scope.short:
        return '1 to 3 months';
      case Scope.long:
        return '3 to 6 months';
      default:
        return 'More than 6 months';
    }
  }
}

abstract class ShimmerLoadable {
  bool isLoading = true;
}

///
/// Project class for creating profile.
/// For student, please refer to [StudentProject]
/// For company project, please refer to [Project]
///
class ProjectBase extends MyObject implements ShimmerLoadable {
  String title;
  String description;
  Scope scope;

  ProjectBase({
    // super.objectId = "",

    this.isLoading = true,
    required this.title,
    required this.description,
    this.scope = Scope.short,
  });

  @override
  bool isLoading;
}

///
/// Project class for Company.
/// For student, please refer to [StudentProject]
/// For general project, please refer to [ProjectBase]
///
class Project extends ProjectBase {
  // var id = const Uuid().v4();
  int numberOfStudents;
  List<Student>? hired = List.empty(growable: true);
  List<Student>? proposal = List.empty(growable: true);
  List<Student>? messages = List.empty(growable: true);
  DateTime timeCreated = DateTime.now();
  bool isFavorite = false;
  bool isWorking = false;

  Project(
      { // super.objectId = "",

      required super.title,
      required super.description,
      super.scope = Scope.short,
      this.numberOfStudents = 1,
      this.hired,
      this.proposal,
      this.messages,
      required this.timeCreated,
      this.isFavorite = false,
      this.isLoading = true,
      this.isWorking = false});

  getModifiedTimeCreated() {
    return timeCreated.difference(DateTime.now()).inDays.abs();
  }

  @override
  bool isLoading;
}

///
/// Project class for Student.
/// For student, please refer to [Project]
/// For general project, please refer to [ProjectBase]
///
class StudentProject extends Project {
  bool isSubmitted = true;
  bool isAccepted = false;
  DateTime submittedTime;

  getModifiedSubmittedTime() {
    return submittedTime.difference(DateTime.now()).inDays.abs();
  }

  StudentProject({
    // super.objectId = "",

    required super.title,
    required super.description,
    required this.submittedTime,
    super.scope = Scope.short,
    super.numberOfStudents = 1,
    required super.timeCreated,
    super.isFavorite = false,
    super.isLoading = true,
    this.isSubmitted = true,
    this.isAccepted = false,
  });
}

// ------------------- PROPOSAL ------------------------------

enum HireStatus { notHire, pending, hired }

extension HireStatusTitle on HireStatus {
  String get title {
    switch (this) {
      case HireStatus.pending:
        return 'Hired after sent';
      case HireStatus.hired:
        return 'Hired';
      default:
        return 'Not hired';
    }
  }
}

enum Status { active, inactive }

class Proposal extends MyObject {
  Project project;
  Student student;
  String coverLetter;
  HireStatus isHired;
  Status status;

  Proposal(
      { // super.objectId = "",

      required this.project,
      required this.student,
      required this.coverLetter,
      this.isHired = HireStatus.notHire,
      this.status = Status.inactive});
}

// ------------------- NOTIFICATION ------------------------------

class NotifiedObject extends MyObject {
  String messageId;
  DateTime dateCreated = DateTime.now();

  UserObject receiver;
  UserObject sender;
  String content;

  NotifiedObject({
    // super.objectId = "",

    required this.messageId,
    required this.dateCreated,
    required this.receiver,
    required this.sender,
    this.content = "",
  });
}

enum NotificationType {
  text,
  joinInterview,
  viewOffer,
  message,
}

class Notification extends NotifiedObject {
  NotificationType type;

  Notification({
    // super.objectId = "",

    required super.messageId,
    required super.dateCreated,
    required super.receiver,
    required super.sender,
    super.content = "",
    this.type = NotificationType.text,
  });
}

enum MessageType {
  joinInterview,
  message,
}

class Message extends NotifiedObject {
  MessageType type;
  InterviewSchedule? interviewSchedule;

  Message({
    // super.objectId = "",

    required super.messageId,
    required super.dateCreated,
    required super.receiver,
    required super.sender,
    super.content = "",
    this.type = MessageType.message,
  });
}

@JsonSerializable()
class InterviewSchedule extends MyObject {
  String title;
  List<UserObject>? participants = List.empty(growable: true);
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isCancel = false;

  InterviewSchedule(
      { // super.objectId = "",

      required this.title,
      this.participants,
      required this.startDate,
      required this.endDate,
      this.isCancel = false});

  clear() {
    endDate = DateTime.now();
    startDate = DateTime.now();
    title = "";
  }

  getDuration() {
    return endDate.difference(startDate).inMinutes.toString() + " minutes";
  }

  @override
  String toString() {
    return ("\n${title.toString()}") +
        (",${endDate.toString()}") +
        (", ${startDate.toString()}, ${isCancel}");
  }

  InterviewSchedule.fromJson(Map<String, dynamic> json)
      : title = (json['title'] ?? "Missing Title") as String,
        endDate = json['endDate'] == null
            ? DateTime.now().add(const Duration(hours: 1, minutes: 1))
            : json['endDate'] as DateTime,
        startDate = json["startDate"] == null
            ? DateTime.now()
            : json["startDate"] as DateTime,
        isCancel = json["isCancel"] ?? false;

  Map<String, dynamic> toJson() => {
        "title": title,
        "startDate": startDate,
        "endDate": endDate,
        "isCancel": isCancel,
      };
}
