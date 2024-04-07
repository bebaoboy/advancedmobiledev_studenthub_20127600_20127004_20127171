import 'package:boilerplate/domain/entity/project/project_entities.dart';

class ProjectList {
  List<Project>? projects;

  ProjectList({required this.projects});

  factory ProjectList.fromJson(List<dynamic> json) {
    List<Project>? projects = <Project>[];
    projects = json.map((post) => Project.fromMap(post)).toList();

    return ProjectList(
      projects: projects,
    );
  }
}
