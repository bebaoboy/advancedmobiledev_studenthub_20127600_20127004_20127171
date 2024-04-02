// ignore_for_file: overridden_fields

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

class MyObject {
  String? objectId = const Uuid().v4();
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  DateTime deletedAt = DateTime.now();
  MyObject({this.objectId}) {
    objectId = const Uuid().v4();
  }
}

// ------------------- STUDENT PROFILE ------------------------------
@JsonSerializable()
class TechStack extends MyObject {
  final String name;
  TechStack(
    this.name, {
    super.objectId,
  });

  TechStack.fromJson(Map<String, dynamic> json) : name = json["name"] ?? "";
}

@JsonSerializable()
class Skill extends MyObject {
  final String name;
  final String description;
  final String imageUrl;

  Skill(
    this.name,
    this.description,
    this.imageUrl, {
    super.objectId,
  });

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

  Skill.fromJson(Map<String, dynamic> json)
      : name = json["name"] ?? "",
        description = "",
        imageUrl = "";

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
        map['name'] ?? '', map['description'] ?? '', map['imageUrl'] ?? '');
  }
}

@JsonSerializable()
class Language extends MyObject {
  String name;
  String proficiency;
  bool readOnly = true;
  bool enabled = true;

  Language(this.name, this.proficiency,
      {super.objectId, this.readOnly = true, this.enabled = true});

  Language.fromJson(Map<String, dynamic> json)
      : name = json["name"] ?? "",
        proficiency = "";

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(map['name'] ?? '', map['proficiency'] ?? '');
  }
}

@JsonSerializable()
class Education extends MyObject {
  String schoolName;
  String year;
  DateTime startYear = DateTime.now().subtract(const Duration(days: 365));
  DateTime endYear = DateTime.now();
  bool readOnly = true;
  bool enabled = true;

  Education(this.schoolName, this.year,
      {super.objectId,
      this.readOnly = true,
      this.enabled = true,
      required this.startYear,
      required this.endYear});

  Education.fromJson(Map<String, dynamic> json)
      : schoolName = json["schoolName"] ?? "",
        year = json["year"] ?? "",
        startYear = json["startYear"] ?? "",
        endYear = json["endYear"] ?? "";

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(map['schoolName'] ?? '', map['year'] ?? '',
        startYear: map['startYear'] ?? '', endYear: map['endYear'] ?? '');
  }
}

@JsonSerializable()
class ProjectExperience extends MyObject {
  String name;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime endDate = DateTime.now();
  String description = "";
  String link = "";
  bool readOnly = true;
  bool enabled = true;
  List<Skill>? skills = [];

  ProjectExperience(this.name,
      {super.objectId,
      this.description = "...",
      this.link = "",
      required this.startDate,
      required this.endDate,
      this.readOnly = true,
      this.enabled = true,
      this.skills});

  ProjectExperience.fromJson(Map<String, dynamic> json)
      : description = json["description"] ?? "",
        link = json["link"] ?? "",
        startDate = json["startDate"] ?? "",
        endDate = json["endDate"] ?? "",
        skills = json["skills"] as List<Skill>,
        name = json["name"] ?? '';
}

// ------------------- PROFILE ACCOUNT ------------------------------
@JsonSerializable()
class Profile extends MyObject {
  Profile({super.objectId});

  Profile.fromJson(Map<String, dynamic> json);
}

@JsonSerializable()
class StudentProfile extends Profile {
  int id;
  String fullName;
  // String userId;
  String education;
  String introduction;
  int yearOfExperience;
  String title; // job
  String review; // maybe enum
  List<TechStack>? techStack;
  List<Skill>? skillSet;
  List<Language>? languages;
  List<Education>? educations;
  String? transcript = "";
  String? resume = "";

