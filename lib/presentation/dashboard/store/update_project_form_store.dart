// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/usecase/project/update_company_project.dart';
import 'package:boilerplate/presentation/dashboard/store/project_store.dart';
import 'package:flutter/foundation.dart';
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

  final UpdateCompanyProject _updateProjectUseCase;

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
  ValueNotifier<bool> updateResult = ValueNotifier(false);

  @observable
  String notification = "";

  @computed
  bool get canUpdate =>
      !formErrorStore.hasError() &&
      title.isNotEmpty &&
      numberOfStudents > 0 &&
      description.length <= 500;

  @action
  void validateTitle(String value) {
    if (value.isEmpty) {
      formErrorStore.title = "Must not be empty";
    } else if (value.length > 200) {
      formErrorStore.title = "Should be upmost 200 character";
    } else {
      formErrorStore.title = null;
    }
  }

  @action
  void validateDescription(String value) {
    if (value.length > 500) {
      formErrorStore.description = "Should be less than 500";
    } else {
      formErrorStore.description = null;
    }
  }

  @action
  void validateNumberOfStudents(int value) {
    if (value <= 0) {
      formErrorStore.numberOfStudent = "Should at least be 1";
    } else if (value >= 1000) {
      formErrorStore.numberOfStudent = "Should be less than 1000";
    } else {
      formErrorStore.numberOfStudent = null;
    }
  }

  setValue(Project project) {
    title = project.title;
    description = project.description;
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
      int id, String title, String description, int number, Scope scope,
      {int? statusFlag}) async {
    var params = UpdateProjectParams(
        id, title, description, number, scope.index,
        statusFlag: statusFlag);
    try {
      var response = await _updateProjectUseCase.call(params: params);
      if (response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        updateResult.value = true;
        notification = "Update successfully";
        final ProjectStore projectStore = getIt<ProjectStore>();
        try {
          projectStore.companyProjects
              .firstWhere((e) => e.objectId == id.toString())
              .title = title;
          projectStore.companyProjects
              .firstWhere((e) => e.objectId == id.toString())
              .description = description;
          projectStore.companyProjects
              .firstWhere((e) => e.objectId == id.toString())
              .numberOfStudents = number;
          projectStore.companyProjects
              .firstWhere((e) => e.objectId == id.toString())
              .scope = scope;
          projectStore.companyProjects
              .firstWhere((e) => e.objectId == id.toString())
              .updatedAt = DateTime.now();
          if (statusFlag != null) {
            projectStore.companyProjects
                .firstWhere((e) => e.objectId == id.toString())
                .enabled = Status.values[statusFlag];
          }
          var i = projectStore.companyProjects
              .indexWhere((e) => e.objectId == id.toString());
          if (i != -1) {
            projectStore.updateCompanyProject(
                projectStore.companyProjects.elementAt(i));
          }
        } catch (e) {
          // at least we tried
        }
      } else {
        errorStore.errorMessage = response.data['errorDetails'][0];
        updateResult.value = false;
      }
    } catch (e) {
      errorStore.errorMessage = 'Update failed';
      updateResult.value = false;
    }
    // ignore: invalid_use_of_visible_for_testing_member
    updateResult.notifyListeners();
  }

  void reset() {
    updateResult.value = false;
    // ignore: invalid_use_of_visible_for_testing_member
    updateResult.notifyListeners();
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

  bool hasError() {
    return title != null || description != null || numberOfStudent != null;
  }
}
