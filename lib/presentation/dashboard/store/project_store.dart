import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/widgets/loading_list.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
import 'package:boilerplate/domain/usecase/project/get_project_proposals.dart';
import 'package:boilerplate/domain/usecase/project/get_projects.dart';
import 'package:boilerplate/domain/usecase/project/get_student_favorite_project.dart';
import 'package:boilerplate/domain/usecase/project/get_student_proposal_projects.dart';
import 'package:boilerplate/domain/usecase/project/save_student_favorite_project.dart';
import 'package:boilerplate/domain/usecase/proposal/post_proposal.dart';
import 'package:boilerplate/domain/usecase/proposal/update_proposal.dart';
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
      this._postProposalUseCase,
      this._getProjectProposalsUseCase,
      this._updateProposalUseCase);

  Future init() async {
    try {
      return await getStudentFavoriteProject(false);
    } catch (e) {
      // nothing changed
      print("error getting fav");
    }
  }

  // company
  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByCompanyUseCase _getProjectByCompanyUseCase;

  // student
  final GetStudentProposalProjectsUseCase _getStudentProposalProjectsUseCase;
  final GetStudentFavoriteProjectUseCase _getStudentFavoriteProjectUseCase;
  final SaveStudentFavoriteProjectUseCase _saveStudentFavoriteProjectUseCase;
  final PostProposalUseCase _postProposalUseCase;
  final GetProjectProposals _getProjectProposalsUseCase;
  final UpdateProposalUseCase _updateProposalUseCase;

  final ErrorStore errorStore = getIt<ErrorStore>();

  @observable
  ProjectList _projects = ProjectList(projects: List.empty(growable: true));

  List<Project> get projects => _projects.projects ?? [];

  @observable
  ProjectList _companyProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get companyProjects => _companyProjects.projects ?? [];

  @observable
  // ignore: prefer_final_fields
  ProjectList _studentProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get studentProjects => _studentProjects.projects ?? [];

  @observable
  ProjectList _favoriteProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get favoriteProjects => _favoriteProjects.projects ?? [];

  @observable
  ProposalList currentProps =
      ProposalList(proposals: List.empty(growable: true));

  @observable
  bool postSuccess = false;

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

  Future<bool> postProposal(Proposal proposal, Project project) async {
    int status = 0;
    int disableFlag = 0;

    var params = PostProposalParams(
        status,
        disableFlag,
        proposal.coverLetter,
        int.parse(proposal.project!.objectId!),
        int.parse(proposal.student.objectId!));
    return await _postProposalUseCase.call(params: params).then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        updateLocalProjectProposal(project, proposal);
        return true;
      } else {
        errorStore.errorMessage = value.data['errorDetails'];
        return false;
      }
    });
  }

  updateLocalProjectProposal(Project project, Proposal proposal) async {
    if (_projects.projects == null || _projects.projects!.isEmpty) return;
    int index = _projects.projects!
        .indexWhere((Project element) => element.objectId == project.objectId);
    if (index != -1) {
      _projects.projects![index].proposal?.add(proposal);
    }
  }

  Future<bool> updateProposal(Proposal project, String studentId) async {
    var params = UpdateProposalParams(
      project.hiredStatus.index,
      project.enabled ? 0 : 1,
      project.coverLetter,
      int.parse(project.objectId!),
    );
    var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
    var userStore = getIt<UserStore>();
    try {
      return await _updateProposalUseCase.call(params: params).then((value) {
        if (value.statusCode == HttpStatus.accepted ||
            value.statusCode == HttpStatus.ok ||
            value.statusCode == HttpStatus.created) {
          if (project.project != null) {
            if (userStore.user != null &&
                userStore.user!.type == UserType.student &&
                userStore.user!.studentProfile != null) {
              var p = userStore.user!.studentProfile!.proposalProjects!
                  .firstWhereOrNull(
                (element) => element.objectId == project.objectId,
              );
              if (p != null) {
                p.hiredStatus = project.hiredStatus;
                p.enabled = project.enabled;
                p.coverLetter = project.coverLetter;

                // if (!p.enabled) {
                //   userStore.user!.studentProfile!.proposalProjects
                //       !.firstWhere((element) => element.objectId == p.objectId)
                //       .hiredStatus = HireStatus.notHired;
                // }
              }

              // TODO: remove if reject (disableFlag)

              sharedPrefsHelper.saveStudentProjects(ProposalList(
                  proposals: userStore.user!.studentProfile!.proposalProjects));

              userStore.user!.studentProfile!.proposalProjects?.sort(
                (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
              );
            }
            int index = _projects.projects!.indexWhere(
                (Project element) => element.objectId == project.objectId);
            if (index != -1) {
              var m = _projects.projects![index].proposal
                  ?.firstWhereOrNull((e) => project.objectId == e.objectId);
              if (m != null) {
                m.hiredStatus = project.hiredStatus;
                m.enabled = project.enabled;
                m.coverLetter = project.coverLetter;
              }
            }
          }
          return true;
        } else {
          print(value.data.toString());

          return false;
        }
      });
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
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

  Future changeToStatus(HireStatus status, Proposal proposal) async {
    // UpdateProposalParams params = UpdateProposalParams(
    //     status.index,
    //     proposal.enabled ? 0 : 1,
    //     proposal.coverLetter,
    //     int.parse(proposal.objectId!));
    proposal.hiredStatus = status;
    await updateProposal(proposal, "");
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
      {int count = 5, Function? setStateCallback}) async {
    _getProjectsUseCase.call(params: GetProjectParams()).then((value) {
      // projects = value.projects!.map((p) => Project.fromMap(p)).toList();
      print("call api refesshh");

      Future.delayed(const Duration(seconds: 1), () async {
        final ProjectDataSource datasource = getIt<ProjectDataSource>();

        bool doneInit = false;
        var fav = await _getStudentFavoriteProjectUseCase.call(params: null);
        _favoriteProjects = fav;

        if (value.data != null) {
          _projects.projects?.clear();
          for (int i = 0; i < value.data!.length; i++) {
            if (i == 5 && !doneInit) {
              doneInit = true;
              // refazynistKey.currentState?.refresh(
              //     isFinal: false,
              //     readyMade: _projects.projects!
              //         .sublist(0, count.clamp(0, _projects.projects!.length))
              //         .toList());
              // if (setStateCallback != null) setStateCallback();

              print("refesshh");
            }
            var project = Project.fromMap(value.data![i]);
            project.isLoading = false;

            addProject(project, sort: false);

            // datasource.insert(project);
          }
          print("favorite refess ${_favoriteProjects.projects!.length}");
          _projects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );

          _projects.projects?.forEach((element) {
            element.isLoading = false;
            var b = fav.projects?.firstWhereOrNull(
              (e) => element.objectId == e.objectId,
            );
            if (b != null) {
              element.isFavorite = true;
            }
          });
          _projects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );
          if (setStateCallback != null) setStateCallback();
          Future.delayed(
            Duration.zero,
            () async {
              // try {
              //   getStudentFavoriteProject(false);
              // } catch (e) {
              //   // nothing changed
              //   print("error getting fav");
              // }
              print("favorite refess ${_favoriteProjects.projects!.length}");
              // _favoriteProjects.projects?.forEach(
              //   (element) {
              //     var p = _projects.projects?.firstWhereOrNull(
              //       (e) => e.objectId == element.objectId,
              //     );
              //     if (p != null) {
              //       p.isFavorite = true;
              //     }
              //   },
              // );
              _projects.projects?.sort(
                (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
              );
              if (_projects.projects != null) {
                refazynistKey.currentState?.refresh(
                    readyMade: _projects.projects!
                        .sublist(0, count.clamp(0, _projects.projects!.length))
                        .toList());
              }
              Future.delayed(Duration.zero, () async {
                var list = await datasource.getProjectsFromDb();
                _projects.projects?.forEach((element) {
                  datasource.insert(element);
                });
                list.projects?.forEach((element) {
                  if (_projects.projects?.firstWhereOrNull(
                        (e) => element.objectId == e.objectId,
                      ) ==
                      null) {
                    print("delete ${element.objectId}");
                    datasource.delete(element);
                  }
                });
              }).onError(
                (error, stackTrace) {
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
                  if (setStateCallback != null) setStateCallback();
                  if (_projects.projects != null) {
                    refazynistKey.currentState?.refresh(
                        readyMade: _projects.projects!
                            .sublist(
                                0, count.clamp(0, _projects.projects!.length))
                            .toList());
                  }
                },
              );
            },
          );
        } else {
          // try {
          //   await getStudentFavoriteProject(false);
          // } catch (e) {
          //   // nothing changed
          //   print("error getting fav");
          // }

          var list = await datasource.getProjectsFromDb();
          _projects.projects = list.projects;
          _projects.projects?.forEach(
            (element) => element.isLoading = false,
          );
          fav.projects?.forEach(
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
          if (setStateCallback != null) setStateCallback();

          if (_projects.projects != null) {
            refazynistKey.currentState?.refresh(
                readyMade: _projects.projects!
                    .sublist(0, count.clamp(0, _projects.projects!.length))
                    .toList());
          }
        }
      });

      // _projects = value;
    });
    return ProjectList(
      projects: List.filled(
        5,
        Project(
          title: "",
          description: "",
          timeCreated: DateTime.now(),
        ),
        growable: true,
      ),
    );
  }

  Future<ProjectList> getStudentFavoriteProject(bool force,
      {GlobalKey<RefazynistState>? refazynistKey}) async {
    try {
      if (force) {
        _getStudentFavoriteProjectUseCase.call(params: null).then((value) {
          _favoriteProjects = value;
          _favoriteProjects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );
          _favoriteProjects.projects?.forEach((element) {
            element.isLoading = false;
            element.isFavorite = true;
          });
          refazynistKey?.currentState?.refresh(
              readyMade: _favoriteProjects.projects!
                  .sublist(0, 5.clamp(0, _favoriteProjects.projects!.length))
                  .toList());

          return ProjectList(projects: []);
        });
      } else {
        if (_favoriteProjects.projects != null &&
            _favoriteProjects.projects!.isNotEmpty) {
          _favoriteProjects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );
          if (_favoriteProjects.projects != null) {
            refazynistKey?.currentState?.refresh(
                readyMade: _favoriteProjects.projects!
                    .sublist(0, 5.clamp(0, _favoriteProjects.projects!.length))
                    .toList());
          }
          return Future.value(ProjectList(projects: []));
        } else {
          _getStudentFavoriteProjectUseCase.call(params: null).then((value) {
            _favoriteProjects = value;
            _favoriteProjects.projects?.sort(
              (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
            );
            _favoriteProjects.projects?.forEach((element) {
              element.isLoading = false;
              element.isFavorite = true;
            });
            if (_favoriteProjects.projects != null) {
              refazynistKey?.currentState?.refresh(
                  readyMade: _favoriteProjects.projects!
                      .sublist(
                          0, 5.clamp(0, _favoriteProjects.projects!.length))
                      .toList());
            }
            return ProjectList(projects: []);
          });
        }
      }
    } catch (e) {
      print(e.toString());
      print("errror favorite");
      if (_favoriteProjects.projects != null) {
        refazynistKey?.currentState?.refresh(
            readyMade: _favoriteProjects.projects!
                .sublist(0, 5.clamp(0, _favoriteProjects.projects!.length))
                .toList());
      }
      return Future.value(ProjectList(projects: []));
    }

    return Future.value(ProjectList(
        projects: _favoriteProjects.projects!
            .sublist(0, 5.clamp(0, _favoriteProjects.projects!.length))
            .toList()));
  }

  @action
  Future<ProjectList> getProjectByCompany(String id,
      {Status? typeFlag, Function? setStateCallback}) async {
    print(
        "\n\n\n\n======================================\n GET PROJECT COMPANY ========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================\n\n\n\n\n\n\n");
    var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
    final GetProjectByCompanyParams loginParams =
        GetProjectByCompanyParams(companyId: id, typeFlag: typeFlag?.index);
    try {
      return _getProjectByCompanyUseCase.call(params: loginParams).then(
        (value) async {
          if (value.statusCode == HttpStatus.accepted ||
              value.statusCode == HttpStatus.ok ||
              value.statusCode == HttpStatus.created) {
            print(value);

            var result = ProjectList.fromJson(value.data["result"]);
            result.projects?.forEach((element) => element.proposal?.forEach(
                  (e) => e.project = StudentProject(
                      title: element.title,
                      description: element.description,
                      timeCreated: element.timeCreated,
                      id: element.objectId!,
                      projectId: element.objectId!),
                ));
            _companyProjects = result;

            sharedPrefsHelper.saveCompanyProjects(_companyProjects);

            _companyProjects.projects?.sort(
              (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
            );
            if (setStateCallback != null) setStateCallback();
            return _companyProjects;
          } else {
            print(value.data);
            var companies = await sharedPrefsHelper.getCompanyProjects();
            if (companies.projects != null && companies.projects!.isNotEmpty) {
              {
                _companyProjects = companies;
                _companyProjects.projects?.sort(
                  (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
                );
                if (setStateCallback != null) setStateCallback();

                return _companyProjects;
              }
            }
            return Future.value(ProjectList(projects: []));
          }
        },
      ).onError((error, stackTrace) async {
        var companies = await sharedPrefsHelper.getCompanyProjects();
        if (companies.projects != null && companies.projects!.isNotEmpty) {
          {
            _companyProjects = companies;
            _companyProjects.projects?.sort(
              (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
            );
            if (setStateCallback != null) setStateCallback();

            return _companyProjects;
          }
        }
        return Future.value(ProjectList(projects: []));
      });
    } catch (e) {
      // errorStore.errorMessage = "cannot save student profile";
      print("cannot get profile company");

      var companies = await sharedPrefsHelper.getCompanyProjects();
      if (companies.projects != null && companies.projects!.isNotEmpty) {
        {
          _companyProjects = companies;
          _companyProjects.projects?.sort(
            (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
          );
          if (setStateCallback != null) setStateCallback();
        }
      }
      return _companyProjects;
    }
    // //print(value);
  }

  /// lấy proposal của 1 project
  Future<ProposalList> getProjectProposals(Project project,
      {bool Function(Proposal)? filter}) async {
    return await _getProjectProposalsUseCase
        .call(params: project)
        .then((value) {
      project.proposal = value.proposals;
      currentProps.proposals = value.proposals;
      updateProjectList(project);
      if (filter != null) {
        value.proposals = value.proposals!.where(filter).toList();
      }
      return value;
    });
  }

  updateProjectList(Project project) async {
    if (_projects.projects == null) return;
    int index = _projects.projects!
        .indexWhere((element) => element.objectId == project.objectId);

    if (index != -1) {
      _projects.projects![index] = project;
    }
  }

  @action
  Future<ProposalList> getStudentProposalProjects(String studentId,
      {HireStatus? statusFlag, Function? setStateCallback}) async {
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
      return future.then<ProposalList>((value) async {
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
                (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
              );
            }
            if (setStateCallback != null) setStateCallback();

            return result;
          } catch (e) {
            // errorStore.errorMessage = "cannot save student profile";
            print("cannot get profile student ${e.toString()}");
            return ProposalList(proposals: []);
          }
        } else {
          print(value.data);
          var companies = await sharedPrefsHelper.getStudentProjects();

          if (companies.proposals != null && companies.proposals!.isNotEmpty) {
            {
              if (userStore.user != null &&
                  userStore.user!.studentProfile != null) {
                userStore.user!.studentProfile!.proposalProjects =
                    companies.proposals;
                userStore.user!.studentProfile!.proposalProjects?.sort(
                  (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
                );
              }
              if (setStateCallback != null) setStateCallback();

              return ProposalList(
                  proposals: userStore.user!.studentProfile!.proposalProjects);
            }
          }
          return ProposalList(proposals: []);
        }
        // //print(value);
      }).onError(
        (error, stackTrace) async {
          var companies = await sharedPrefsHelper.getStudentProjects();

          if (companies.proposals != null && companies.proposals!.isNotEmpty) {
            {
              if (userStore.user != null &&
                  userStore.user!.studentProfile != null) {
                userStore.user!.studentProfile!.proposalProjects =
                    companies.proposals;
                userStore.user!.studentProfile!.proposalProjects?.sort(
                  (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
                );
              }
              if (setStateCallback != null) setStateCallback();

              return companies;
            }
          }
          return Future.value(ProposalList(proposals: []));
        },
      );
    } catch (e) {
      var companies = await sharedPrefsHelper.getStudentProjects();

      if (companies.proposals != null && companies.proposals!.isNotEmpty) {
        {
          if (userStore.user != null &&
              userStore.user!.studentProfile != null) {
            userStore.user!.studentProfile!.proposalProjects =
                companies.proposals;
            userStore.user!.studentProfile!.proposalProjects?.sort(
              (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
            );
          }
          if (setStateCallback != null) setStateCallback();

          return companies;
        }
      }
      return Future.value(ProposalList(proposals: []));
    }
  }
}
