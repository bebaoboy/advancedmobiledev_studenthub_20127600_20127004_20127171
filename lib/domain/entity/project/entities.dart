// ignore_for_file: overridden_fields

import 'dart:convert';

import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

class MyObject {
  String? objectId = const Uuid().v4();
  DateTime? createdAt = DateTime.now();
  DateTime? updatedAt = DateTime.now();
  DateTime? deletedAt = DateTime.now();
  MyObject({this.objectId, this.createdAt, this.updatedAt, this.deletedAt}) {
    objectId ??= const Uuid().v4();
    if (objectId!.isEmpty) objectId = const Uuid().v4();
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
        description = json["id"].toString(),
        imageUrl = "",
        super(objectId: json["id"].toString());

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

  @override
  String toString() {
    return languageName;
  }
}

@JsonSerializable()
class Education extends MyObject {
  String schoolName;
  String year() {
    return "${startYear.year} - ${endYear.year}";
    // return "$startYear - $endYear";
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
        startYear = DateTime(json['startYear'] ?? DateTime.now().year - 1),
        endYear = DateTime(json['endYear'] ?? DateTime.now().year),
        super(objectId: json["id"]);

  Map<String, dynamic> toJson() {
    return {
      "schoolName": schoolName,
      "startYear": startYear.year,
      "endYear": endYear.year,
      if (objectId != "") "id": int.tryParse(objectId!),
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(map['schoolName'] ?? '',
        startYear: DateTime(map['startYear'] ?? DateTime.now().year - 1),
        endYear: DateTime(map['endYear'] ?? DateTime.now().year),
        id: map['id'].toString());
  }

  @override
  String toString() {
    return schoolName;
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
        startDate = DateFormat("MM-yyyy").parse(json['startMonth'] ??
            "${DateTime.now().month}-${DateTime.now().year}"),
        endDate = DateFormat("MM-yyyy").parse(json['endMonth'] ??
            "${DateTime.now().month}-${DateTime.now().year}"),
        skills = json["skillSets"] as List<Skill>,
        name = json["title"] ?? '',
        super(objectId: json['id']);

  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "title": name,
      "startMonth": DateFormat("MM-yyyy").format(startDate),
      "endMonth": DateFormat("MM-yyyy").format(endDate),
      "skillSets": skills == null
          ? ["1"]
          : skills!.isEmpty
              ? ["1"]
              : skills!.map((e) => e.objectId).toList(),
      if (objectId != "") "id": int.tryParse(objectId!),
    };
  }

  @override
  String toString() {
    return name;
  }

  factory ProjectExperience.fromMap(Map<String, dynamic> map) {
    return ProjectExperience(map['title'] ?? '',
        description: map['description'] ?? '',
        id: map['id'].toString(),
        skills: (map['skillSets'] != null)
            ? List<Skill>.from((map['skillSets'] as List<dynamic>).map((e) =>
                e is String
                    ? Skill(e, "", "", id: "")
                    : Skill.fromJson(e as Map<String, dynamic>)))
            : [],
        startDate: DateFormat("MM-yyyy").parse(map['startMonth'] ??
            "${DateTime.now().month}-${DateTime.now().year}"),
        endDate: DateFormat("MM-yyyy").parse(map['endMonth'] ??
            "${DateTime.now().month}-${DateTime.now().year}"));
  }
}

// ------------------- NOTIFICATION ------------------------------

@JsonSerializable()

/// Our class
class NotificationObject extends MyObject {
  String id;
  Profile receiver;
  Profile sender;
  String content;
  NotificationType get type => _type ?? NotificationType.text;
  NotificationType? _type;

  NotificationObject({
    required this.id,
    required this.receiver,
    required this.sender,
    required NotificationType type,
    super.createdAt,
    super.updatedAt,
    this.content = "",
  }) : super(objectId: id) {
    _type = type;
  }
  NotificationObject.fromJson(Map<String, dynamic> json)
      : id = json["id"] ?? "",
        receiver = Profile.fromJson(json['receiver'] ?? ''),
        sender = Profile.fromJson(json["sender"] ?? ''),
        content = json['content'] ?? '',
        _type = NotificationType.values[json['type'] ?? 0];
}

enum NotificationType {
  text,
  joinInterview,
  viewOffer,
  message,
}

@JsonSerializable()
class OfferNotification extends NotificationObject {
  String projectId;

