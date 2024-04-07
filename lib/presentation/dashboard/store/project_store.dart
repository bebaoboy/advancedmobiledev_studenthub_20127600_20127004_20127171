
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:mobx/mobx.dart';

part 'project_store.g.dart';

class ProjectStore = _ProjectStore with _$ProjectStore;

abstract class _ProjectStore with Store {
  _ProjectStore() {
    // _getProjectsUseCase.call(params: null).then((value) => _projects = value);
  }

  //GetProjectsUseCase _getProjectsUseCase;

  @observable
  ProjectList _projects = ProjectList(projects: List.empty());

  List<Project>? get projects => _projects.projects;

}
