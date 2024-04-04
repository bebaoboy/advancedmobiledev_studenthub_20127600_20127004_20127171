import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/change_password_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/get_must_change_pass_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/has_to_change_pass_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/send_reset_password_mail_usecase.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';

part 'forget_password_store.g.dart';

class ForgetPasswordStore = _ForgetPasswordStore with _$ForgetPasswordStore;

abstract class _ForgetPasswordStore with Store {
  ForgetPasswordFormErrorStore formErrorStore;
  ErrorStore errorStore;

  _ForgetPasswordStore(
      this.formErrorStore,
      this.errorStore,
      this._changePasswordUseCase,
      this._sendResetPasswordMailUseCase,
      this._saveHasToChangePassUseCase,
      this._getMustChangePassUseCase) {
    _setupDisposer();
    _getMustChangePassUseCase
        .call(params: null)
        .then((value) => {_oldPassword = value.oldPass});
  }

  //use case
  final SendResetPasswordMailUseCase _sendResetPasswordMailUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final HasToChangePassUseCase _saveHasToChangePassUseCase;
  final GetMustChangePassUseCase _getMustChangePassUseCase;

  // disposer
  late List<ReactionDisposer> _disposers;

  _setupDisposer() {
    _disposers = [
      reaction((_) => email, validateEmail),
      reaction((_) => newPassword, validateNewPassword),
      reaction((_) => _oldPassword, validateOldPassword),
      reaction((_) => confirmNewPassword, validateConfirmNewPassword)
    ];
  }

  //observable
  @observable
  String email = "";

  @observable
  String newPassword = "";

  @observable
  String confirmNewPassword = "";

  @observable
  String _oldPassword = "";

  @observable
  bool mailSentSuccess = false;

  @observable
  bool changePassSuccess = false;

  @computed
  bool get canSendEmail =>
      email.isNotEmpty && !formErrorStore.hasErrorInEmail();

  @computed
  bool get canResetPassword =>
      newPassword.isNotEmpty &&
      confirmNewPassword.isNotEmpty &&
      !formErrorStore.hasErrorInPassword();

  // function
  Future sendMail() async {
    var response = await _sendResetPasswordMailUseCase.call(params: email);

    if (response.statusCode == HttpStatus.accepted ||
        response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      mailSentSuccess = true;
    } else {
      mailSentSuccess = false;
    }
  }

  Future changePassword() async {
    //ToDo change 1st param to old password
    ChangePasswordParams params =
        ChangePasswordParams(_oldPassword, newPassword);
    var response = await _changePasswordUseCase.call(params: params);
    print(response.data);
    if (response.statusCode == HttpStatus.accepted ||
        response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      changePassSuccess = true;
      mailSentSuccess = false;
      _saveHasToChangePassUseCase.call(params: ChangePassParams('', false));
    } else {
      changePassSuccess = false;
      errorStore.errorMessage = response.data['errorDetails'].toString();
    }
  }

  Future saveShouldChangePass() async {
    if (mailSentSuccess) {
      var params = ChangePassParams(_oldPassword, true);
      _saveHasToChangePassUseCase.call(params: params);
    }
  }

  // action
  @action
  void setEmail(String value) {
    email = value;
  }

  @action
  void setNewPassword(String value) {
    newPassword = value;
  }

  @action
  void setNewConfirmPassword(String value) {
    confirmNewPassword = value;
  }

  @action
  void setOldPassword(String value) {
    _oldPassword = value;
  }

  @action
  void validateEmail(String value) {
    if (value.isEmpty) {
      formErrorStore.email = "Email can't be empty";
    } else if (!isEmail(value)) {
      formErrorStore.email = 'Please enter a valid email address';
    } else {
      formErrorStore.email = null;
    }
  }

  @action
  void validateNewPassword(String value) {
    if (value.isEmpty) {
      formErrorStore.newPassword = "Password can't be empty";
    } else if (value.length < 8) {
      formErrorStore.newPassword =
          "Password must be at-least 8 characters long";
    } else {
      formErrorStore.newPassword = null;
    }
  }

  @action
  void validateConfirmNewPassword(String value) {
    if (value.isEmpty) {
      formErrorStore.confirmNewPassword = "Confirm password can't be empty";
    } else if (value != newPassword) {
      formErrorStore.confirmNewPassword = "Password doesn't match";
    } else {
      formErrorStore.confirmNewPassword = null;
    }
  }

  @action
  void validateOldPassword(String value) {
    if (value.isEmpty) {
      formErrorStore.oldPassword = "Confirm password can't be empty";
    } else if (value.length < 8) {
      formErrorStore.oldPassword = "Password doesn't match";
    } else {
      formErrorStore.oldPassword = null;
    }
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}

class ForgetPasswordFormErrorStore = _ForgetPasswordFormErrorStore
    with _$ForgetPasswordFormErrorStore;

abstract class _ForgetPasswordFormErrorStore with Store {
  @observable
  String? email;

  @observable
  String? newPassword;

  @observable
  String? confirmNewPassword;

  @observable
  String? oldPassword;

  @action
  hasErrorInEmail() {
    return email != null;
  }

  @action
  hasErrorInPassword() {
    return newPassword != null || confirmNewPassword != null;
  }
}
