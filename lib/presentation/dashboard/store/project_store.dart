import 'dart:io';

import 'package:boilerplate/core/widgets/loading_list.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
import 'package:boilerplate/domain/usecase/project/get_projects.dart';
import 'package:boilerplate/domain/usecase/project/get_student_favorite_project.dart';
import 'package:boilerplate/domain/usecase/project/get_student_proposal_projects.dart';
import 'package:boilerplate/domain/usecase/project/save_student_favorite_project.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'project_store.g.dart';

class ProjectStore = _ProjectStore with _$ProjectStore;

abstract class _ProjectStore with Store {
  _ProjectStore(
    this._getProjectsUseCase,
    this._getProjectByCompanyUseCase,
    this._getStudentProposalProjectsUseCase,
    this._getStudentFavoriteProjectUseCase,
    this._saveStudentFavoriteProjectUseCase,
  ) {
    // _getStudentFavoriteProjectUseCase.call(params: null).then((value) {
    //   _favoriteProjects = value;
    // });
  }

  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByCompanyUseCase _getProjectByCompanyUseCase;
  final GetStudentProposalProjectsUseCase _getStudentProposalProjectsUseCase;
  final GetStudentFavoriteProjectUseCase _getStudentFavoriteProjectUseCase;
  final SaveStudentFavoriteProjectUseCase _saveStudentFavoriteProjectUseCase;

  @observable
  ProjectList _projects = ProjectList(projects: List.empty(growable: true));

  List<Project> get projects => _projects.projects ?? [];

  @observable
  ProjectList _companyProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get companyProjects => _companyProjects.projects ?? [];

  @observable
  ProjectList _favoriteProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get favoriteProjects => _favoriteProjects.projects ?? [];

  Future addProject(Project value, {index = 0, sort = true}) async {
    if (_projects.projects != null) {
      if (sort) {
        value.updatedAt = DateTime.now();
      }
      value.isLoading = false;
      _projects.projects!.insert(index, value);
    } else {
      _projects.projects = [value];
    }
    if (sort) {
      _projects.projects?.sort(
        (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
      );
    }
  }

  Future updateInFav(Project project) async {
    var findProject = favoriteProjects
        .firstWhereOrNull((p) => p.objectId == project.objectId);
    if (findProject == null) {
      _favoriteProjects.projects!.add(project);
    } else {
      _favoriteProjects.projects!.remove(project);
    }
  }

  Future saveFavToSharePref() async {
    await _saveStudentFavoriteProjectUseCase.call(params: _favoriteProjects);
  }

  Future deleteCompanyProject(Project value, {index = 0}) async {
    if (_companyProjects.projects != null) {
      var i = _companyProjects.projects!
          .indexWhere((e) => e.objectId == value.objectId);
      if (i != -1) _companyProjects.projects!.removeAt(i);
    } else {
      // _companyProjects.projects = [value];
    }
    _companyProjects.projects?.sort(
      (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
    );
  }

  Future updateCompanyProject(Project value, {index = 0}) async {
    if (_companyProjects.projects != null) {
      value.updatedAt = DateTime.now();
      var i = _companyProjects.projects!
          .indexWhere((e) => e.objectId == value.objectId);
      if (i != -1) {
        _companyProjects.projects!
            .insert(index, _companyProjects.projects!.removeAt(i));
      } else {
        _companyProjects.projects!.insert(index, value);
      }
    } else {
      _companyProjects.projects = [value];
    }
    _companyProjects.projects?.sort(
      (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
    );
  }

  /// descending created date order
  // Future<ProjectList> getAllProject() async {
  //   try {
  //     await getStudentFavoriteProject(false);
  //   } catch (e) {
  //     // nothing changed
  //   }
  //   return await _getProjectsUseCase
  //       .call(params: GetProjectParams())
  //       .then((value) {
  //     _projects = value;
  //     for (var element in _favoriteProjects.projects!) {
  //       var p = _projects.projects!.firstWhereOrNull(
  //         (e) => e.objectId == element.objectId,
  //       );
  //       if (p != null) {
  //         p.isFavorite = true;
  //       }
  //     }
  //     _projects.projects?.sort(
  //       (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
  //     );
  //     return _projects;
  //   });
  // }
  Future<ProjectList> getAllProject(GlobalKey<RefazynistState> refazynistKey,
      {int count = 5}) async {
    return await _getProjectsUseCase
        .call(params: GetProjectParams())
        .then((value) {
      // projects = value.projects!.map((p) => Project.fromMap(p)).toList();
      print("call api refesshh");

      Future.delayed(const Duration(seconds: 1), () async {
        try {
          await getStudentFavoriteProject(false);
        } catch (e) {
          // nothing changed
        }
        final ProjectDataSource datasource = getIt<ProjectDataSource>();

        bool doneInit = false;
        if (value.data != null) {
          _projects.projects?.clear();
          for (int i = 0; i < value.data!.length; i++) {
            if (i == 5 && !doneInit) {
              // refazynistKey.currentState?.refresh();
              doneInit = true;
              print("refesshh");
            }
            var project = Project.fromMap(value.data![i]);
            project.isLoading = false;
            var p = _favoriteProjects.projects!.firstWhereOrNull(
              (e) => e.objectId == project.objectId,
            );
            if (p != null) {
              project.isFavorite = true;
            }
            addProject(project, sort: false);

            datasource.insert(project);
          }
          _projects.projects?.forEach(
            (element) => element.isLoading = false,
          );
          _projects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );

          refazynistKey.currentState?.refresh(readyMade: _projects.projects);
        } else {
          _projects = value;
          _projects.projects?.forEach(
            (element) => element.isLoading = false,
          );
          _favoriteProjects.projects?.forEach(
            (element) {
              var p = _projects.projects!.firstWhereOrNull(
                (e) => e.objectId == element.objectId,
              );
              if (p != null) {
                p.isFavorite = true;
              }
            },
          );
          _projects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );
          refazynistKey.currentState?.refresh(readyMade: _projects.projects);
        }
      });

      // _projects = value;

      return ProjectList(
        projects: List.filled(
          5.clamp(0, (value.data ?? []).length),
          Project(
            title: "",
            description: "",
            timeCreated: DateTime.now(),
          ),
          growable: true,
        ),
      );
    });
  }

  Future<ProjectList> getStudentFavoriteProject(bool force) async {
    if (force) {
      return await _getStudentFavoriteProjectUseCase
          .call(params: null)
          .then((value) {
        _favoriteProjects = value;
        _favoriteProjects.projects?.sort(
          (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
        );
        return _favoriteProjects;
      });
    } else {
      if (_favoriteProjects.projects != null &&
          _favoriteProjects.projects!.isNotEmpty) {
        return Future.value(_favoriteProjects);
      } else {
        return await _getStudentFavoriteProjectUseCase
            .call(params: null)
            .then((value) {
          _favoriteProjects = value;
          _favoriteProjects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );
          return _favoriteProjects;
        });
      }
    }
  }

  @action
  Future<ProjectList> getProjectByCompany(String id, {Status? typeFlag}) async {
    print(
        "\n\n\n\n======================================\n GET PROJECT COMPANY ========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================\n\n\n\n\n\n\n");
    var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
    final GetProjectByCompanyParams loginParams =
        GetProjectByCompanyParams(companyId: id, typeFlag: typeFlag?.index);
    try {
      final value = await _getProjectByCompanyUseCase.call(params: loginParams);
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        print(value);

        var result = ProjectList.fromJson(value.data["result"]);
        _companyProjects = result;

        // TODO: lưu vào sharedpref

        sharedPrefsHelper.saveCompanyProjects(_companyProjects);

        _companyProjects.projects?.sort(
          (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
        );

        return _companyProjects;
      } else {
        print(value.data);
        _companyProjects = ProjectList(projects: []);
        return Future.value(ProjectList(projects: []));
      }
    } catch (e) {
      // errorStore.errorMessage = "cannot save student profile";

      var companys = await sharedPrefsHelper.getCompanyProjects();
      if (companys.projects != null && companys.projects!.isNotEmpty) {
        {
          _companyProjects = companys;
          _companyProjects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );
          return companys;
        }
      }
      print("cannot get profile company");
      return Future.value(ProjectList(projects: []));
    }
    // //print(value);
  }

