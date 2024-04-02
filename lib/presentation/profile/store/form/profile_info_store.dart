import 'package:boilerplate/domain/entity/project/education_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/experience_list.dart';
import 'package:boilerplate/domain/entity/project/language_list.dart';
import 'package:boilerplate/domain/usecase/profile/get_education_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_experience_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_language_usecase.dart';
import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';
part 'profile_info_store.g.dart';

class ProfileStudentStore = _ProfileStudentStore with _$ProfileStudentStore;

abstract class _ProfileStudentStore with Store {
  _ProfileStudentStore(this._getEducationUseCase, this._getExperienceUseCase,
      this._getLanguageUseCase) {
    // _getEducationUseCase
    //     .call(params: _studentId.toString())
    //     .then((value) => _educations = value);
    // _getExperienceUseCase
    //     .call(params: _studentId.toString())
    //     .then((value) => _experiences = value);
    // _getLanguageUseCase
    //     .call(params: _studentId.toString())
    //     .then((value) => _languages = value);
  }

  GetLanguageUseCase _getLanguageUseCase;
  GetExperienceUseCase _getExperienceUseCase;
  GetEducationUseCase _getEducationUseCase;

  @computed
  bool get isEmpty => _languages.languages == null && _experiences.experiences == null && _educations.educations == null;

  @observable
  String? _studentId = '';

  @observable
  LanguageList _languages = LanguageList();

  @observable
  ProjectExperienceList _experiences = ProjectExperienceList();

  @observable
  EducationList _educations = EducationList();

  List<Language>? get currentLanguage => _languages.languages;
  List<ProjectExperience>? get currentProjectExperience => _experiences.experiences;
  List<Education>? get currentEducation => _educations.educations;

  @action
  void setStudentId(String value) {
    _studentId = value;
  }

  Future getInfo() async {
    _getEducationUseCase
        .call(params: _studentId.toString())
        .then((value) => _educations = value);
    _getExperienceUseCase
        .call(params: _studentId.toString())
        .then((value) => _experiences = value);
    _getLanguageUseCase
        .call(params: _studentId.toString())
        .then((value) => _languages = value);
  }
}
