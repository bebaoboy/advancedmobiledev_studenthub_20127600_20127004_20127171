import 'package:uuid/uuid.dart';

class Skill {
  final String name;
  final String description;
  final String imageUrl;

  const Skill(this.name, this.description, this.imageUrl);

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

// -------------------------------------------------

class Language {
  String name;
  String proficiency;
  bool readOnly = true;
  bool enabled = true;

  Language(this.name, this.proficiency,
      {this.readOnly = true, this.enabled = true});
}

class Education {
  String name;
  String year;
  bool readOnly = true;
  bool enabled = true;

  Education(this.name, this.year, {this.readOnly = true, this.enabled = true});
}

class ProjectExperience {
  String name;
  DateTime? startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime? endDate = DateTime.now();
  String? description = "...";
  String link = "";
  bool readOnly = true;
  bool enabled = true;
  List<String>? skills = [];

  ProjectExperience(this.name,
      {this.description,
      this.link = "",
      this.startDate,
      this.endDate,
      this.readOnly = true,
      this.enabled = true,
      this.skills});
}

// ----------------
class Student {
  String name;
  String education;
  String introduction;
  int yearOfExperience;
  String title; // job
  String review; // maybe enum

  Student(
      {required this.name,
      required this.education,
      required this.introduction,
      required this.title,
      required this.review,
      this.yearOfExperience = 0});
}

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

class Project implements ShimmerLoadable {
  var id = const Uuid().v4();
  String title;
  String description;
  Scope scope;
  int numberOfStudents;
  List<Student>? hired = List.empty(growable: true);
  List<Student>? proposal = List.empty(growable: true);
  List<Student>? messages = List.empty(growable: true);
  DateTime? timeCreated = DateTime.now();
  bool? isFavorite = false;
  bool? isWorking = false;

  Project(
      {required this.title,
      required this.description,
      this.scope = Scope.short,
      this.numberOfStudents = 1,
      this.hired,
      this.proposal,
      this.messages,
      this.timeCreated,
      this.isFavorite = false,
      this.isLoading = true,
      this.isWorking = false});

  getModifiedTimeCreated() {
    return timeCreated?.difference(DateTime.now()).inDays.abs();
  }
  @override
  bool isLoading;
}

class StudentProject extends Project {

  bool isSubmitted = true;
  bool isAccepted = false;
  DateTime? submittedTime;

  getModifiedSubmittedTime() {
    return submittedTime?.difference(DateTime.now()).inDays.abs();
  }

  StudentProject({
    required super.title,
    required super.description,
    required this.submittedTime,
    super.scope = Scope.short,
    super.numberOfStudents = 1,
    super.timeCreated,
    super.isFavorite = false,
    super.isLoading = true,
    this.isSubmitted = true,
    this.isAccepted = false,
  });
}