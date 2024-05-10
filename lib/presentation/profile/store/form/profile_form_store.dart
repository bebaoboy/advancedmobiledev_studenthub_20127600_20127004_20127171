// ignore_for_file: prefer_final_fields

import 'dart:io';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/update_profile_company_usecase.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';

part 'profile_form_store.g.dart';

class ProfileFormStore = _ProfileFormStore with _$ProfileFormStore;

abstract class _ProfileFormStore with Store {
  final ProfileFormErrorStore profileFormErrorStore;

  final ErrorStore errorStore;

  _ProfileFormStore(this.profileFormErrorStore, this.errorStore,
      this._addProfileCompanyUseCase, this._updateProfileCompanyUseCase) {
    _setupValidations();
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupValidations() {
    _disposers = [
      reaction((_) => companyName, validateCompanyName),
      reaction((_) => website, validateWebsite),
      reaction((_) => description, validateDescription),
      reaction((_) => profileName, validateProfileName),
      reaction((_) => email, validateEmail),
    ];
  }

  @observable
  String companyName = '';

  @observable
  String website = '';

  @observable
  String description = '';

  @observable
  String profileName = '';

  @observable
  String email = '';

  @observable
  CompanyScope scope = CompanyScope.solo;

  @observable
  bool success = false;

  //usecase
  AddProfileCompanyUseCase _addProfileCompanyUseCase;
  UpdateProfileCompanyUseCase _updateProfileCompanyUseCase;

  static ObservableFuture<void> emptyResponse = ObservableFuture.value(null);

  @observable
  ObservableFuture<void> addProfileCompanyFuture = emptyResponse;

  @computed
  bool get isLoading => addProfileCompanyFuture.status == FutureStatus.pending;

  @computed
  bool get canContinue =>
      !profileFormErrorStore.hasErrors && companyName.isNotEmpty;

  @action
  Future addProfileCompany(String companyName, String website,
      String description, CompanyScope size) async {
    final AddProfileCompanyParams loginParams = AddProfileCompanyParams(
        companyName: companyName,
        website: website,
        description: description,
        size: size.index,
        id: -1);
    final future = _addProfileCompanyUseCase.call(params: loginParams);
    addProfileCompanyFuture = ObservableFuture(future);

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;
        print(value.data);
        String? id;
        try {
          id = value.data["result"]["id"].toString();
        } catch (e) {
          errorStore.errorMessage = "cannot parse company id";
        }
        UserStore userStore = getIt<UserStore>();
        userStore.user!.companyProfile = CompanyProfile(
            companyName: companyName,
            profileName: companyName,
            email: "",
            website: website,
            description: description,
            scope: scope,
            objectId: id);
        var sharedPrefsHelper = getIt<SharedPreferenceHelper>();

        sharedPrefsHelper
            .saveCompanyProfile(CompanyProfile.fromMap(value.data["result"]));
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        print(value.data);
      }
    });
  }

  @action
  Future updateProfileCompany(String companyName, String website,
      String description, CompanyScope size, int id) async {
    final AddProfileCompanyParams loginParams = AddProfileCompanyParams(
        companyName: companyName,
        website: website,
        description: description,
        size: size.index,
        id: id);
    final future = _updateProfileCompanyUseCase.call(params: loginParams);
    addProfileCompanyFuture = ObservableFuture(future);

    await future.then((value) {
      if (value.statusCode == HttpStatus.accepted ||
          value.statusCode == HttpStatus.ok ||
          value.statusCode == HttpStatus.created) {
        success = true;
        print(value.data);
        UserStore userStore = getIt<UserStore>();
        userStore.user!.companyProfile =
            CompanyProfile.fromMap(value.data["result"]);
        var sharedPrefsHelper = getIt<SharedPreferenceHelper>();
        sharedPrefsHelper
            .saveCompanyProfile(CompanyProfile.fromMap(value.data["result"]));
        // ToDO: save profile to sharedpref
      } else {
        success = false;
        errorStore.errorMessage = value.data['errorDetails'] is List<String>
            ? value.data['errorDetails'][0].toString()
            : value.data['errorDetails'].toString();
        print(value.data);
      }
    });
  }

  // FUNCTION =======================

  @action
  void setCompanyName(String value) {
    companyName = value;
  }

  @action
  void setWebsite(String value) {
    website = value;
  }

  @action
  void setDescription(String value) {
    description = value;
  }

  @action
  void setProfileName(String value) {
    profileName = value;
  }

  @action
  void setEmail(String value) {
    email = value;
  }

  @action
  void setCompanyScope(CompanyScope value) {
    scope = value;
  }

  @action
  void validateCompanyName(String value) {
    if (value.isEmpty) {
      profileFormErrorStore.companyName = "Name can't be empty";
    } else {
      profileFormErrorStore.companyName = null;
    }
  }

  @action
  void validateWebsite(String value) {}

  @action
  void validateDescription(String value) {}

  @action
  void validateProfileName(String value) {}

  @action
  void validateEmail(String value) {
    if (value.isEmpty) {
      profileFormErrorStore.email = "Email can't be empty";
    } else if (!isEmail(value)) {
      profileFormErrorStore.email = 'Please enter a valid email address';
    } else {
      profileFormErrorStore.email = null;
    }
  }

  @action
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }

  void validateAll() {
    validateCompanyName(companyName);
    validateWebsite(website);
  }
}

class ProfileFormErrorStore = _ProfileFormErrorStore
    with _$ProfileFormErrorStore;

abstract class _ProfileFormErrorStore with Store {
  @observable
  String? companyName;

  @observable
  String? website;

  @observable
  String? description;

  @observable
  String? profileName;

  @observable
  String? email;

  @observable
  CompanyScope scope = CompanyScope.solo;

  @computed
  bool get hasErrorsInCompanyName => companyName != null;

  @computed
  bool get hasErrorsInEmail => email != null;

  @computed
  bool get hasErrors => hasErrorsInCompanyName;
}
