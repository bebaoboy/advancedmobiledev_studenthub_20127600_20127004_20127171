import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/usecase/project/get_projects.dart';
import 'package:mobx/mobx.dart';

part 'project_store.g.dart';

class ProjectStore = _ProjectStore with _$ProjectStore;

abstract class _ProjectStore with Store {
  _ProjectStore(this._getProjectsUseCase) {
    getAllProject();
  }

  GetProjectsUseCase _getProjectsUseCase;

  @observable
  ProjectList _projects = ProjectList(projects: List.empty());

  List<Project> get projects => _projects.projects ?? [];

  Future addProject(Project value, {index = 0}) async {
    if (_projects.projects != null) {
      _projects.projects!.insert(index, value);
    } else {
      _projects.projects = [value];
    }
  }

  Future getAllProject() {
    return _getProjectsUseCase.call(params: null).then((value) => _projects = value);
  }
}
