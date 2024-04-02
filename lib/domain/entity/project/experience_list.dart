import 'package:boilerplate/domain/entity/project/entities.dart';

class ProjectExperienceList {
  List<ProjectExperience>? experiences;

  ProjectExperienceList({
    this.experiences,
  });

  factory ProjectExperienceList.fromJson(List<dynamic> json) {
    List<ProjectExperience> experiences = <ProjectExperience>[];
    experiences = json.map((experience) => ProjectExperience.fromMap(experience)).toList();

    return ProjectExperienceList(
      experiences: experiences,
    );
  }
}