  OfferNotification({
    required this.projectId,
    required super.id,
    required super.receiver,
    required super.sender,
    super.createdAt,
    super.content = "",
  }) : super(type: NotificationType.viewOffer);
}

enum MessageType {
  joinInterview,
  message,
}

@JsonSerializable()

/// Our class
class MessageObject extends NotificationObject {
  MessageType messageType;
  InterviewSchedule? interviewSchedule;

  MessageObject({
    required super.id,
    required super.receiver,
    required super.sender,
    super.content = "",
    super.type = NotificationType.message,
    this.messageType = MessageType.message,
    this.interviewSchedule,
    super.createdAt,
    super.updatedAt,
    this.project,
  });

  Project? project;

  MessageObject.fromJson(Map<String, dynamic> json2)
      : messageType = MessageType.values[json2["type"] ?? 0],
        interviewSchedule = json2["interview"] != null
            ? InterviewSchedule.fromJsonApi(json2["interview"])
            : null,
        project = json2["projectId"] != null
            ? Project.fromMap(json2["projectId"])
            : null,
        super(
            content: json2["content"] ?? "Null",
            createdAt: DateTime.tryParse(json2["createdAt"]) ?? DateTime.now(),
            updatedAt: DateTime.tryParse(
                    json2["updatedAt"] ?? json2["createdAt"] ?? "") ??
                DateTime.now(),
            id: json2["id"].toString(),
            receiver: Profile.fromJson(
                json2["receiver"] != null && json2["receiver"] is String
                    ? json.decode(json2["receiver"])
                    : json2["receiver"]),
            sender: Profile.fromJson(
                json2["sender"] != null && json2["sender"] is String
                    ? json.decode(json2["sender"])
                    : json2["sender"]),
            type: NotificationType.message);

  String toJson() {
    return json.encode({
      "type": messageType.index,
      "id": id,
      "content": content,
      "receiver": receiver.toJson(),
      "sender": sender.toJson(),
      "createdAt": (createdAt ?? DateTime.now()).toString(),
      "updatedAt": (updatedAt ?? createdAt ?? DateTime.now()).toString(),
      "projectId": project?.toJson(),
    });
  }
}

@JsonSerializable()
class InterviewSchedule extends MyObject {
  String title;
  List<Profile>? participants = List.empty(growable: true);
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isCancel = false;
  String meetingRoomId;
  String meetingRoomCode;

  InterviewSchedule({
    required this.title,
    this.participants,
    required this.startDate,
    required this.endDate,
    this.isCancel = false,
    String id = "",
    super.createdAt,
    super.updatedAt,
    this.meetingRoomId = "-1",
    this.meetingRoomCode = "-1",
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
        isCancel = (json["disableFlag"] ?? 0) == 1,
        meetingRoomId = "-1",
        meetingRoomCode = "-1",
        super(objectId: json["id"].toString());

  InterviewSchedule.fromJsonApi(Map<String, dynamic> json)
      : participants = json['participants'] ?? [],
        title = (json['title'] ?? "Missing Title") as String,
        endDate = json['endTime'] == null
            ? DateTime.now().add(const Duration(hours: 1, minutes: 1))
            : json['endTime'] is DateTime
                ? json['endTime']
                : DateTime.tryParse(json['endTime']) ?? DateTime.now(),
        startDate = json["startTime"] == null
            ? DateTime.now()
            : json['startTime'] is DateTime
                ? json['startTime']
                : DateTime.tryParse(json['startTime']) ?? DateTime.now(),
        isCancel = (json["disableFlag"] ?? 0) == 1,
        meetingRoomId =
            (json["meetingRoom"]?["meeting_room_id"] ?? "-1").toString(),
        meetingRoomCode =
            (json["meetingRoom"]?["meeting_room_code"] ?? '-1').toString(),
        super(
            objectId: json["id"].toString(),
            createdAt:
                DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
            updatedAt:
                DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now());

  Map<String, dynamic> toJson() => {
        "title": title,
        "startTime": startDate,
        "endTime": endDate,
        "disableFlag": isCancel ? 1 : 0,
        "id": objectId,
      };
}