  StudentProfile({
    super.objectId,
    required this.fullName,
    required this.education,
    required this.introduction,
    required this.title,
    required this.review,
    required this.id,
    this.yearOfExperience = 0,
    this.skillSet,
    this.educations,
    this.techStack,
    this.transcript,
    this.languages,
    this.resume,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fullName': fullName,
      'education': education,
      'introduction': introduction,
      'yearOfExperience': yearOfExperience,
      'review': review,
      'techStack': techStack,
      'skillSet': skillSet,
      'languages': languages,
      'educations': educations,
      'transcript': transcript,
      'resume': resume,
    };
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      fullName: map['fullName'] ?? '',
      education: map['education'] ?? '',
      introduction: map['introduction'] ?? '',
      yearOfExperience: map['yearOfExperience'] ?? 0,
      review: map['review'] ?? '',
      techStack: map['techStack'],
      skillSet: (map['skillSet'] != null)
          ? List<Skill>.from((map['skillSet'] as List<dynamic>)
              .map((e) => Skill.fromMap(e as Map<String, dynamic>)))
          : [],
      languages: (map['languages'] != null)
          ? List<Language>.from((map['languages'] as List<dynamic>)
              .map((e) => Language.fromMap(e as Map<String, dynamic>)))
          : [],
      educations: (map['educations'] != null)
          ? List<Education>.from((map['educations'] as List<dynamic>)
              .map((e) => Education.fromMap(e as Map<String, dynamic>)))
          : [],
      transcript: map['transcript'] ?? '',
      resume: map['resume'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StudentProfile.fromJson(String source) =>
      StudentProfile.fromMap(json.decode(source));
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

@JsonSerializable()
class CompanyProfile extends Profile {
  // String userId;
  String profileName;
  String companyName;
  String email;
  String website;
  String description;
  CompanyScope scope = CompanyScope.solo;

  CompanyProfile({
    super.objectId,
    // required this.userId,
    required this.companyName,
    required this.profileName,
    required this.email,
    required this.website,
    required this.description,
    this.scope = CompanyScope.solo,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileName': profileName,
      'companyName': companyName,
      'email': email,
      'website': website,
      'description': description,
      'scope': scope,
    };
  }

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      profileName: map['profileName'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      description: map['description'] ?? '',
      scope: CompanyScope.values[map['size'] ?? 0],
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyProfile.fromJson(String source) =>
      CompanyProfile.fromMap(json.decode(source));
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
@JsonSerializable()
class ProjectBase extends MyObject implements ShimmerLoadable {
  String title;
  String description;
  Scope scope;

  ProjectBase({
    super.objectId,
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
@JsonSerializable()
class Project extends ProjectBase {
  // var id = const Uuid().v4();
  int numberOfStudents;
  List<Proposal>? hired = List.empty(growable: true);
  List<Proposal>? proposal = List.empty(growable: true);
  List<Proposal>? messages = List.empty(growable: true);
  DateTime timeCreated = DateTime.now();
  bool isFavorite = false;
  bool isWorking = false;
  bool isArchived = false;

  Project(
      {super.objectId,
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
@JsonSerializable()
class StudentProject extends Project {
  bool isSubmitted = true;
  bool isAccepted = false;
  DateTime submittedTime;

  getModifiedSubmittedTime() {
    return submittedTime.difference(DateTime.now()).inDays.abs();
  }

  StudentProject({
    super.objectId,
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

@JsonSerializable()
class Proposal extends MyObject {
  // Project project;
  StudentProfile student;
  String coverLetter;
  HireStatus isHired;
  Status status;

  Proposal(
      {super.objectId,
      // required this.project,
      required this.student,
      this.coverLetter = "",
      this.isHired = HireStatus.notHire,
      this.status = Status.inactive});

  Proposal.fromJson(Map<String, dynamic> json)
      : student = StudentProfile.fromJson(json["student"] ?? ""),
        coverLetter = json["coverLetter"] ?? "",
        status = Status.values[json["status"] ?? 0],
        isHired = HireStatus.values[json["isHired"] ?? 0];
}

// ------------------- NOTIFICATION ------------------------------

@JsonSerializable()
class Notification extends MyObject {
  String id;
  Profile receiver;
  Profile sender;
  String content;
  NotificationType type;

  Notification({
    super.objectId,
    required this.id,
    required this.receiver,
    required this.sender,
    required this.type,
    this.content = "",
  });

  Notification.fromJson(Map<String, dynamic> json)
      : id = json["id"] ?? "",
        receiver = Profile.fromJson(json['receiver'] ?? ''),
        sender = Profile.fromJson(json["sender"] ?? ''),
        content = json['content'] ?? '',
        type = NotificationType.values[json['type'] ?? 0];
}

enum NotificationType {
  text,
  joinInterview,
  viewOffer,
  message,
}

@JsonSerializable()
class OfferNotification extends Notification {
  String projectId;

  OfferNotification({
    super.objectId,
    required this.projectId,
    required super.id,
    required super.receiver,
    required super.sender,
    super.content = "",
    super.type = NotificationType.text,
  });
}

enum MessageType {
  joinInterview,
  message,
}

@JsonSerializable()
class Message extends Notification {
  MessageType messageType;
  InterviewSchedule? interviewSchedule;

  Message({
    super.objectId,
    required super.id,
    required super.receiver,
    required super.sender,
    super.content = "",
    super.type = NotificationType.message,
    this.messageType = MessageType.message,
  });
}

@JsonSerializable()
class InterviewSchedule extends MyObject {
  String title;
  List<Profile>? participants = List.empty(growable: true);
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isCancel = false;

  InterviewSchedule(
      {super.objectId,
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
    return "${endDate.difference(startDate).inMinutes} minutes";
  }

  @override
  String toString() {
    return ("\n${title.toString()}") +
        (",${endDate.toString()}") +
        (", ${startDate.toString()}, $isCancel");
  }

  InterviewSchedule.fromJson(Map<String, dynamic> json)
      : participants = json['participants'] ?? [],
        title = (json['title'] ?? "Missing Title") as String,
        endDate = json['endDate'] == null
            ? DateTime.now().add(const Duration(hours: 1, minutes: 1))
            : json['endDate'] as DateTime,
        startDate = json["startDate"] == null
            ? DateTime.now()
            : json["startDate"] as DateTime,
        isCancel = bool.tryParse(json["isCancel"] ?? "false") ?? false,
        super(objectId: "");

  Map<String, dynamic> toJson() => {
        "title": title,
        "startDate": startDate,
        "endDate": endDate,
        "isCancel": isCancel,
      };
}
