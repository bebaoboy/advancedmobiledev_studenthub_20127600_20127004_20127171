import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';

part 'profile_form_store.g.dart';

class ProfileFormStore = _ProfileFormStore with _$ProfileFormStore;

abstract class _ProfileFormStore with Store {
  final ProfileFormErrorStore profileFormErrorStore;

  final ErrorStore errorStore;

  _ProfileFormStore(this.profileFormErrorStore, this.errorStore) {
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

  @computed
  bool get canContinue =>
      !profileFormErrorStore.hasErrors &&
      companyName.isNotEmpty &&
      email.isNotEmpty;

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
  bool get hasErrors => hasErrorsInCompanyName || hasErrorsInEmail;
}
