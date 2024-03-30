// ignore_for_file: prefer_final_fields

import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_student_usecase.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';

part 'profile_student_form_store.g.dart';

class ProfileStudentFormStore = _ProfileStudentFormStore
    with _$ProfileStudentFormStore;

abstract class _ProfileStudentFormStore with Store {
  final ProfileStudentFormErrorStore profileFormErrorStore;

  final ErrorStore errorStore;

  _ProfileStudentFormStore(this.profileFormErrorStore, this.errorStore,
      this._addProfileStudentUseCase) {
    _setupValidations();
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupValidations() {
    _disposers = [
      // reaction((_) => companyName, validateCompanyName)
      ];
  }

  @observable
  String fullName = "";

  @observable
  String userId = "";

  @observable
  String education = "";

  @observable
  String introduction = "";

  @observable
  int yearOfExperience = 0;

  @observable
  String title = ""; // job

  @observable
  String review = ""; // maybe enum

  @observable
  List<TechStack>? techStack;

  @observable
  List<Skill>? skillSet;

  @observable
  List<Language>? languages;

  @observable
  List<Education>? educations;

    @observable
  List<ProjectExperience>? projectExperience;

  @observable
  String transcript = "";

  @observable
  String resume = "";

  @observable
  bool success = false;

  //usecase
  AddProfileStudentUseCase _addProfileStudentUseCase;

  static ObservableFuture<void> emptyResponse = ObservableFuture.value(null);

  @observable
  ObservableFuture<void> addProfileStudentCompanyFuture = emptyResponse;

  @computed
  bool get isLoading =>
      addProfileStudentCompanyFuture.status == FutureStatus.pending;

  @computed
  bool get canContinue => !profileFormErrorStore.hasErrors;

  @action
  Future addProfileStudentCompany(String companyName, String website,
      String description, CompanyScope size) async {
    final AddProfileStudentParams loginParams =
        AddProfileStudentParams(
            companyName: companyName,
            website: website,
            description: description,
            size: size.index);
    final future = _addProfileStudentUseCase.call(params: loginParams);
    addProfileStudentCompanyFuture = ObservableFuture(future);

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;
        print(value.data);
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        // print(value.data);
      }
    });
  }

  // FUNCTION =======================

  @action
  void setFullName(String value) {
    fullName = value;
  }

  @action
  void setUserId(String value) {
    userId = value;
  }

  @action
  void setEducation(String value) {
    education = value;
  }

  @action
  void setIntroduction(String value) {
    introduction = value;
  }

  @action
  void setYearOfExperience(int value) {
    yearOfExperience = value;
  }

  @action
  void setTitle(String value) {
    title = value;
  }

  @action
  void setReview(String value) {
    review = value;
  }

  @action
  void setTechStack(List<TechStack> value) {
    techStack = value;
  }

  @action
  void setSkillSet(List<Skill> value) {
    skillSet = value;
  }

  @action
  void setLanguages(List<Language> value) {
    languages = value;
  }

  @action
  void setEducations(List<Education> value) {
    educations = value;
  }

  @action
  void setProjectExperience(List<ProjectExperience> value) {
    projectExperience = value;
  }

  @action
  void setTranscript(String value) {
    transcript = value;
  }

  @action
  void setResume(String value) {
    resume = value;
  }

  @action
  void validateCompanyName(String value) {
    // if (value.isEmpty) {
    //   profileFormErrorStore.companyName = "Name can't be empty";
    // } else {
    //   profileFormErrorStore.companyName = null;
    // }
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }

  // void validateAll() {
  //   validateCompanyName(companyName);
  //   validateWebsite(website);
  // }
}

class ProfileStudentFormErrorStore = _ProfileStudentFormErrorStore
    with _$ProfileStudentFormErrorStore;

abstract class _ProfileStudentFormErrorStore with Store {
  @observable
  String? fullName;

  @observable
  String? userId;

  @observable
  String? education;

  @observable
  String? introduction;

  @observable
  int yearOfExperience = 0;

  @observable
  String? title; // job

  @observable
  String? review; // maybe enum

  @observable
  List<TechStack>? techStack;

  @observable
  List<Skill>? skillSet;

  @observable
  List<Language>? languages;

  @observable
  List<Education>? educations;

  @observable
  String? transcript;

  @observable
  String? resume;

  // @computed
  // bool get hasErrorsInCompanyName => companyName != null;

  // @computed
  // bool get hasErrorsInEmail => email != null;

  @computed
  bool get hasErrors => false;
}
