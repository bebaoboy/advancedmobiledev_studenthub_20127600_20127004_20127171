import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/language/Language.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:mobx/mobx.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'language_store.g.dart';

class LanguageStore = _LanguageStore with _$LanguageStore;

abstract class _LanguageStore with Store {
  // static const String TAG = "LanguageStore";

  // repository instance
  final SettingRepository _repository;

  // store for handling errors
  final ErrorStore errorStore;

  // supported languages
  List<Language> supportedLanguages = [
    Language(code: 'US', locale: 'en', language: 'English'),
    // Language(code: 'DK', locale: 'da', language: 'Danish'),
    // Language(code: 'ES', locale: 'es', language: 'España'),
    Language(code: 'VI', locale: 'vi', language: 'Vietnamese'),
  ];

  // constructor:---------------------------------------------------------------
  _LanguageStore(this._repository, this.errorStore) {
    init();
  }

  // store variables:-----------------------------------------------------------
  @observable
  String _locale = "en";

  @computed
  String get locale => _locale;

  // actions:-------------------------------------------------------------------
  @action
  void changeLanguage(String value) {
    _locale = value;
    switch (_locale) {
      case 'vi':
        timeago.setLocaleMessages(_locale, timeago.ViMessages());
        break;
      default:
        timeago.setLocaleMessages(_locale, timeago.EnMessages());
        break;
    }
    _repository.changeLanguage(value).then((_) {
      // write additional logic here
    });
  }

  @action
  String getCode() {
    var code = "US";

    if (_locale == 'en') {
      code = "US";
    } else if (_locale == 'da') {
      code = "DK";
    } else if (_locale == 'es') {
      code = "ES";
    } else if (_locale == 'vi') {
      code = "VI";
    }

    return code;
  }

  @action
  String? getLanguage() {
    return supportedLanguages[supportedLanguages
            .indexWhere((language) => language.locale == _locale)]
        .language;
  }

  // general:-------------------------------------------------------------------
  void init() async {
    // getting current language from shared preference
    if (_repository.currentLanguage != null) {
      _locale = _repository.currentLanguage!;
      switch (_locale) {
        case 'vi':
          timeago.setLocaleMessages(_locale, timeago.ViMessages());
          break;
        default:
          timeago.setLocaleMessages(_locale, timeago.EnMessages());
          break;
      }
    }
  }

  // dispose:-------------------------------------------------------------------
  dispose() {}
}
