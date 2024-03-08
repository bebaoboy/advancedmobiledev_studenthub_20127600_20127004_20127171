import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

part 'profile_form_store.g.dart';

class ProfileFormStore = _ProfileFormStore with _$ProfileFormStore;

abstract class _ProfileFormStore with Store{

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
      reaction((_) => website, validateWebsite)
    ];
  }

  @observable
  String companyName = '';

  @observable
  String website = '';

  @observable
  String description = '';

  @action
  void setCompanyName(String value){
    companyName = value;
  }

  @action
  void setWebsite(String value){
    website = value;
  }

  @action
  void setDescription(String value){
    description = value;
  }


  @action
  void validateCompanyName(String value){

  }

  @action
  void validateWebsite(String value){

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

class ProfileFormErrorStore = _ProfileFormErrorStore with _$ProfileFormErrorStore;

abstract class _ProfileFormErrorStore with Store {
  @observable
  String? companyName;

  @observable
  String? website;

  @computed
  bool get hasErrorsInCompanyName => companyName != null;
}
