import 'package:boilerplate/domain/entity/project/entities.dart';

class EducationList {
  List<Education>? educations;

  EducationList({
    this.educations,
  });

  factory EducationList.fromJson(List<dynamic> json) {
    List<Education> educations = <Education>[];
    educations = json.map((education) => Education.fromMap(education)).toList();

    return EducationList(
      educations: educations,
    );
  }
}
