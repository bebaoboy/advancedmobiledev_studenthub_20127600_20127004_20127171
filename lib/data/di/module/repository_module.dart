import 'dart:async';

import 'package:boilerplate/data/local/datasources/chat/chat_datasource.dart';
import 'package:boilerplate/data/local/datasources/post/post_datasource.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/network/apis/chat/chat_api.dart';
import 'package:boilerplate/data/network/apis/interview/interview_api.dart';
import 'package:boilerplate/data/network/apis/noti/noti_api.dart';
import 'package:boilerplate/data/network/apis/posts/post_api.dart';
import 'package:boilerplate/data/network/apis/profile/profile_api.dart';
import 'package:boilerplate/data/network/apis/project/project_api.dart';
import 'package:boilerplate/data/network/apis/user/user_api.dart';
import 'package:boilerplate/data/repository/chat/chat_repository_impl.dart';
import 'package:boilerplate/data/repository/interview/interview_repository_impl.dart';
import 'package:boilerplate/data/repository/noti/noti_repository_impl.dart';
import 'package:boilerplate/data/repository/post/post_repository_impl.dart';
import 'package:boilerplate/data/repository/project/project_repository_impl.dart';
import 'package:boilerplate/data/repository/setting/setting_repository_impl.dart';
import 'package:boilerplate/data/repository/user/user_repository_impl.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/repository/chat/chat_repository.dart';
import 'package:boilerplate/domain/repository/interview/interview_repository.dart';
import 'package:boilerplate/domain/repository/noti/noti_repository.dart';
import 'package:boilerplate/domain/repository/post/post_repository.dart';
import 'package:boilerplate/domain/repository/project/project_repository.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

import '../../../di/service_locator.dart';

mixin RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // repository:--------------------------------------------------------------
    getIt.registerSingleton<SettingRepository>(SettingRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<UserRepository>(UserRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
      getIt<UserApi>(),
      getIt<ProfileApi>(),
    ));

    getIt.registerSingleton<NotiRepository>(
        NotiRepositoryImpl(getIt<NotiApi>()));

    getIt.registerSingleton<PostRepository>(PostRepositoryImpl(
      getIt<PostApi>(),
      getIt<PostDataSource>(),
    ));

    getIt.registerSingleton<ProjectRepository>(ProjectRepositoryImpl(
        getIt<ProjectApi>(),
        getIt<ProjectDataSource>(),
        getIt<SharedPreferenceHelper>()));

    getIt.registerSingleton<ChatRepository>(ChatRepositoryImpl(getIt<ChatApi>(),
        getIt<ChatDataSource>(), getIt<SharedPreferenceHelper>()));

    getIt.registerSingleton<InterviewRepository>(
        InterviewRepositoryImpl(getIt<InterviewApi>()));
  }
}
