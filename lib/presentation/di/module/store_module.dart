import 'dart:async';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:boilerplate/domain/usecase/post/get_post_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_education_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_experience_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_language_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_resume.dart';
import 'package:boilerplate/domain/usecase/profile/get_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/get_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/get_transcript.dart';
import 'package:boilerplate/domain/usecase/profile/update_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/user/auth/logout_usecase.dart';
import 'package:boilerplate/domain/usecase/user/auth/save_token_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_profile_student_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/add_skillset.dart';
import 'package:boilerplate/domain/usecase/profile/add_techstack.dart';
import 'package:boilerplate/domain/usecase/profile/update_education.dart';
import 'package:boilerplate/domain/usecase/profile/update_language.dart';
import 'package:boilerplate/domain/usecase/profile/update_profile_company_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/update_projectexperience.dart';
import 'package:boilerplate/domain/usecase/profile/update_resume.dart';
import 'package:boilerplate/domain/usecase/profile/update_transcript.dart';
import 'package:boilerplate/domain/usecase/user/auth/sign_up_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/change_password_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/get_must_change_pass_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/has_to_change_pass_usecase.dart';
import 'package:boilerplate/domain/usecase/user/forgetPass/send_reset_password_mail_usecase.dart';
import 'package:boilerplate/domain/usecase/user/get_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/user/get_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/user/set_user_profile_usecase.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/forget_password_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/post/store/post_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_form_store.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_info_store.dart';
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
    getIt.registerFactory(() => ForgetPasswordFormErrorStore());
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
        getIt<GetMustChangePassUseCase>(),
        getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
        getIt<GetUserDataUseCase>(),
        getIt<SaveTokenUseCase>(),
        getIt<GetProfileUseCase>(),
        getIt<LogoutUseCase>(),
        getIt<SetUserProfileUseCase>(),
      ),
    );

    getIt.registerSingleton<SignupStore>(
      SignupStore(getIt<SignUpUseCase>(), getIt<SignUpFormErrorStore>(),
          getIt<ErrorStore>()),
    );

    getIt.registerSingleton<ForgetPasswordStore>(ForgetPasswordStore(
      getIt<ForgetPasswordFormErrorStore>(),
      getIt<ErrorStore>(),
      getIt<ChangePasswordUseCase>(),
      getIt<SendResetPasswordMailUseCase>(),
      getIt<HasToChangePassUseCase>(),
      getIt<GetMustChangePassUseCase>(),
    ));

    getIt.registerSingleton<ProfileFormStore>(ProfileFormStore(
        getIt<ProfileFormErrorStore>(),
        getIt<ErrorStore>(),
        getIt<AddProfileCompanyUseCase>(),
        getIt<UpdateProfileCompanyUseCase>()));

    getIt.registerSingleton<ProfileStudentFormStore>(ProfileStudentFormStore(
      getIt<ProfileStudentFormErrorStore>(),
      getIt<ErrorStore>(),
      getIt<AddProfileStudentUseCase>(),
      getIt<GetProfileStudentUseCase>(),
      getIt<UpdateProfileStudentUseCase>(),
      getIt<AddTechStackUseCase>(),
      getIt<AddSkillsetUseCase>(),
      getIt<UpdateLanguageUseCase>(),
      getIt<UpdateEducationUseCase>(),
      getIt<UpdateProjectExperienceUseCase>(),
      getIt<UpdateResumeUseCase>(),
      getIt<GetResumeUseCase>(),
      getIt<UpdateTranscriptUseCase>(),
      getIt<GetTranscriptUseCase>(),
    ));

    getIt.registerSingleton<ProfileStudentStore>(ProfileStudentStore(
      getIt<GetEducationUseCase>(),
      getIt<GetExperienceUseCase>(),
      getIt<GetLanguageUseCase>(),
      getIt<GetTechStackUseCase>(),
      getIt<GetSkillsetUseCase>(),
    ));

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
