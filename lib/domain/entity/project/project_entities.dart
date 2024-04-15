// ignore_for_file: overridden_fields

import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:json_annotation/json_annotation.dart';

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
  bool doneLoading = false;
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
  Status enabled;
  bool isFavorite;

  ProjectBase(
      {this.isLoading = true,
      this.doneLoading = false,
      required this.title,
      required this.description,
      this.scope = Scope.short,
      String id = "",
      this.enabled = Status.active,
      this.isFavorite = false,
      super.createdAt,
      super.updatedAt})
      : super(objectId: id);

  @override
  bool isLoading;

  @override
  bool doneLoading;
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
  List<Proposal>? hired;
  List<Proposal>? proposal;
  List<Proposal>? messages;
  DateTime timeCreated = DateTime.now();
  bool get isWorking => enabled == Status.active;
  bool get isArchived => enabled == Status.inactive;
  String companyId;

  int? _countProposals;
  int? _countMessages;
  int? _countHired;

  int get countProposals => _countProposals ?? proposal?.length ?? 0;
  int get countMessages => _countMessages ?? messages?.length ?? 0;
  int get countHired => _countHired ?? hired?.length ?? 0;

  Project({
    required super.title,
    required super.description,
    super.scope = Scope.short,
    this.numberOfStudents = 1,
    this.hired,
    this.proposal,
    this.messages,
    required this.timeCreated,
    super.updatedAt,
    super.isFavorite = false,
    super.enabled,
    super.id,
    this.companyId = "",
    countProposals,
    countMessages,
    countHired,
  }) {
    if (countProposals != null) {
      _countProposals = countProposals;
      if (proposal != null) assert(_countProposals == proposal!.length);
    }
    if (countMessages != null) {
      _countHired = countHired;
      if (hired != null) assert(_countHired == hired!.length);
    }
    if (countHired != null) {
      _countMessages = countMessages;
      if (messages != null) assert(_countMessages == messages!.length);
    }
  }

  @Deprecated("Use timeago instead")
  getModifiedTimeCreated() {
    return timeCreated.difference(DateTime.now()).inDays.abs();
  }

  factory Project.fromMap(Map<String, dynamic> json, {fav = false}) {
    // var proprosal = json['proposals'];
    // var real;
    // if (proprosal is String) {
    //   real = jsonDecode(proprosal);
    // } else {
    //   real = json['proposals'];
    // }
    return Project(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        timeCreated: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
                : DateTime.now(),
        scope: Scope.values[json['projectScopeFlag'] ?? 0],
        numberOfStudents: json['numberOfStudents'] ?? 1,
        id: (json["projectId"] ?? json["id"] ?? "").toString(),
        proposal: (json['proposals'] != null)
            ? List<Proposal>.from((json['proposals'] as List<dynamic>)
                .map((e) => Proposal.fromJson(e as Map<String, dynamic>)))
            : null,
        companyId: json["companyId"] ?? "",
        countProposals: json["countProposals"],
        countMessages: json["countMessages"],
        countHired: json["countHired"],
        enabled: Status.values[json["typeFlag"] ?? 0],
        isFavorite: fav);
  }

  Map<String, dynamic> toJson() {
    return {
      "companyId": companyId,
      "projectScopeFlag": scope.index,
      "title": title,
      "description": description,
      "typeFlag": enabled == Status.active ? 0 : 1,
      "countHired": countHired,
      "countMessages": countMessages,
      "countProposals": countProposals,
      "id": objectId,
      "isArchived": isArchived,
      "isWorking": isWorking,
      "numberOfStudents": numberOfStudents,
      "scope": scope.index,
      "createdAt": timeCreated.toString(),
      "proposals": proposal,
      "updatedAt": updatedAt.toString(),
      "isFavorite": isFavorite,
    };
  }

  @override
  String toString() {
    return "\ncompanyId: $companyId\nid: $objectId\ntitle: $title \ndescription: $description";
  }
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
  // DateTime submittedTime;
  // int numberOfStudents;
  String projectId;

  @Deprecated("Use timeago instead")
  getModifiedSubmittedTime() {
    return timeCreated.difference(DateTime.now()).inDays.abs();
  }

  StudentProject({
    required super.title,
    required super.description,
    required super.timeCreated,
    super.scope = Scope.short,
    super.numberOfStudents = 1,
    // required super.timeCreated,
    super.isFavorite = false,
    this.isSubmitted = true,
    this.isAccepted = false,
    super.id,
    super.enabled,
    super.updatedAt,
    this.projectId = "",
  });

  factory StudentProject.fromMap(Map<String, dynamic> json) {
    return StudentProject(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
         timeCreated: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
                : DateTime.now(),
        scope: Scope.values[json['projectScopeFlag'] ?? 0],
        numberOfStudents: json['numberOfStudents'] ?? 0,
        id: (json["id"] ?? "").toString(),
        projectId: (json["projectId"] ?? "").toString(),
        enabled: Status.values[json["typeFlag"] ?? 0],);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "projectId": projectId,
    };
  }

  @override
  String toString() {
    return "\ncompanyId: $projectId\nid: $objectId";
  }
}

// ------------------- PROPOSAL ------------------------------

enum HireStatus { pending, offer, hired, notHired }

extension HireStatusTitle on HireStatus {
  String get title {
    switch (this) {
      case HireStatus.pending:
        return 'Hired after sent';
      case HireStatus.hired:
        return 'Hired';
      case HireStatus.offer:
        return 'Offered';
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
  HireStatus hiredStatus;
  Status status;
  bool get isHired => hiredStatus == HireStatus.hired;
  String projectId;
  bool enabled;
  StudentProject? project;

  Proposal.fromJson(Map<String, dynamic> json)
      :
        // student = StudentProfile.fromJson(json["student"] ?? ""),
        student = StudentProfile(
            objectId: json["studentId"].toString(),
            fullName: "Sample Student ${json["studentId"]}"),
        coverLetter = json["coverLetter"] ?? "",
        status = Status.values[json["statusFlag"] ?? 0],
        hiredStatus = HireStatus.values[json["hiredStatus"] ?? 0],
        projectId = json["projectId"].toString(),
        enabled = json["disableFlag"] != 0,
        project = json["project"] != null
            ? StudentProject.fromMap(json["project"])
            : null,
        super(
            objectId: json["id"].toString(),
            createdAt: json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
                : DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      "id": objectId,
      "coverLetter": coverLetter,
      "hiredStatus": hiredStatus.index,
      "student": student,
      "disableFlag": enabled ? 0 : 1,
      "projectId": projectId,
      "statusFlag": status.index,
      "project": project,
      "createdAt": createdAt.toString(),
    };
  }

  Proposal({
    required this.project,
    required this.student,
    this.coverLetter = "",
    this.hiredStatus = HireStatus.pending,
    this.status = Status.inactive,
    this.projectId = "",
    this.enabled = true,
    String id = "",
  }) : super(objectId: id);
}
