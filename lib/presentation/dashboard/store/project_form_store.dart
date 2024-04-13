import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/usecase/project/create_project.dart';
import 'package:boilerplate/domain/usecase/project/delete_project.dart';
import 'package:boilerplate/domain/usecase/project/update_favorite.dart';
import 'package:mobx/mobx.dart';

part 'project_form_store.g.dart';

class ProjectFormStore = _ProjectFormStore with _$ProjectFormStore;

abstract class _ProjectFormStore with Store {
  final ErrorStore errorStore;

  _ProjectFormStore(this._createProjectUseCase, this._deleteProjectUseCase,
      this._updateFavoriteProjectUseCase, this.errorStore) {}

  // For add to favorite
  @observable
  int projectId = 1;

  @observable
  bool disableFlag = true;

  // For post project
  @observable
  int companyId = 1;

  @observable
  String title = '';

  @observable
  String description = '';

  @observable
  int numberOfStudents = 0;

  @observable
  Scope projectScopeFlag = Scope.tight;

  @observable
  bool typeFlag = true;

  @observable
  bool success = false;

  @observable
  int studentId = 1;

  @observable
  ObservableFuture<void> createProjectFuture = emptyResponse;

  @observable
  ObservableFuture<void> deleteProjectFuture = emptyResponse;

  @observable
  ObservableFuture<void> updateProjectFuture = emptyResponse;

  createProjectUseCase _createProjectUseCase;
  deleteProjectUseCase _deleteProjectUseCase;
  updateFavoriteProjectUseCase _updateFavoriteProjectUseCase;

  static ObservableFuture<void> emptyResponse = ObservableFuture.value(null);

  @action
  Future createProject(int companyId, String title, String description,
      int numberOfStudents, Scope projectScopeFlag, bool typeFlag) async {
    final createProjectParams projectParams = createProjectParams(
        companyId: companyId,
        title: title,
        description: description,
        numberOfStudents: numberOfStudents,
        projectScopeFlag: projectScopeFlag,
        typeFlag: typeFlag);
    final future = _createProjectUseCase.call(params: projectParams);
    createProjectFuture = ObservableFuture(future);

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;
        print(value.data);
        String? id;
        try {
          id = value.data["result"]["id"].toString();
        } catch (e) {
          errorStore.errorMessage = "cannot parse company id";
        }

        var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        print(value.data);
      }
    });
  }

  @action
  Future deleteProject(int projectId) async {
    final deleteProjectParams projectParams =
        deleteProjectParams(Id: projectId);
    final future = _deleteProjectUseCase.call(params: projectParams);
    deleteProjectFuture = ObservableFuture(future);

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;
        print(value.data);
        String? id;
        try {
          id = value.data["result"]["id"].toString();
        } catch (e) {
          errorStore.errorMessage = "cannot parse company id";
        }

        var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        print(value.data);
      }
    });
  }

  @action
  Future updateFavoriteProject(
      int studentId, int projectId, bool disableFlag) async {
    final updateFavoriteProjectParams projectParams =
        updateFavoriteProjectParams(
            projectId: projectId,
            disableFlag: disableFlag,
            studentId: studentId);
    final future = _updateFavoriteProjectUseCase.call(params: projectParams);
    updateProjectFuture = ObservableFuture(future);

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;
        print(value.data);
        String? id;
        try {
          id = value.data["result"]["id"].toString();
        } catch (e) {
          errorStore.errorMessage = "cannot parse company id";
        }

        var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        print(value.data);
      }
    });
  }
}
