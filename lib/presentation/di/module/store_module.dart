import 'dart:async';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:boilerplate/domain/usecase/post/get_post_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/update_language.dart';
import 'package:boilerplate/domain/usecase/user/auth/sign_up_usecase.dart';
import 'package:boilerplate/domain/usecase/user/get_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_user_data_usecase.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/post/store/post_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_form_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_student_form_store.dart';
import 'package:boilerplate/presentation/signup/store/signup_store.dart';

import '../../../di/service_locator.dart';

mixin StoreModule {
  static Future<void> configureStoreModuleInjection() async {
    // factories:---------------------------------------------------------------
    getIt.registerFactory(() => ErrorStore());
    getIt.registerFactory(() => FormErrorStore());
    getIt.registerFactory(
      () => FormStore(getIt<FormErrorStore>(), getIt<ErrorStore>()),
    );
    getIt.registerFactory(
      () => ProfileFormErrorStore(),
    );
    getIt.registerFactory(
      () => ProfileStudentFormErrorStore(),
    );
    getIt.registerFactory(() => SignUpFormErrorStore());


    // stores:------------------------------------------------------------------
    getIt.registerSingleton<UserStore>(
      UserStore(
        getIt<IsLoggedInUseCase>(),
        getIt<SaveLoginStatusUseCase>(),
        getIt<LoginUseCase>(),
        getIt<SaveUserDataUsecase>(),
        getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
        getIt<GetUserDataUseCase>(),
      ),
    );

    getIt.registerSingleton<SignupStore>(
      SignupStore(getIt<SignUpUseCase>(), getIt<SignUpFormErrorStore>(),
          getIt<ErrorStore>()),
    );

    getIt.registerSingleton<ProfileFormStore>(ProfileFormStore(
        getIt<ProfileFormErrorStore>(),
        getIt<ErrorStore>(),
        getIt<AddProfileCompanyUseCase>()));

    getIt.registerSingleton<ProfileStudentFormStore>(ProfileStudentFormStore(
        getIt<ProfileStudentFormErrorStore>(),
        getIt<ErrorStore>(),
        getIt<AddProfileStudentUseCase>(),
        getIt<AddTechStackUseCase>(),
        getIt<AddSkillsetUseCase>(),
        getIt<UpdateLanguageUseCase>()));

    getIt.registerSingleton<PostStore>(
      PostStore(
        getIt<GetPostUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ThemeStore>(
      ThemeStore(
        getIt<SettingRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<LanguageStore>(
      LanguageStore(
        getIt<SettingRepository>(),
        getIt<ErrorStore>(),
      ),
    );
  }
}
