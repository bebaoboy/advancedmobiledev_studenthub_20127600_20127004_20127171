import 'dart:io';

import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:boilerplate/domain/usecase/project/get_project_by_company.dart';
import 'package:boilerplate/domain/usecase/project/get_projects.dart';
import 'package:mobx/mobx.dart';

part 'project_store.g.dart';

class ProjectStore = _ProjectStore with _$ProjectStore;

abstract class _ProjectStore with Store {
  _ProjectStore(this._getProjectsUseCase, this._getProjectByCompanyUseCase) {
    // getAllProject();
  }

  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByCompanyUseCase _getProjectByCompanyUseCase;

  @observable
  ProjectList _projects = ProjectList(projects: List.empty());

  List<Project> get projects => _projects.projects ?? [];

  @observable
  ProjectList _companyProjects = ProjectList(projects: List.empty());

  List<Project> get companyProjects => _companyProjects.projects ?? [];

  Future addProject(Project value, {index = 0}) async {
    if (_projects.projects != null) {
      _projects.projects!.insert(index, value);
    } else {
      _projects.projects = [value];
    }
  }

  /// descending created date order
  Future getAllProject() {
    // TODO: gọi hàm này mỗi khi bấm navbar 2 lần
    return _getProjectsUseCase.call(params: null).then((value) {
      _projects = value;
      _projects.projects?.sort(
        (a, b) => b.timeCreated.compareTo(a.timeCreated),
      );
    });
  }

  @action
  Future getProjectByCompany(String id, {Status? typeFlag}) async {
    print(
        "\n\n\n\n======================================\n GET PROJECT COMPANY ========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================\n\n\n\n\n\n\n");
    final GetProjectByCompanyParams loginParams =
        GetProjectByCompanyParams(companyId: id, typeFlag: typeFlag?.index);
    final future = _getProjectByCompanyUseCase.call(params: loginParams);
    // addProfileStudentFuture = ObservableFuture(future);
    // var userStore = getIt<UserStore>();

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        print(value);
        try {
          var result = ProjectList.fromJson(value.data["result"]);
          _companyProjects = result;
          // if (userStore.user != null &&
          //     userStore.user!.studentProfile != null) {
          //   userStore.user!.studentProfile!.fullName =
          //       value.data["result"]["fullname"];
          //   userStore.user!.studentProfile!.techStack =
          //   //     TechStack.fromJson(value.data["result"]["techStack"]);
          //   // techStack = userStore.user!.studentProfile!.techStack;
          //   // if (value.data["result"]["skillSets"] != null) {
          //   //   var ssList = value.data["result"]["skillSets"] as List;
          //   //   userStore.user!.studentProfile!.skillSet = [];
          //   //   for (var element in ssList) {
          //   //     userStore.user!.studentProfile!.skillSet!
          //   //         .add(Skill.fromMap(element));
          //   //   }
          //   //   skillSet = userStore.user!.studentProfile!.skillSet!;
          //   // }
          // }
          // TODO: lưu vào sharedpref
        } catch (e) {
          // errorStore.errorMessage = "cannot save student profile";
          print("cannot get profile company");
        }
      } else {
        // success = false;
        // errorStore.errorMessage = value.data['errorDetails'] is List<String>
        //     ? value.data['errorDetails'][0].toString()
        //     : value.data['errorDetails'].toString();
        print(value.data);
      }
      // //print(value);
    });
  }
}
