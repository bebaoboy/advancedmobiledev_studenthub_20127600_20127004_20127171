import 'dart:io';

import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/education_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/experience_list.dart';
import 'package:boilerplate/domain/entity/project/language_list.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/get_education_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_experience_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_language_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/get_techstack.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:mobx/mobx.dart';

part 'profile_info_store.g.dart';

class ProfileStudentStore = _ProfileStudentStore with _$ProfileStudentStore;

abstract class _ProfileStudentStore with Store {
  _ProfileStudentStore(
      this._getEducationUseCase,
      this._getExperienceUseCase,
      this._getLanguageUseCase,
      this._getTechStackUseCase,
      this._getSkillsetUseCase) {
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

  final GetLanguageUseCase _getLanguageUseCase;
  final GetExperienceUseCase _getExperienceUseCase;
  final GetEducationUseCase _getEducationUseCase;
  final GetTechStackUseCase _getTechStackUseCase;
  final GetSkillsetUseCase _getSkillsetUseCase;

  @computed
  bool get isEmpty =>
      _languages.languages == null &&
      _experiences.experiences == null &&
      _educations.educations == null;

  @observable
  String? _studentId = '';

  @observable
  LanguageList _languages = LanguageList();

  @observable
  ProjectExperienceList _experiences = ProjectExperienceList();

  @observable
  EducationList _educations = EducationList();

  List<Language> get currentLanguage => _languages.languages ?? [];
  List<ProjectExperience> get currentProjectExperience =>
      _experiences.experiences ?? [];
  List<Education> get currentEducation => _educations.educations ?? [];

  List<TechStack>? _techStack;
  List<Skill>? _skillset;

  List<TechStack> get techStack => _techStack ?? [];
  List<Skill> get skillSet => _skillset ?? [];

  @action
  void setStudentId(String value) {
    _studentId = value;
  }

  Future getInfo() async {
    if (_studentId != null) {
      try {
        var userStore = getIt<UserStore>();
        await getTechStack();
        await getSkillset();

        await _getEducationUseCase
            .call(params: _studentId.toString())
            .then((value) => _educations = value)
            .onError(
              (error, stackTrace) => _educations = EducationList(
                  educations: userStore.user!.studentProfile!.educations),
            );
        await _getExperienceUseCase
            .call(params: _studentId.toString())
            .then((value) => _experiences = value)
            .onError(
              (error, stackTrace) => _experiences = ProjectExperienceList(
                  experiences:
                      userStore.user!.studentProfile!.projectExperience),
            );
        await _getLanguageUseCase
            .call(params: _studentId.toString())
            .then((value) => _languages = value)
            .onError(
              (error, stackTrace) => _languages = LanguageList(
                  languages: userStore.user!.studentProfile!.languages),
            );
        // if (userStore.user != null && userStore.user!.studentProfile != null) {
        //   userStore.user!.studentProfile!.educations = currentEducation;
        //   userStore.user!.studentProfile!.languages = currentLanguage;
        //   userStore.user!.studentProfile!.projectExperience =
        //       currentProjectExperience;
        // }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @action
  Future<bool> getTechStack() async {
    try {
      final loginParams = AddTechStackParams(name: "");
      final future = _getTechStackUseCase.call(params: loginParams);
      // addProfileCompanyFuture = ObservableFuture(future);

      var sharePref = getIt<SharedPreferenceHelper>();
      var techStack = await sharePref.getTechStack();
      if (techStack!.isNotEmpty) {
        _techStack = techStack;
        return true;
      }

      bool success = false;
      return await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          print("techstack: ${value.data}");
          try {
            if (value.data["result"] != null) {
              var ssList = value.data["result"] as List;
              _techStack = [];
              for (var element in ssList) {
                _techStack!.add(TechStack.fromJson(element));
              }

              sharePref.saveTechStack(_techStack);
            }
          } catch (e) {
            print("cannot get all techstack");
          }
        } else {
          success = false;
          print(value.data.toString());
          // print(value.data);
        }
        return success;
      });
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> getSkillset() async {
    try {
      final loginParams = AddSkillsetParams(name: "");
      final future = _getSkillsetUseCase.call(params: loginParams);

      var sharePref = getIt<SharedPreferenceHelper>();
      bool success = false;
      var skillset = await sharePref.getSkill();
      if (skillset!.isNotEmpty) {
        _skillset = skillset;
        return true;
      }

      return await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          print("skillset: ${value.data}");
          try {
            if (value.data["result"] != null) {
              var ssList = value.data["result"] as List;
              _skillset = [];
              for (var element in ssList) {
                _skillset!.add(Skill.fromMap(element));
              }
              sharePref.saveSkills(_skillset);
            }
          } catch (e) {
            print("cannot get all skillset");
          }
        } else {
          success = false;
          print(value.data.toString());
          // print(value.data);
        }
        return success;
      });
    } catch (e) {
      return false;
    }
  }
}
