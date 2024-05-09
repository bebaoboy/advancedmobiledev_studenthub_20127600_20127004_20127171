import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobx/mobx.dart';

part 'theme_store.g.dart';

class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store {
  final String TAG = "_ThemeStore";

  // repository instance
  final SettingRepository _repository;

  // store for handling errors
  final ErrorStore errorStore;

  // store variables:-----------------------------------------------------------
  @observable
  bool _darkMode = false;

  @observable
  bool systemTheme = false;

  // getters:-------------------------------------------------------------------
  @computed
  bool get darkMode => _darkMode;

  // constructor:---------------------------------------------------------------
  _ThemeStore(this._repository, this.errorStore) {
    init();
  }

  // actions:-------------------------------------------------------------------
  @action
  Future changeBrightnessToDark(bool? value) async {
    if (value != null) {
      _darkMode = value;
      systemTheme = false;
      await _repository.changeBrightnessToDark(value);
    } else {
      systemTheme = true;
      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      _darkMode = brightness == Brightness.dark;
      final SharedPreferenceHelper sharedPrefsHelper =
          getIt<SharedPreferenceHelper>();

      sharedPrefsHelper.changeBrightnessToDark(null);
    }
  }

  @action
  Future autoChangeBrightness(bool value) async {
    if (value != _darkMode) {
      _darkMode = value;
      await _repository.changeBrightnessToDark(value);
    }
  }

  // general methods:-----------------------------------------------------------
  Future init() async {
    try {
      var d = _repository.isDarkMode;
      if (d == null) {
        systemTheme = true;
        var brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        _darkMode = brightness == Brightness.dark;
      } else {
        systemTheme = false;
        _darkMode = _repository.isDarkMode!;
      }
    } catch (e) {
      _darkMode = false;
      systemTheme = false;
    }
  }

  bool isPlatformDark(BuildContext context) => systemTheme &&
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;

  // dispose:-------------------------------------------------------------------
  // @override
  // dispose() {}
}
