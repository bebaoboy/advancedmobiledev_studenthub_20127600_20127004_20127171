import 'package:boilerplate/core/data/local/sembast/sembast_client.dart';
import 'package:boilerplate/core/data/network/dio/configs/dio_configs.dart';
import 'package:boilerplate/data/di/module/network_module.dart';
import 'package:boilerplate/data/di/module/repository_module.dart';
import 'package:boilerplate/data/local/datasources/post/post_datasource.dart';
import 'package:boilerplate/data/local/datasources/project/project_datasource.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/di/domain_layer_injection.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/presentation/di/presentation_layer_injection.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'login_test.mocks.dart';

initDb() async {
  // preference manager:------------------------------------------------------
  // data sources:------------------------------------------------------------
  // Prevent calling Future.delayed that seems to hang in flutter test
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  getIt.registerSingleton<SharedPreferenceHelper>(
    SharedPreferenceHelper(await getIt.getAsync<SharedPreferences>()),
  );
  disableSembastCooperator();
  var sb = SembastClient(await databaseFactoryMemory.openDatabase('database'));
  getIt.registerSingleton(PostDataSource(sb));

  getIt.registerSingleton(ProjectDataSource(sb));
  await NetworkModule.configureNetworkModuleInjection();
  await RepositoryModule.configureRepositoryModuleInjection();

  await DomainLayerInjection.configureDomainLayerInjection();
  await PresentationLayerInjection.configurePresentationLayerInjection();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  // database:----------------------------------------------------------------
  // each database has a unique name
}

@GenerateMocks([Dio])
void main() async {
  group('Test userStore', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({"first_time": true});
      await initDb();
    });

    test("Test login success", () async {
      MockDio dio = MockDio();
      final userStore = getIt<UserStore>();
      const email = "tuanquan129@gmail.com";
      const password = "1234Quan+";
      const token =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OTQsImZ1bGxuYW1lIjoicXVhbiIsImVtYWlsIjoidHVhbnF1YW4xMjlAZ21haWwuY29tIiwicm9sZXMiOlswLDFdLCJpYXQiOjE3MTUwMDUzMDgsImV4cCI6MTcxNjIxNDkwOH0.wpY_Tnhpx8JgQF0GLIoCq4GjBC3f0Bv2RMkhUC3qhb0";
      when(dio.post(Endpoints.login,
              data: {"email": email, "password": password}))
          .thenAnswer((_) async => Response(data: {
                "result": {"token": token}
              }, statusCode: 200, requestOptions: RequestOptions()));
      final future = userStore.login(email, password, UserType.naught, []);
      expectLater(future, completes);
      final result = await future;
      expect(result, true);
    });

    test("Test login failed", () async {
      MockDio dio = MockDio();
      final userStore = getIt<UserStore>();
      const email = "tuanquan129@gmail.com";
      const password = "1234Quan+++++";
      when(dio.post(Endpoints.login,
              data: {"email": email, "password": password}))
          .thenAnswer((_) async => Response(
              data: {'error': 'Invalid credentials'},
              statusCode: 401,
              requestOptions: RequestOptions()));

      final future = userStore.login(email, password, UserType.naught, []);
      expectLater(future, completes);
      final result = await future;
      expect(result, false);
    });
  });
}
