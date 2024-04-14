// ignore_for_file: prefer_final_fields

import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/usecase/user/auth/sign_up_usecase.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';

part "signup_store.g.dart";

class SignupStore = _SignupStore with _$SignupStore;

abstract class _SignupStore with Store {
  // store for handling form errors
  final SignUpFormErrorStore signUpFormErrorStore;

  // store for handling error messages
  final ErrorStore errorStore;

  _SignupStore(
    this._signUpUseCase,
    this.signUpFormErrorStore,
    this.errorStore,
  ) {
    _setupValidations();
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupValidations() {
    _disposers = [
      reaction((_) => email, validateUserEmail),
      reaction((_) => password, validatePassword),
      reaction((_) => repeatPassword, validateConfirmPassword)
    ];
  }

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<void> emptySignUpResponse =
      ObservableFuture.value(null);

  //public variable
  UserType? get userType => _userType;

  //store variable
  @observable
  bool success = false;

  @observable
  UserType? _userType;

  @observable
  String name = "";

  @observable
  String email = "";

  @observable
  String password = "";

  @observable
  String repeatPassword = "";

  @observable
  bool hasAcceptPolicy = false;

  //usecase
  final SignUpUseCase _signUpUseCase;

  @observable
  ObservableFuture<void> signUpFuture = emptySignUpResponse;

  @computed
  bool get isLoading => signUpFuture.status == FutureStatus.pending;

  @computed
  bool get canRegister =>
      !signUpFormErrorStore.hasErrorsInRegister &&
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      repeatPassword.isNotEmpty &&
      hasAcceptPolicy == true;

  //actions
  @action
  setUserType(UserType type) {
    _userType = type;
  }

  @action
  changeAcceptState() {
    hasAcceptPolicy = !hasAcceptPolicy;
  }

  @action
  setEmail(String value) {
    email = value;
  }

  @action
  setPassword(String value) {
    password = value;
  }

  @action
  setConfirmPassword(String value) {
    repeatPassword = value;
  }

  @action
  setFullname(String value) {
    name = value;
  }

  @action
  signUp(String fullname, String email, String password,
      {bool fastSwitch = false}) async {
    final SignUpParams signUpParams = SignUpParams(
        fullname: fullname, email: email, password: password, type: _userType);
    final future = _signUpUseCase.call(params: signUpParams);

    signUpFuture = ObservableFuture(future);

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'][0].toString();
        // print(value.data);
      }
    });
  }

  @action
  void validateUserEmail(String value) {
    if (value.isEmpty) {
      signUpFormErrorStore.email = "Email can't be empty";
    } else if (!isEmail(value)) {
      signUpFormErrorStore.email = 'Please enter a valid email address';
    } else {
      signUpFormErrorStore.email = null;
    }
  }

  @action
  void validatePassword(String value) {
    if (value.isEmpty) {
      signUpFormErrorStore.password = "Password can't be empty";
    } else if (value.length < 8) {
      signUpFormErrorStore.password =
          "Password must be at-least 8 characters long";
    } else {
      signUpFormErrorStore.password = null;
    }
  }

  @action
  void validateConfirmPassword(String value) {
    if (value.isEmpty) {
      signUpFormErrorStore.repeatPassword = "Confirm password can't be empty";
    } else if (value != password) {
      signUpFormErrorStore.repeatPassword = "Password doesn't match";
    } else {
      signUpFormErrorStore.repeatPassword = null;
    }
  }

  // general methods:-----------------------------------------------------------
  @action
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }

  void validateAll() {
    validatePassword(password);
    validateUserEmail(email);
  }
}

class SignUpFormErrorStore = _SignUpFormErrorStore with _$SignUpFormErrorStore;

abstract class _SignUpFormErrorStore with Store {
  @observable
  String? fullname;

  @observable
  String? email;

  @observable
  String? password;

  @observable
  String? repeatPassword;

  @computed
  bool get hasErrorsInRegister =>
      email != null ||
      password != null ||
      repeatPassword != null ||
      fullname != null;
}
