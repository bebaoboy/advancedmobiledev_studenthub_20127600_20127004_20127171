// ignore_for_file: overridden_fields

import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

class MyObject {
  String? objectId = const Uuid().v4();
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  DateTime deletedAt = DateTime.now();
  MyObject({this.objectId}) {
    objectId ??= const Uuid().v4();
  }
}

// ------------------- STUDENT PROFILE ------------------------------
@JsonSerializable()
class TechStack extends MyObject {
  final String name;
  TechStack(
    this.name, {
    String id = "",
  }) : super(objectId: id);

  @override
  String toString() {
    return name;
  }

  TechStack.fromJson(Map<String, dynamic> json)
      : name = json["name"] ?? "",
        super(objectId: json["id"].toString());

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": objectId,
    };
  }
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
    String id = "",
  }) : super(objectId: id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }

  Skill.fromJson(Map<String, dynamic> json)
      : name = json["name"] ?? "",
        description = json["id"],
        imageUrl = "";

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(map['name'] ?? '', map['id'].toString(), map['imageUrl'] ?? '',
        id: map['id'].toString());
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": objectId,
    };
  }
}

@JsonSerializable()
class Language extends MyObject {
  String languageName;
  String level;
  bool readOnly = true;
  bool enabled = true;

  Language(
    this.languageName,
    this.level, {
    this.readOnly = true,
    this.enabled = true,
    String id = "",
  }) : super(objectId: id);

  Language.fromJson(Map<String, dynamic> json)
      : languageName = json["languageName"] ?? "",
        level = json['level'] ?? "",
        super(objectId: json["id"]);

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(map['languageName'] ?? '', map['level'] ?? '',
        id: map['id'].toString());
  }

  Map<String, dynamic> toJson() {
    return {
      "languageName": languageName,
      "level": level,
      if (objectId != "") "id": int.tryParse(objectId!),
    };
  }
}

@JsonSerializable()
class Education extends MyObject {
  String schoolName;
  String year() {
    return "${startYear.year} - ${endYear.year}";
  }

  DateTime startYear = DateTime.now().subtract(const Duration(days: 365));
  DateTime endYear = DateTime.now();
  bool readOnly = true;
  bool enabled = true;

  Education(
    this.schoolName, {
    this.readOnly = true,
    this.enabled = true,
    required this.startYear,
    required this.endYear,
    String id = "",
  }) : super(objectId: id);

  Education.fromJson(Map<String, dynamic> json)
      : schoolName = json["schoolName"] ?? "",
        startYear = json["startYear"] ?? "",
        endYear = json["endYear"] ?? "",
        super(objectId: json["id"]);

  Map<String, dynamic> toJson() {
    return {
      "schoolName": schoolName,
      "startYear": startYear.toString(),
      "endYear": endYear.toString(),
      if (objectId != "") "id": int.tryParse(objectId!),
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(map['schoolName'] ?? '',
        startYear: DateTime.parse(map['startYear']),
        endYear: DateTime.parse(map['endYear']),
        id: map['id'].toString());
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

  ProjectExperience(
    this.name, {
    this.description = "...",
    this.link = "",
    required this.startDate,
    required this.endDate,
    this.readOnly = true,
    this.enabled = true,
    this.skills,
    String id = "",
  }) : super(objectId: id);

  ProjectExperience.fromJson(Map<String, dynamic> json)
      : description = json["description"] ?? "",
        link = json["link"] ?? "",
        startDate = json["startMonth"] ?? "",
        endDate = json["endMonth"] ?? "",
        skills = json["skills"] as List<Skill>,
        name = json["title"] ?? '',
        super(objectId: json['id']);

  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "title": name,
      "startMonth": startDate.toString(),
      "endMonth": endDate.toString(),
      "skillSets": skills == null
          ? ["1"]
          : skills!.isEmpty
              ? ["1"]
              : skills!.map((e) => e.objectId).toList(),
      if (objectId != "") "id": int.tryParse(objectId!),
    };
  }

  factory ProjectExperience.fromMap(Map<String, dynamic> map) {
    return ProjectExperience(map['title'] ?? '',
        description: map['description'] ?? '',
        id: map['id'].toString(),
        startDate: DateTime.parse(map['startMonth']),
        endDate: DateTime.parse(map['endMonth']));
  }
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
    required this.id,
    required this.receiver,
    required this.sender,
    required this.type,
    this.content = "",
  }) : super(objectId: id);
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

  InterviewSchedule({
    required this.title,
    this.participants,
    required this.startDate,
    required this.endDate,
    this.isCancel = false,
    String id = "",
  }) : super(objectId: id);

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
        isCancel = json["isCancel"] ?? false,
        super(objectId: json["id"] ?? const Uuid().v4());

  Map<String, dynamic> toJson() => {
        "title": title,
        "startDate": startDate,
        "endDate": endDate,
        "isCancel": isCancel,
      };
}
