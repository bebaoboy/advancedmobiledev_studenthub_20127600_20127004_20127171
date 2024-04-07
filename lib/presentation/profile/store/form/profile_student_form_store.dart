// ignore_for_file: prefer_final_fields, unused_field, prefer_interpolation_to_compose_strings

import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/get_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_resume.dart';
import 'package:boilerplate/domain/usecase/profile/get_transcript.dart';
import 'package:boilerplate/domain/usecase/profile/update_education.dart';
import 'package:boilerplate/domain/usecase/profile/update_language.dart';
import 'package:boilerplate/domain/usecase/profile/update_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/update_project_experience.dart';
import 'package:boilerplate/domain/usecase/profile/update_resume.dart';
import 'package:boilerplate/domain/usecase/profile/update_transcript.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:mobx/mobx.dart';

part 'profile_student_form_store.g.dart';

class ProfileStudentFormStore = _ProfileStudentFormStore
    with _$ProfileStudentFormStore;

abstract class _ProfileStudentFormStore with Store {
  final ProfileStudentFormErrorStore profileFormErrorStore;

  final ErrorStore errorStore;

  _ProfileStudentFormStore(
    this.profileFormErrorStore,
    this.errorStore,
    this._addProfileStudentUseCase,
    this._getProfileStudentUseCase,
    this._updateProfileStudentUseCase,
    this._addTechStackUseCase,
    this._addSkillsetUseCase,
    this._updateLanguageUseCase,
    this._updateEducationUseCase,
    this._updateProjectExperienceUseCase,
    this._updateResumeUseCase,
    this._getResumeUseCase,
    this._updateTranscriptUseCase,
    this._getTranscriptUseCase,
  ) {
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
  TechStack? techStack;

  @observable
  List<Skill>? skillSet;

  @observable
  List<Language>? languages;

  @observable
  List<Education>? educations;

  @observable
  List<ProjectExperience>? projectExperience;

  @observable
  String? transcript;
  String oldTranscript = "";

  @observable
  String? resume;
  String oldResume = "";

  @observable
  bool success = false;

  //usecase
  AddProfileStudentUseCase _addProfileStudentUseCase;
  UpdateProfileStudentUseCase _updateProfileStudentUseCase;
  GetProfileStudentUseCase _getProfileStudentUseCase;
  AddTechStackUseCase _addTechStackUseCase;
  AddSkillsetUseCase _addSkillsetUseCase;
  UpdateLanguageUseCase _updateLanguageUseCase;
  UpdateEducationUseCase _updateEducationUseCase;
  UpdateProjectExperienceUseCase _updateProjectExperienceUseCase;
  UpdateResumeUseCase _updateResumeUseCase;
  GetResumeUseCase _getResumeUseCase;
  UpdateTranscriptUseCase _updateTranscriptUseCase;
  GetTranscriptUseCase _getTranscriptUseCase;

  static ObservableFuture<void> emptyResponse = ObservableFuture.value(null);

  @observable
  ObservableFuture<void> addProfileStudentFuture = emptyResponse;

  @computed
  bool get isLoading => addProfileStudentFuture.status == FutureStatus.pending;

  @computed
  bool get canContinue => !profileFormErrorStore.hasErrors;

  @action
  Future addProfileStudent(
    TechStack? techStack,
    List<Skill>? skillset,
    List<Language>? languages,
    List<Education>? educations,
    List<ProjectExperience>? projectExperiences,
    String? transcripts,
    String? resumes,
  ) async {
    final AddProfileStudentParams loginParams = AddProfileStudentParams(
        techStack:
            techStack != null ? int.tryParse(techStack.objectId ?? "1") : 1,
        skillSet: (skillSet ?? [])
            .map((e) => int.tryParse(e.objectId ?? "1") ?? 0)
            .toList());
    final future = _addProfileStudentUseCase.call(params: loginParams);
    addProfileStudentFuture = ObservableFuture(future);
    String studentId = "15";

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;

        try {
          studentId = value.data["result"]["id"].toString();
        } catch (e) {
          errorStore.errorMessage = "cannot parse student id";
        }
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        //print(value.data);
      }
      //print(value);
    });

    await _updateLanguage(languages ?? [], studentId).then(
      (value) {
        success &= value;
        //print(value);
      },
    );

    await _updateEducation(educations ?? [], studentId).then(
      (value) {
        success &= value;

        //print(value);
      },
    );

    await _updateProjectExperience(projectExperiences ?? [], studentId).then(
      (value) {
        success &= value;

        //print(value);
      },
    );

    if (resumes != null) {
      await _updateResume(resumes, studentId).then(
        (value) {
          success &= value;

          //print(value);
        },
      );
    }

    if (transcripts != null) {
      await _updateTranscript(transcripts, studentId).then(
        (value) {
          success &= value;

          //print(value);
        },
      );
    }

    var userStore = getIt<UserStore>();
    if (userStore.user != null) {
      oldResume = resumes ?? "";
      oldTranscript = transcripts ?? "";
      userStore.user!.studentProfile = StudentProfile(
          fullName: userStore.user!.name,
          skillSet: skillset,
          techStack: techStack,
          transcript: transcripts,
          resume: resumes,
          languages: languages,
          educations: educations,
          projectExperience: projectExperiences,
          objectId: studentId);
      // ToDO: save to shared pref
      var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
      sharedPrefsHelper.saveStudentProfile(StudentProfile(
          fullName: userStore.user!.name,
          skillSet: skillset,
          techStack: techStack,
          transcript: transcripts,
          resume: resumes,
          languages: languages,
          educations: educations,
          projectExperience: projectExperiences,
          objectId: studentId));
    }
  }

  @action
  Future updateProfileStudent(
    TechStack? techStack,
    List<Skill>? skillset,
    List<Language>? languages,
    List<Education>? educations,
    List<ProjectExperience>? projectExperiences,
    String? transcripts,
    String? resumes,
    String id,
  ) async {
    print(
        "\n\n\n\n======================================\n UPDATE PROFILE\n======================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================\n\n\n\n\n\n");
    final UpdateProfileStudentParams loginParams = UpdateProfileStudentParams(
        techStack:
            techStack != null ? int.tryParse(techStack.objectId ?? "1") : 1,
        skillSet: (skillset ?? [])
            .map((e) => int.tryParse(e.objectId ?? "1") ?? 0)
            .toList(),
        id: id);
    final future = _updateProfileStudentUseCase.call(params: loginParams);
    addProfileStudentFuture = ObservableFuture(future);
    String studentId = id;

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;

        // try {
        //   studentId = value.data["result"]["id"].toString();
        // } catch (e) {
        //   errorStore.errorMessage = "cannot parse student id";
        // }
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        print("failed");
      }
      //print(value);
    });
    if (languages != null) {
      await _updateLanguage(languages, studentId).then(
        (value) {
          success &= value;
          //print(value);
        },
      );
    }

    if (educations != null) {
      await _updateEducation(educations, studentId).then(
        (value) {
          success &= value;

          //print(value);
        },
      );
    }

    if (projectExperiences != null) {
      await _updateProjectExperience(projectExperiences, studentId).then(
        (value) {
          success &= value;

          //print(value);
        },
      );
    }

    if (resumes != null && oldResume != resumes) {
      await _updateResume(resumes, studentId).then(
        (value) {
          success &= value;

          //print(value);
        },
      );
    }

    if (transcripts != null && oldTranscript != transcripts) {
      await _updateTranscript(transcripts, studentId).then(
        (value) {
          success &= value;

          //print(value);
        },
      );
    }
    // var infoStore = getIt<ProfileStudentStore>();
    var userStore = getIt<UserStore>();
    if (userStore.user != null) {
      userStore.user!.studentProfile = StudentProfile(
          objectId: studentId,
          fullName: userStore.user!.name,
          skillSet: skillset,
          techStack: techStack,
          transcript: transcripts,
          resume: resumes,
          languages: languages,
          educations: educations,
          projectExperience: projectExperiences);
      // ToDO: save to shared pref
      var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
      sharedPrefsHelper.saveStudentProfile(StudentProfile(
          fullName: userStore.user!.name,
          skillSet: skillset,
          techStack: techStack,
          transcript: transcripts,
          resume: resumes,
          languages: languages,
          educations: educations,
          projectExperience: projectExperiences,
          objectId: studentId));
    }
  }

  @action
  Future getProfileStudent(
    String id,
  ) async {
    print(
        "\n\n\n\n======================================\n GET PROFILE========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================\n\n\n\n\n\n\n");
    final UpdateProfileStudentParams loginParams =
        UpdateProfileStudentParams(techStack: null, skillSet: [], id: id);
    final future = _getProfileStudentUseCase.call(params: loginParams);
    addProfileStudentFuture = ObservableFuture(future);
    var userStore = getIt<UserStore>();

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        // TODO: API này trả về full student profile

        //print(value);
        try {
          if (userStore.user != null &&
              userStore.user!.studentProfile != null) {
            userStore.user!.studentProfile!.fullName =
                value.data["result"]["fullname"];
            userStore.user!.studentProfile!.techStack =
                TechStack.fromJson(value.data["result"]["techStack"]);
            techStack = userStore.user!.studentProfile!.techStack;
            if (value.data["result"]["skillSets"] != null) {
              var ssList = value.data["result"]["skillSets"] as List;
              userStore.user!.studentProfile!.skillSet = [];
              for (var element in ssList) {
                userStore.user!.studentProfile!.skillSet!
                    .add(Skill.fromMap(element));
              }
              skillSet = userStore.user!.studentProfile!.skillSet!;
            }
            // TODO: lưu thong tin student profile
          }
        } catch (e) {
          errorStore.errorMessage = "cannot save student profile";
        }
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        //print(value.data);
      }
      // //print(value);
    });
    await _getResume("", id).then(
      (value) {
        //print(value);
      },
    );

    await _getTranscript("", id).then(
      (value) {
        //print(value);
      },
    );
  }

  @action
  Future<bool> _updateLanguage(
      List<Language>? languages, String studentId) async {
    try {
      final loginParams = UpdateLanguageParams(
          languages: languages ?? [], studentId: studentId);
      final future = _updateLanguageUseCase.call(params: loginParams);
      // addProfileCompanyFuture = ObservableFuture(future);
      bool success = false;
      return await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          //print("language: ${value.data}");
        } else {
          success = false;
          errorStore.errorMessage = value.data['errorDetails'] is List<String>
              ? value.data['errorDetails'][0].toString()
              : value.data['errorDetails'].toString();
          // //print(value.data);
        }
        return success;
      });
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> _updateEducation(
      List<Education>? educations, String studentId) async {
    try {
      final loginParams = UpdateEducationParams(
          educations: educations ?? [], studentId: studentId);
      final future = _updateEducationUseCase.call(params: loginParams);
      // addProfileCompanyFuture = ObservableFuture(future);
      bool success = false;
      return await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          //print("education: ${value.data}");
        } else {
          success = false;
          errorStore.errorMessage = value.data['errorDetails'] is List<String>
              ? value.data['errorDetails'][0].toString()
              : value.data['errorDetails'].toString();
          // //print(value.data);
        }
        return success;
      });
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> _updateProjectExperience(
      List<ProjectExperience>? projectExperiences, String studentId) async {
    try {
      final loginParams = UpdateProjectExperienceParams(
          projectExperiences: projectExperiences ?? [], studentId: studentId);
      final future = _updateProjectExperienceUseCase.call(params: loginParams);
      // addProfileCompanyFuture = ObservableFuture(future);
      bool success = false;
      return await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          //print("exp: ${value.data}");
        } else {
          success = false;
          errorStore.errorMessage = value.data['errorDetails'] is List<String>
              ? value.data['errorDetails'][0].toString()
              : value.data['errorDetails'].toString();
          // //print(value.data);
        }
        return success;
      });
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> _updateResume(String resume, String studentId) async {
    try {
      //print("resume $resume");
      final loginParams =
          UpdateResumeParams(path: resume, studentId: studentId);
      final future = _updateResumeUseCase.call(params: loginParams);
      // addProfileCompanyFuture = ObservableFuture(future);
      bool success = false;
      return await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          //print("resume: ${value.data}");
        } else {
          success = false;
          errorStore.errorMessage = value.data.toString();
          //print(value.data);
        }
        return success;
      });
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> _getResume(String resume, String studentId) async {
    try {
      //print("resume $resume");
      final loginParams =
          UpdateResumeParams(path: resume, studentId: studentId);
      final future = _getResumeUseCase.call(params: loginParams);
      // addProfileCompanyFuture = ObservableFuture(future);
      bool success = false;
      return await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          //print("resume: ${value.data}");
          try {
            var userStore = getIt<UserStore>();
            if (userStore.user != null &&
                userStore.user!.studentProfile != null) {
              userStore.user!.studentProfile!.resume = value.data["result"];
            }
          } catch (e) {
            errorStore.errorMessage = "cannot get resume";
          }
        } else {
          success = false;
          errorStore.errorMessage = value.data.toString();
          //print(value.data);
        }
        return success;
      });
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> _updateTranscript(String transcript, String studentId) async {
    try {
      final loginParams =
          UpdateTranscriptParams(transcript: transcript, studentId: studentId);
      final future = _updateTranscriptUseCase.call(params: loginParams);
      // addProfileCompanyFuture = ObservableFuture(future);
      bool success = false;
      await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          //print("transcript: ${value.data}");
        } else {
          success = false;
          errorStore.errorMessage = value.data['errorDetails'] is List<String>
              ? value.data['errorDetails'][0].toString()
              : value.data['errorDetails'].toString();
          //print(value.data);
        }
      });
      return success;
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> _getTranscript(String transcript, String studentId) async {
    try {
      final loginParams =
          UpdateTranscriptParams(transcript: transcript, studentId: studentId);
      final future = _getTranscriptUseCase.call(params: loginParams);
      // addProfileCompanyFuture = ObservableFuture(future);
      bool success = false;
      await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          success = true;
          //print("transcript: ${value.data}");
          try {
            var userStore = getIt<UserStore>();
            if (userStore.user != null &&
                userStore.user!.studentProfile != null) {
              userStore.user!.studentProfile!.transcript = value.data["result"];
            }
          } catch (e) {
            errorStore.errorMessage = "cannot get transcript";
          }
        } else {
          success = false;
          errorStore.errorMessage = value.data['errorDetails'] is List<String>
              ? value.data['errorDetails'][0].toString()
              : value.data['errorDetails'].toString();
          //print(value.data);
        }
      });
      return success;
    } catch (e) {
      return false;
    }
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
  void setTechStack(TechStack value) {
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
    //print("set resume");
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
