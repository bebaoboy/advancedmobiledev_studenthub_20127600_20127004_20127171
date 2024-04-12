import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/usecase/project/update_company_project.dart';
import 'package:mobx/mobx.dart';

part 'update_project_form_store.g.dart';

class UpdateProjectFormStore = _UpdateProjectFormStore
    with _$UpdateProjectFormStore;

abstract class _UpdateProjectFormStore with Store {
  final ErrorStore errorStore;
  final UpdateProjectFormErrorStore formErrorStore;

  _UpdateProjectFormStore(
      this.errorStore, this.formErrorStore, this._updateProjectUseCase) {
    _setUpValidator();
  }

  UpdateCompanyProject _updateProjectUseCase;

  late List<ReactionDisposer> _disposers;

  _setUpValidator() {
    _disposers = [
      reaction((_) => title, validateTitle),
      reaction((_) => description, validateDescription),
      reaction((_) => numberOfStudents, validateNumberOfStudents),
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

  @observable
  bool updateResult = false;

  @observable
  String notification = "";

  @computed
  bool get canUpdate =>
      !formErrorStore.hasError() &&
      title.isNotEmpty &&
      numberOfStudents > 0;

  @action
  void validateTitle(String value) {
    if (value.isEmpty) {
      formErrorStore.title = "Title must not be empty";
    } else {
      formErrorStore.title = null;
    }
  }

  @action
  void validateDescription(String value) {
    if (value.length > 500) {
      formErrorStore.description = "Description should be less than 500";
    } else {
      formErrorStore.description = null;
    }
  }

  @action
  void validateNumberOfStudents(int value) {
    if (value <= 0) {
      formErrorStore.numberOfStudent =
          "The number of students should at least be 1";
    } else if (value >= 1000) {
      formErrorStore.numberOfStudent =
          "The number of students should be less than 1000";
    } else {
      formErrorStore.numberOfStudent = null;
    }
  }

  setValue(Project project) {
    title = project.title;
    jobDescription = project.description;
    numberOfStudents = project.numberOfStudents;
    scope = project.scope;
  }

  void setTitle(String value) {
    title = value;
  }

  void setScope(Scope scope) {
    scope = scope;
  }

  void setDescription(String value) {
    description = value;
  }

  void setNumberOfStudents(int number) {
    numberOfStudents = number;
  }

  Future updateProject(
      int id, String title, String description, int number, Scope scope) async {
    var params =
        UpdateProjectParams(id, title, description, number, scope.index);
    var response = await _updateProjectUseCase.call(params: params);
    if (response.statusCode == HttpStatus.accepted ||
        response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      updateResult = true;
      notification = "Update successfully";
    } else {
      errorStore.errorMessage = response.data['errorDetails'][0];
      updateResult = false;
    }
  }

  void reset() {
    updateResult = false;
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}

class UpdateProjectFormErrorStore = _UpdateProjectFormErrorStore
    with _$UpdateProjectFormErrorStore;

abstract class _UpdateProjectFormErrorStore with Store {
  @observable
  String? title;

  @observable
  String? description;

  @observable
  String? numberOfStudent;
  String? jobDescription;

  bool hasError() {
    return title != null || description != null || numberOfStudent != null;
  }
}