  @action
  Future<ProposalList> getStudentProposalProjects(String studentId,
      {HireStatus? statusFlag}) async {
    print(
        "\n\n\n\n======================================\n GET PROJECT COMPANY ========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================\n\n\n\n\n\n\n");
    final GetStudentProposalProjectsParams loginParams =
        GetStudentProposalProjectsParams(
            studentId: studentId, statusFlag: statusFlag?.index);
    var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
    var userStore = getIt<UserStore>();

    try {
      final future =
          _getStudentProposalProjectsUseCase.call(params: loginParams);
      return await future.then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          print(value);
          try {
            var result = ProposalList.fromJson(value.data["result"]);
            if (userStore.user != null &&
                userStore.user!.studentProfile != null) {
              userStore.user!.studentProfile!.proposalProjects =
                  result.proposals;

              sharedPrefsHelper.saveStudentProjects(result);

              userStore.user!.studentProfile!.proposalProjects?.sort(
                (a, b) => b.createdAt!.compareTo(a.createdAt!),
              );
            }
            return result;

            // TODO: lưu vào sharedpref
          } catch (e) {
            // errorStore.errorMessage = "cannot save student profile";
            print("cannot get profile company");
            return ProposalList(proposals: []);
          }
        } else {
          print(value.data);
          return ProposalList(proposals: []);
        }
        // //print(value);
      });
    } catch (e) {
      var companys = await sharedPrefsHelper.getStudentProjects();

      if (companys.proposals != null && companys.proposals!.isNotEmpty) {
        {
          if (userStore.user != null &&
              userStore.user!.studentProfile != null) {
            userStore.user!.studentProfile!.proposalProjects =
                companys.proposals;
            userStore.user!.studentProfile!.proposalProjects?.sort(
              (a, b) => b.createdAt!.compareTo(a.createdAt!),
            );
          }
          return companys;
        }
      }
    }
    return ProposalList(proposals: []);
  }
}
