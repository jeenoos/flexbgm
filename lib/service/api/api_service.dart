// import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() {
    debugPrint('${111111}');
    return _instance;
  }
  Dio _dio = Dio();

  ApiService._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://api.flextv.co.kr',
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 10000),
      sendTimeout: const Duration(milliseconds: 10000),
      // headers: {},
    );
    _dio = Dio(options);
    _dio.interceptors.add(DioInterceptor());
  }

  Dio get instance => _dio;
}

class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('options: ${options.toString()}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('response: ${response.toString()}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('err: ${err.toString()}');
    super.onError(err, handler);
  }
}
