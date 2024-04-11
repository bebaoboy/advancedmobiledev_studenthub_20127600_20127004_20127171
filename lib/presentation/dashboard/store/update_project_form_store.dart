import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:mobx/mobx.dart';

part 'update_project_form_store.g.dart';

class UpdateProjectFormStore = _UpdateProjectFormStore
    with _$UpdateProjectFormStore;

abstract class _UpdateProjectFormStore with Store {
  final ErrorStore _errorStore;
  final UpdateProjectFormErrorStore _formErrorStore;

  _UpdateProjectFormStore(this._errorStore, this._formErrorStore) {
    _setUpValidator();
  }

  late List<ReactionDisposer> _disposers;

  _setUpValidator() {
    _disposers = [
      reaction((_) => title, validateTitle),
      reaction((_) => description, validateDescription),
    ];
  }

  @observable
  String title = "";

  @observable
  String jobDescription = "";

  @observable
  Scope scope = Scope.short;

  @observable
  int numberOfStudents = 1;

  @observable
  String description = "";

  @computed
  bool get canUpdate =>
      _formErrorStore.hasNoError() &&
      jobDescription.isNotEmpty &&
      description.isNotEmpty &&
      numberOfStudents > 0;

  @action
  void validateTitle(String value) {}

  @action
  void validateDescription(String value) {}

  setValue(Project project){
    title = project.title;
    jobDescription = project.description;
    numberOfStudents = project.numberOfStudents;
    scope = project.scope;
  }
}

class UpdateProjectFormErrorStore = _UpdateProjectFormErrorStore
    with _$UpdateProjectErrorFormStore;

abstract class _UpdateProjectFormErrorStore with Store {
  String? title;
  String? description;
  String? numberOfStudent;
  String? jobDescription;

  bool hasNoError() {
    return title != null &&
        description != null &&
        jobDescription != null &&
        numberOfStudent != null;
  }
}
