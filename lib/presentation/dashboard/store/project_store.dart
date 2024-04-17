import 'dart:io';

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
import 'package:boilerplate/domain/usecase/proposal/post_proposal.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:collection/collection.dart';
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
  ) {
    // _getStudentFavoriteProjectUseCase.call(params: null).then((value) {
    //   _favoriteProjects = value;
    // });
  }

  // company
  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByCompanyUseCase _getProjectByCompanyUseCase;

  // student
  final GetStudentProposalProjectsUseCase _getStudentProposalProjectsUseCase;
  final GetStudentFavoriteProjectUseCase _getStudentFavoriteProjectUseCase;
  final SaveStudentFavoriteProjectUseCase _saveStudentFavoriteProjectUseCase;
  final PostProposalUseCase _postProposalUseCase;

  @observable
  ProjectList _projects = ProjectList(projects: List.empty(growable: true));

  List<Project> get projects => _projects.projects ?? [];

  @observable
  ProjectList _companyProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get companyProjects => _companyProjects.projects ?? [];

  @observable
  ProjectList _studentProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get studentProjects => _studentProjects.projects ?? [];

  @observable
  ProjectList _favoriteProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get favoriteProjects => _favoriteProjects.projects ?? [];

  @observable
  bool postSuccess = false;

  Future addProject(Project value, {index = 0}) async {
    if (_projects.projects != null) {
      value.updatedAt = DateTime.now();
      _projects.projects!.insert(index, value);
    } else {
      _projects.projects = [value];
    }
    _projects.projects?.sort(
      (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
    );
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

  Future<bool> postProposal(StudentProject project, String studentId) async {
    int status = 0;
    int disableFlag = 0;

    var params = PostProposalParams(status, disableFlag, project.description,
        int.parse(project.objectId!), int.parse(studentId));
    return await _postProposalUseCase.call(params: params).then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        _studentProjects.projects!.add(project);
        return true;
      } else {
        return false;
      }
    });
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
  Future<ProjectList> getAllProject() async {
    try {
      await getStudentFavoriteProject(false);
    } catch (e) {
      // nothing changed
    }
    return await _getProjectsUseCase
        .call(params: GetProjectParams())
        .then((value) {
      _projects = value;
      for (var element in _favoriteProjects.projects!) {
        var p = _projects.projects!.firstWhereOrNull(
          (e) => e.objectId == element.objectId,
        );
        if (p != null) {
          p.isFavorite = true;
        }
      }
      _projects.projects?.sort(
        (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
      );
      return _projects;
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
