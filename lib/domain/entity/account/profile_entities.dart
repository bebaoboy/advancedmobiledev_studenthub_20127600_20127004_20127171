import 'dart:convert';

import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:json_annotation/json_annotation.dart';

// ------------------- PROFILE ACCOUNT ------------------------------

@JsonSerializable()
class Profile extends MyObject {
  Profile.fromJson(Map<String, dynamic> json);
  Profile({
    required super.objectId,
  });
}

@JsonSerializable()
class StudentProfile extends Profile {
  String fullName;
  // String userId;
  String education;
  String introduction;
  int yearOfExperience;
  String title; // job
  String review; // maybe enum
  TechStack? techStack;
  List<Skill>? skillSet;
  List<Language>? languages;
  List<Education>? educations;
  List<Proposal>? proposalProjects;

  List<ProjectExperience>? projectExperience;
  String? transcript = "";
  String? resume = "";

  StudentProfile({
    this.fullName = "",
    this.education = "",
    this.introduction = "",
    this.title = "",
    this.review = "",
    this.yearOfExperience = 0,
    this.skillSet,
    this.techStack,
    this.languages,
    this.educations,
    this.projectExperience,
    this.transcript,
    this.resume,
    this.proposalProjects,
    super.objectId = "",
  });

//   StudentProfile.fromJson(Map<String, dynamic> json)
//       : title = json["title"] ?? "",
//         fullName = json["fullName"] ?? "",
//         education = json["education"] ?? "",
//         introduction = json["introduction"] ?? "",
//         yearOfExperience = json["yearOfExperience"] ?? 0,
//         review = json["review"] ?? "",
//         techStack = (json["techStack"] as List<TechStack>),
//         skillSet = (json["skillSet"] as List<Skill>),
//         languages = (json["language"] as List<Language>),
//         educations = (json["education"] as List<Education>),
//         projectExperience =
//             (json["projectExperience"] as List<ProjectExperience>),
//         transcript = json["transcript"] ?? "",
//         resume = json["resume"] ?? "",
//         super(objectId: json["id"]);

//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'fullName': fullName,
//       'education': education,
//       'introduction': introduction,
//       'yearOfExperience': yearOfExperience,
//       'review': review,
//       'techStack': techStack,
//       'skillSet': skillSet,
//       'languages': languages,
//       'educations': educations,
//       'transcript': transcript,
//       'resume': resume,
//     };
//   }

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
      'experience': projectExperience,
      "proposals": proposalProjects,
      "id": int.tryParse(objectId ?? "-1"),
    };
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      title: map['title'] ?? '',
      fullName: map['fullName'] ?? '',
      education: map['education'] ?? '',
      introduction: map['introduction'] ?? '',
      yearOfExperience: map['yearOfExperience'] ?? 0,
      projectExperience: (map['experience'] != null)
          ? List<ProjectExperience>.from((map['experience'] as List<dynamic>)
              .map((e) => ProjectExperience.fromMap(e as Map<String, dynamic>)))
          : [],
      review: map['review'] ?? '',
      techStack: map['techStack'] != null
          ? TechStack.fromJson(map['techStack'])
          : null,
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
      proposalProjects: (map['proposals'] != null)
          ? List<Proposal>.from((map['proposals'] as List<dynamic>)
              .map((e) => Proposal.fromJson(e as Map<String, dynamic>)))
          : [],
      objectId: map["id"].toString(),
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
    // required this.userId,
    required this.companyName,
    required this.profileName,
    required this.email,
    required this.website,
    required this.description,
    this.scope = CompanyScope.solo,
    super.objectId = "",
  });

//   CompanyProfile.fromJson(Map<String, dynamic> json)
//       :
//         // userId = json["userId"] ?? "",
//         profileName = json["profileName"] ?? "",
//         companyName = json["companyName"] ?? "",
//         email = json["email"] ?? "",
//         website = json["website"] ?? "",
//         description = json["description"] ?? "",
//         scope = json["scope"] ?? "",
//         super(objectId: json["id"]);

//   Map<String, dynamic> toJson() {
//     return {
//       'profileName': profileName,
//       'companyName': companyName,
//       'email': email,
//       'website': website,
//       'description': description,
//       'scope': scope,
//     };
//   }

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      profileName: map['profileName'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      description: map['description'] ?? '',
      scope: CompanyScope.values[map['size'] ?? 0],
      objectId: map["id"].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileName': profileName,
      'companyName': companyName,
      'email': email,
      'website': website,
      'description': description,
      'size': scope.index,
      "id": int.tryParse(objectId ?? "-1"),
    };
  }

  String toJson() => json.encode(toMap());

  factory CompanyProfile.fromJson(String source) =>
      CompanyProfile.fromMap(json.decode(source));
}
