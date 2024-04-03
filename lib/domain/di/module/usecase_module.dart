import 'dart:async';

import 'package:boilerplate/domain/repository/post/post_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/post/delete_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/find_post_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/post/get_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/insert_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/udpate_post_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_education_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_experience_usecase.dart';
import 'package:boilerplate/domain/usecase/profile/get_language_usecase.dart';
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

import '../../../di/service_locator.dart';

mixin UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
    // user:--------------------------------------------------------------------
    getIt.registerSingleton<IsLoggedInUseCase>(
      IsLoggedInUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SaveLoginStatusUseCase>(
      SaveLoginStatusUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SignUpUseCase>(
      SignUpUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SaveTokenUseCase>(
      SaveTokenUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<AddProfileCompanyUseCase>(
      AddProfileCompanyUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<UpdateProfileCompanyUseCase>(
      UpdateProfileCompanyUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<AddProfileStudentUseCase>(
      AddProfileStudentUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<AddTechStackUseCase>(
      AddTechStackUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<AddSkillsetUseCase>(
      AddSkillsetUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<UpdateLanguageUseCase>(
      UpdateLanguageUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<GetLanguageUseCase>(
        GetLanguageUseCase(getIt<UserRepository>()));

    getIt.registerSingleton<UpdateEducationUseCase>(
      UpdateEducationUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<GetEducationUseCase>(
        GetEducationUseCase(getIt<UserRepository>()));

    getIt.registerSingleton<UpdateProjectExperienceUseCase>(
      UpdateProjectExperienceUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<GetExperienceUseCase>(
        GetExperienceUseCase(getIt<UserRepository>()));

    getIt.registerSingleton<UpdateTranscriptUseCase>(
      UpdateTranscriptUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<UpdateResumeUseCase>(
      UpdateResumeUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<GetUserDataUseCase>(
      GetUserDataUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SaveUserDataUsecase>(
      SaveUserDataUsecase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SetUserProfileUseCase>(
      SetUserProfileUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<GetProfileUseCase>(
      GetProfileUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<LogoutUseCase>(
      LogoutUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<ChangePasswordUseCase>(
      ChangePasswordUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SendResetPasswordMailUseCase>(
      SendResetPasswordMailUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<GetMustChangePassUseCase>(
      GetMustChangePassUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<HasToChangePassUseCase>(
      HasToChangePassUseCase(getIt<UserRepository>()),
    );

    // post:--------------------------------------------------------------------
    getIt.registerSingleton<GetPostUseCase>(
      GetPostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<FindPostByIdUseCase>(
      FindPostByIdUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<InsertPostUseCase>(
      InsertPostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<UpdatePostUseCase>(
      UpdatePostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<DeletePostUseCase>(
      DeletePostUseCase(getIt<PostRepository>()),
    );
  }
}
