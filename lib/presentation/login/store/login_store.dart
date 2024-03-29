import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/usecase/user/auth/sign_up_usecase.dart';
import 'package:boilerplate/domain/usecase/user/get_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_user_data_usecase.dart';
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
    this._signUpUseCase,
    this.formErrorStore,
    this.errorStore,
    this._getUserDataUseCase,
  ) {
    // setting up disposers
    _setupDisposers();

    // checking if user is logged in
    _isLoggedInUseCase.call(params: null).then((value) async {
      isLoggedIn = value;
    });

    _getUserDataUseCase.call(params: null).then((value) async {
      _user = value;
    });

    savedUsers.add(User(
        email: "user1@gmail.com", type: UserType.company, name: "Hai Pham"));
    savedUsers.add(User(
        email: "user2@gmail.com", type: UserType.company, name: "Hai Pham 2"));
    savedUsers.add(User(
        email: "user3@gmail.com", type: UserType.student, name: "Student 1"));
    savedUsers.add(User(
        email: "user4@gmail.com", type: UserType.student, name: "Student 2"));
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
  final SignUpUseCase _signUpUseCase;

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
  static ObservableFuture<User?> emptyLoginResponse =
      ObservableFuture.value(null);

  // store variables:-----------------------------------------------------------
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  User? _user;

  @observable
  ObservableFuture<User?> loginFuture = emptyLoginResponse;

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future login(String email, String password, UserType userType,
      {fastSwitch = false}) async {
    // TODO change userType to debug company or student
    // //print(UserType.company.name);
    final LoginParams loginParams = LoginParams(
        username: email, password: password, userType: userType.name);
    final future = _loginUseCase.call(params: loginParams);
    loginFuture = ObservableFuture(future);

    if (fastSwitch) {
      var value = User(email: email, type: userType);
      await _saveLoginStatusUseCase.call(params: true);
      await _saveUserDataUseCase.call(params: value);
      isLoggedIn = true;
      success = true;
      _user = value;
      return;
    }

    await future.then((value) async {
      if (value != null) {
        await _saveLoginStatusUseCase.call(params: true);
        await _saveUserDataUseCase.call(params: value);
        isLoggedIn = true;
        success = true;
        _user = value;
      }
    }).catchError((e) {
      //print(e);
      isLoggedIn = false;
      success = false;
      throw e;
    });
  }

  signUp(String email, String password, UserType userType,
      {fastSwitch = false}) async {
    final LoginParams loginParams = LoginParams(
        username: email, password: password, userType: userType.name);
    final future = _signUpUseCase.call(params: loginParams);
    await future.then((value) => print(value.toString()));
  }

  logout() async {
    isLoggedIn = false;
    _user = null;
    await _saveLoginStatusUseCase.call(params: false);
    await _saveUserDataUseCase.call(params: null);
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
