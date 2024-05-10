import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:mobx/mobx.dart';

class ProjectList {
  @observable
  List<Project>? projects;
  List? data;

  ProjectList({required this.projects, this.data});

  factory ProjectList.fromJson(List<dynamic> json) {
    List<Project>? projects = <Project>[];
    projects = json.map((p) => Project.fromMap(p)).toList();

    return ProjectList(
      projects: projects,
    );
  }

  factory ProjectList.fromJsonWithPrefix(List<dynamic> json) {
    List<Project>? projects = <Project>[];
    projects =
        json.map((p) => Project.fromMap(p['project'] ?? p, fav: true)).toList();
    for (var element in projects) {
      element.isLoading = false;
    }
    return ProjectList(
      projects: projects,
    );
  }
}
