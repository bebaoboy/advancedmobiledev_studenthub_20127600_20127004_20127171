import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_test.mocks.dart';
import 'widget_test.dart';

@GenerateMocks([Dio])
void main() async {
  group('Test userStore', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({"first_time": true});
      await initDb();
    });

    tearDown(
      () async {
        await getIt.reset();
      },
    );

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
      expect(result, isNotNull);
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
