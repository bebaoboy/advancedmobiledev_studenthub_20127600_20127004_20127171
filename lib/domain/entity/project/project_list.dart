import 'package:boilerplate/domain/entity/project/project_entities.dart';

class ProjectList {
  List<Project>? projects;

  ProjectList({required this.projects});

  factory ProjectList.fromJson(List<dynamic> json) {
    List<Project>? projects = <Project>[];
    projects =
        json.map((p) => Project.fromMap(p)).toList();

    return ProjectList(
      projects: projects,
    );
  }

  factory ProjectList.fromJsonWithPrefix(List<dynamic> json) {
    List<Project>? projects = <Project>[];
    projects =
        json.map((p) => Project.fromMap(p['project'], fav: true)).toList();

    return ProjectList(
      projects: projects,
    );
  }
}
