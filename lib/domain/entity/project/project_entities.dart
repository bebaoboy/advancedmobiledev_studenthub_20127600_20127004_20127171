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

  ProjectBase({
    this.isLoading = true,
    this.doneLoading = false,
    required this.title,
    required this.description,
    this.scope = Scope.short,
    String id = "",
  }) : super(objectId: id);

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
  List<Proposal>? hired = List.empty(growable: true);
  List<Proposal>? proposal = List.empty(growable: true);
  List<Proposal>? messages = List.empty(growable: true);
  DateTime timeCreated = DateTime.now();
  bool isFavorite = false;
  bool isWorking = false;
  bool isArchived = false;

  Project({
    required super.title,
    required super.description,
    super.scope = Scope.short,
    this.numberOfStudents = 1,
    this.hired,
    this.proposal,
    this.messages,
    required this.timeCreated,
    this.isFavorite = false,
    this.isWorking = false,
    super.id,
  });

  getModifiedTimeCreated() {
    return timeCreated.difference(DateTime.now()).inDays.abs();
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
  DateTime submittedTime;

  getModifiedSubmittedTime() {
    return submittedTime.difference(DateTime.now()).inDays.abs();
  }

  StudentProject({
    required super.title,
    required super.description,
    required this.submittedTime,
    super.scope = Scope.short,
    super.numberOfStudents = 1,
    required super.timeCreated,
    super.isFavorite = false,
    this.isSubmitted = true,
    this.isAccepted = false,
    super.id,
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

  Proposal.fromJson(Map<String, dynamic> json)
      : student = StudentProfile.fromJson(json["student"] ?? ""),
        coverLetter = json["coverLetter"] ?? "",
        status = Status.values[json["status"] ?? 0],
        isHired = HireStatus.values[json["isHired"] ?? 0];
  Proposal({
    // required this.project,
    required this.student,
    this.coverLetter = "",
    this.isHired = HireStatus.notHire,
    this.status = Status.inactive,
    String id = "",
  }) : super(objectId: id);
}