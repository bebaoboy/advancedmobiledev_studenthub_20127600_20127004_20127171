import 'dart:io';

import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/entity/project/proposal_list.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
import 'package:boilerplate/domain/usecase/project/get_projects.dart';
import 'package:boilerplate/domain/usecase/project/get_student_proposal_projects.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:mobx/mobx.dart';

part 'project_store.g.dart';

class ProjectStore = _ProjectStore with _$ProjectStore;

abstract class _ProjectStore with Store {
  _ProjectStore(this._getProjectsUseCase, this._getProjectByCompanyUseCase,
      this._getStudentProposalProjectsUseCase) {
    // getAllProject();
  }

  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByCompanyUseCase _getProjectByCompanyUseCase;
  final GetStudentProposalProjectsUseCase _getStudentProposalProjectsUseCase;

  @observable
  ProjectList _projects = ProjectList(projects: List.empty(growable: true));

  List<Project> get projects => _projects.projects ?? [];

  @observable
  ProjectList _companyProjects =
      ProjectList(projects: List.empty(growable: true));

  List<Project> get companyProjects => _companyProjects.projects ?? [];

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
  Future<ProjectList> getAllProject() async {
    return await _getProjectsUseCase
        .call(params: GetProjectParams())
        .then((value) {
      _projects = value;
      _projects.projects?.sort(
        (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
      );
      return _projects;
    });
  }

  @action
  Future<ProjectList> getProjectByCompany(String id, {Status? typeFlag}) async {
    print(
        "\n\n\n\n======================================\n GET PROJECT COMPANY ========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================\n\n\n\n\n\n\n");
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
    final future = _getStudentProposalProjectsUseCase.call(params: loginParams);
    return await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        print(value);
        try {
          var result = ProposalList.fromJson(value.data["result"]);
          var userStore = getIt<UserStore>();
          if (userStore.user != null &&
              userStore.user!.studentProfile != null) {
            userStore.user!.studentProfile!.proposalProjects = result.proposals;
          }
          userStore.user!.studentProfile!.proposalProjects?.sort(
            (a, b) => b.createdAt!.compareTo(a.createdAt!),
          );
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
  }
}
