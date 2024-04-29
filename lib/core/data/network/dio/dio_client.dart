import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/utils/routes/navbar_notifier2.dart';
import 'package:dio/dio.dart';

import 'configs/dio_configs.dart';

class DioClient {
  final DioConfigs dioConfigs;
  final Dio _dio;
  final Dio _dio2;
  bool _isBusy = false;

  DioClient({required this.dioConfigs})
      : _dio = Dio()
          ..options.baseUrl = dioConfigs.baseUrl
          ..options.connectTimeout =
              Duration(milliseconds: dioConfigs.connectionTimeout)
          ..options.receiveTimeout =
              Duration(milliseconds: dioConfigs.receiveTimeout)
          ..options.headers.putIfAbsent("Access-Control-Allow-Methods",
              () => "GET,PUT,POST,DELETE,PATCH,OPTIONS")
          ..options
              .headers
              .putIfAbsent("Access-Control-Allow-Headers", () => "Content-Type")
          ..options
              .headers
              .putIfAbsent("Access-Control-Allow-Credentials", () => "true"),
        _dio2 = Dio();

  Dio get dio {
    if (!_isBusy) {
      _isBusy = true;
      return _dio;
    } else {
      print("Dio is busy BEBAOBOY");
      if (NavigationService.navigatorKey.currentContext != null) {
        // TODO:Delete this line
        NavbarNotifier2.showSnackBar(
          duration: const Duration(milliseconds: 100),
          NavigationService.navigatorKey.currentContext!,
          "Dio is busy BEBAOBOY",
          bottom: 60,
        );
      }
      return _dio2;
    }
  }

  void clearDio() {
    _isBusy = false;
    print("Dio is free now BEBAOBOY");
  }

  Dio addInterceptors(Iterable<Interceptor> interceptors) {
    return _dio..interceptors.addAll(interceptors);
  }
}
