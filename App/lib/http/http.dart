import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../common/index.dart';
import '../untils/index.dart';
import 'index.dart';

class HttpService {
  Dio? dio;
  Response<dynamic>? response;
  static final instance = HttpService._internal();

  factory HttpService.getInstance() => instance;

  HttpService._internal() {
    if (dio == null) {
      BaseOptions baseOptions = BaseOptions(
          baseUrl: baseUrl,
          //Timeout time for connecting to the server
          connectTimeout: 10000,
          //Time elapsed since last received data
          receiveTimeout: 5000,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json);
      dio ??= Dio(baseOptions);
      //Interceptors
      dio!.interceptors.add(InterceptorsWrapper(
          // onRequest: (RequestOptions options, _) => options,
          // onResponse: (Response response, _) => response,
          onError: (DioError e, _) {
        //Get the error according to the dio error
        ErrorEntity errorEntity = ErrorEntity.createErrorEntity(e);
        //Error Alert
        toastInfo(msg: errorEntity.message ?? "");
        return;
      }));
    }
  }

  Future get({String? path, dynamic queryParameters}) async {
    EasyLoading.show(status: "Loading...");
    Options? options = setToken();
    response = await dio?.get(path!,
        options: options, queryParameters: queryParameters);
    EasyLoading.dismiss();
    return response!.data;
  }

  Future post({required String path, Options? options, var data}) async {
    Options? options = setToken();
    response = await dio?.post(path, data: data, options: options);
    return response!.data;
  }

  Future put(
      {required String path,
      Options? options,
      Map<String, dynamic>? data}) async {
    Options? options = setToken();
    response = await dio?.put(path, data: data, options: options);
    return response!.data;
  }

  Future delete(
      {required String path,
      Options? options,
      Map<String, dynamic>? data}) async {
    Options? options = setToken();
    response = await dio?.delete(path, data: data, options: options);
    return response!.data;
  }

  Options? setToken() {
    Options? options = Options();
    // if (UserService.to.hasToken) {
    //   options.headers = {"Authorization": UserService.to.token.value};
    // }
    return options;
  }
}
