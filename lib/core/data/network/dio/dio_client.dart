import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'configs/dio_configs.dart';

class DioClient {
  final DioConfigs dioConfigs;
  final Dio _dio;
  // final Dio _dio2;
  // bool _isBusy = false;

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
              .putIfAbsent("Access-Control-Allow-Credentials", () => "true");

  Dio get dio => _dio;
  int _dioCount = 0;

  var dioText = ValueNotifier<String?>(null);

  void clearDio() {
    // _isBusy = false;
    _dioCount = (_dioCount - 1).clamp(0, _dioCount);
    dioText.value = null;
    print("Dio is free now BEBAOBOY");
  }

  Dio addInterceptors(Iterable<Interceptor> interceptors) {
    return _dio
      ..interceptors.addAll([
        ...interceptors,
        QueuedInterceptorsWrapper(
          onRequest: (
            RequestOptions requestOptions,
            RequestInterceptorHandler handler,
          ) async {
            // print(requestOptions.uri)
            _dioCount++;
            if (_dioCount > 1) {
              dioText.value = "Dio is busy";
            }
            handler.next(requestOptions);
          },
        ),
      ]);
  }
}
