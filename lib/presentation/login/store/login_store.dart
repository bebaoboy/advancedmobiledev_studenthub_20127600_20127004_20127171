// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_company_usecase.dart';
import 'package:boilerplate/domain/usecase/project/get_student_favorite_project.dart';
import 'package:boilerplate/domain/usecase/user/auth/logout_usecase.dart';
import 'package:boilerplate/domain/usecase/user/auth/save_token_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/get_must_change_pass_usecase.dart';
import 'package:boilerplate/domain/usecase/user/get_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/user/get_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/user/set_user_profile_usecase.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';

part 'login_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  // constructor:---------------------------------------------------------------
  _UserStore(
    this._isLoggedInUseCase,
    this._saveLoginStatusUseCase,
    this._loginUseCase,
    this._saveUserDataUseCase,
    this._getMustChangePassUseCase,
    this.formErrorStore,
    this.errorStore,
    this._getUserDataUseCase,
    this._saveTokenUseCase,
    this._getProfileUseCase,
    this._logoutUseCase,
    this._setUserProfileUseCase,
    this._getStudentFavoriteProjectUseCase,
    this._getCompanyUseCase,
  ) {
    // setting up disposers
    _setupDisposers();

    // checking if user is logged in
    _isLoggedInUseCase.call(params: null).then((value) async {
      isLoggedIn = value;
    });

    _getUserDataUseCase.call(params: null).then((value) async {
      _user = value;
      if (_user != null) _user?.isVerified = true;
    });

    _getMustChangePassUseCase.call(params: null).then((value) {
      shouldChangePass = value.res;
    });

    // savedUsers.add(User(
    //     email: "user1@gmail.com",
    //     name: "Hai Pham",
    //     roles: [UserType.company, UserType.student],
    //     isVerified: true));
    savedUsers.add(User(
        email: "user2@gmail.com",
        name: "Hai Pham 2",
        roles: [],
        isVerified: true,
        objectId: "hai"));

    // savedUsers.add(User(
    //     email: "user3@gmail.com", name: "Hai Pham 3", roles: [], isVerified: true));
    // savedUsers.add(User(
    //     email: "user4@gmail.com", name: "Hai Pham 3", roles: [UserType.company]));
  }

  // public variable
  User? get user => _user;
  List<User> savedUsers = [];

  // use cases:-----------------------------------------------------------------
  final IsLoggedInUseCase _isLoggedInUseCase;
  final SaveLoginStatusUseCase _saveLoginStatusUseCase;
  final LoginUseCase _loginUseCase;
  final SaveUserDataUsecase _saveUserDataUseCase;
  final GetUserDataUseCase _getUserDataUseCase;
  final SaveTokenUseCase _saveTokenUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final SetUserProfileUseCase _setUserProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetMustChangePassUseCase _getMustChangePassUseCase;
  // ignore: unused_field
  final GetStudentFavoriteProjectUseCase _getStudentFavoriteProjectUseCase;
  final GetCompanyUseCase _getCompanyUseCase;

  // stores:--------------------------------------------------------------------
  // for handling form errors
  final FormErrorStore formErrorStore;

  // store for handling error messages
  final ErrorStore errorStore;

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [
      reaction((_) => success, (_) => success = false, delay: 200),
    ];
  }

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<Response?> emptyLoginResponse =
      ObservableFuture.value(null);

  // store variables:-----------------------------------------------------------
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  String notification = "";

  @observable
  bool shouldChangePass = false;

  @observable
  FetchProfileResult profileResult =
      FetchProfileResult(false, [], [], "", "", false);

  @observable
  User? _user;

  @observable
  ObservableFuture<Response?> loginFuture = emptyLoginResponse;

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future login(
      String email, String password, UserType type, List<UserType> roles,
      {fastSwitch = false}) async {
    // //print(UserType.company.name);
    final LoginParams loginParams =
        LoginParams(username: email, password: password);
    final future = _loginUseCase.call(params: loginParams);
    loginFuture = ObservableFuture(future);

    if (fastSwitch) {
      var value = User(email: email, roles: roles, type: type);
      isLoggedIn = true;
      success = true;
      _user = value;
      await _saveLoginStatusUseCase.call(params: true);
      await _saveUserDataUseCase.call(params: value);
    }

    await future.then((value) async {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.created ||
          value.statusCode == HttpStatus.ok) {
        success = true;

        if (value.data['result'] is! String &&
            value.data['result']['token'] != null) {
          await _saveTokenUseCase.call(params: value.data['result']['token']);
          await _saveLoginStatusUseCase.call(params: true);

          var userValue = User(
              // type: getUserType(type.name ?? UserType.naught.name),
              type: getUserType(type.name),
              email: email,
              roles: [],
              isVerified: true);

          isLoggedIn = true;

          profileResult = await _getProfileUseCase(params: true);

          if (profileResult.status) {
            userValue.companyProfile = profileResult.result[1] != null
                ? profileResult.result[1] as CompanyProfile
                : null;
            userValue.studentProfile = profileResult.result[0] != null
                ? profileResult.result[0] as StudentProfile
                : null;
            userValue.roles = profileResult.roles;
            userValue.isVerified = profileResult.isVerified;
            userValue.name = profileResult.name;
            userValue.objectId = profileResult.id;
          }

          // print(profileResult);

          _user = userValue;
          await _saveUserDataUseCase(
            params: _user,
          );

          savedUsers.add(_user!);
          _getMustChangePassUseCase.call(params: null).then((value) {
            shouldChangePass = value.res;
          });

          // _getStudentFavoriteProjectUseCase.call(params: null);
        } else {
          notification = value.data['result'];
        }
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
      }
    }).catchError((e) {
      print(e);
      isLoggedIn = false;
      success = false;
      //throw e;
    });
  }

  Future<bool> fetchUserProfileIfLoggedIn() async {
    print('in background fetch');
    _setUserProfileUseCase.call(params: null).then((value) async {
      if (value != null) {
        if (_user != null) {
          _user?.companyProfile =
              value[1] != null ? value[1] as CompanyProfile : null;
          _user?.studentProfile =
              value[0] != null ? value[0] as StudentProfile : null;
          return Future.value(true);
        }
      }
      return Future.value(false);
    }).onError((error, stackTrace) => Future.value(false));
    return Future.value(true);
  }

  @action
  Future<CompanyProfile?> getCompanyProfile(String id) async {
    try {
      return await _getCompanyUseCase
          .call(
              params: AddProfileCompanyParams(
                  companyName: "",
                  website: "",
                  description: "",
                  size: 0,
                  id: int.tryParse(id) ??
                      (int.tryParse(user?.companyProfile?.objectId ?? "1") ??
                          1)))
          .then(
        (value) {
          print(value);
          return CompanyProfile.fromMap(value.data["result"]);
        },
      );
    } catch (e) {
      print("error company id $id");
      return null;
    }
  }

  @action
  Future logout() async {
    isLoggedIn = false;
    if (_user != null) {
      savedUsers.removeWhere((e) => e.objectId == _user!.objectId);
    }
    _user = null;

    await _logoutUseCase.call(params: true);
  }

  @action
  UserType getCurrentType() {
    return user?.type ?? UserType.naught;
  }

  @action
  addNewProposal(Proposal proposal) async {
    if (_user == null || _user!.studentProfile == null) return;
    if (_user!.studentProfile!.proposalProjects == null) {
      _user!.studentProfile!.proposalProjects = List.empty(growable: true);
    }
    _user?.studentProfile?.proposalProjects!.add(proposal);
  }

  // general methods:-----------------------------------------------------------
  @action
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
