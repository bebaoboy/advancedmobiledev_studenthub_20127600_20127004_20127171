// import 'package:boilerplate/domain/entity/project/entities.dart';
// import 'package:json_annotation/json_annotation.dart';

// @JsonSerializable()
// class Interview extends MyObject {
//   String title;
//   DateTime startDate;
//   DateTime endDate;
//   int disableFlag = 0;

//   Interview(
//     this.disableFlag, {
//     required this.title,
//     required this.startDate,
//     required this.endDate,
//     String id = "",
//     super.createdAt,
//     super.updatedAt,
//     super.deletedAt,
//   }) : super(
//           objectId: id,
//         );

//   Interview.fromJson(Map<String, dynamic> json)
//       : title = json['title'] ?? '',
//         startDate = DateTime.parse(json['startTime']),
//         endDate = DateTime.parse(json['endTime']),
//         disableFlag = json['disableFlag'] ?? 0,
//         super(
//             objectId: json['id'] ?? 'random-meeting-id',
//             createdAt: DateTime.parse(json['createdAt']),
//             updatedAt: json['updatedAt'] == null
//                 ? DateTime.now()
//                 : DateTime.parse(json['updatedAt']),
//             deletedAt: json['deletedAt'] == null
//                 ? null
//                 : DateTime.parse(json['deletedAt']));

//   Map<String, dynamic> toJson() {
//     return {
//       "title": title,
//       "startDate": startDate,
//       "endDate": endDate,
//       "id": objectId ?? 'random-meeting-id',
//       "disableFlag": disableFlag,
//       "type": "schedule",
//     };
//   }
// }
