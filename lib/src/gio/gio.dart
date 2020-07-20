/*
 * Copyright © 2019 CHANGLEI. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'entry_stub.dart'
    if (dart.library.html) 'entry/gio_for_browser.dart'
    if (dart.library.io) 'entry/gio_for_native.dart';

const int _kValidStatus = 200;
const int _kValidCode = 200;
const int _kTimeout = 90 * 1000;

typedef ValidateCode = bool Function(int code);

dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

dynamic _parseJson(String text) {
  return compute<String, dynamic>(_parseAndDecode, text);
}

class IResponse<T> {
  const IResponse(this.code, this.message, this.data);

  final int code;
  final String message;
  final T data;

  static IResponse<T> convert<T>(Response<dynamic> response) {
    if (response == null || response.data is! Map) {
      return null;
    }
    final Map<String, dynamic> dataMap = response?.data as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }
    final int code = dataMap['code'] as int;
    final String message = dataMap['msg'] as String;
    final T data = dataMap['data'] as T;
    if (code != null || message != null || data != null) {
      return IResponse<T>(code, message, data);
    }
    return null;
  }
}

class HttpError extends DioError {
  HttpError({
    RequestOptions request,
    Response<dynamic> response,
    DioErrorType type = DioErrorType.DEFAULT,
    dynamic error,
    int code,
  })  : _code = code,
        super(
          request: request,
          response: response,
          type: type,
          error: error,
        );

  int _code;

  int get code => _code;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    return identical(this, other) || other is HttpError && other._code == _code;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _code;

  static DioError _assureDioError(dynamic err) {
    if (err is HttpError) {
      return err;
    } else if (err is DioError) {
      return HttpError._convert(err);
    } else {
      final HttpError _err = HttpError();
      if (err is Error) {
        _err.error = err;
      }
      if (err is IResponse) {
        _err.error = err.message;
        _err._code = err.code;
      } else {
        _err.error = err;
      }
      return _err;
    }
  }

  static DioError _convert(DioError error) {
    if (error is HttpError) {
      return error;
    }
    try {
      int code = -1;
      final Response<dynamic> response = error.response;
      if (error.type == DioErrorType.RESPONSE && response != null) {
        final dynamic data = response.data;
        code = data['code'] as int;
      }
      return HttpError(
        request: error.request,
        response: response,
        type: error.type,
        error: error.error,
        code: code,
      );
    } catch (e) {
      return error;
    }
  }
}

class ConvertInterceptor extends InterceptorsWrapper {
  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    return options;
  }

  @override
  Future<dynamic> onError(DioError err) async {
    final Response<dynamic> response = err?.response;
    final dynamic iResponse = IResponse.convert<dynamic>(response);
    if (iResponse != null) {
      return HttpError._assureDioError(iResponse);
    } else {
      return HttpError._convert(err);
    }
  }

  @override
  Future<dynamic> onResponse(Response<dynamic> response) async {
    final RequestOptions requestOptions = response.request;
    final dynamic iResponse = IResponse.convert<dynamic>(response);
    if (iResponse != null && iResponse is IResponse && !_validateCode(iResponse, requestOptions)) {
      return HttpError._assureDioError(iResponse);
    }
    return iResponse;
  }

  bool _validateCode(IResponse<dynamic> iResponse, RequestOptions options) {
    if (iResponse == null || options is! GioRequestOptions) {
      return true;
    }
    return (options as GioRequestOptions).validateCode(iResponse.code);
  }
}

abstract class Gio with DioMixin implements Dio {
  factory Gio([GioBaseOptions options]) {
    final Gio gio = createGio(options);
    (gio.transformer as DefaultTransformer).jsonDecodeCallback = _parseJson;
    gio.interceptors.add(ConvertInterceptor());
    return gio;
  }

  factory Gio.normal({
    String baseUrl,
    int connectTimeout = _kTimeout,
    int receiveTimeout = _kTimeout,
    int validStatus = _kValidStatus,
    int validCode = _kValidCode,
  }) {
    return Gio(GioBaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (int status) => status == validStatus,
      validateCode: (int code) => code == validCode,
    ));
  }
}

class GioBaseOptions extends BaseOptions {
  GioBaseOptions({
    String method,
    int connectTimeout,
    int receiveTimeout,
    int sendTimeout,
    String baseUrl,
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> extra,
    Map<String, dynamic> headers,
    ResponseType responseType = ResponseType.json,
    String contentType,
    ValidateStatus validateStatus,
    bool receiveDataWhenStatusError = true,
    bool followRedirects = true,
    int maxRedirects = 5,
    RequestEncoder requestEncoder,
    ResponseDecoder responseDecoder,
    this.validateCode,
  }) : super(
          method: method,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
          baseUrl: baseUrl,
          queryParameters: queryParameters,
          extra: extra,
          headers: headers,
          responseType: responseType,
          contentType: contentType,
          validateStatus: validateStatus,
          receiveDataWhenStatusError: receiveDataWhenStatusError,
          followRedirects: followRedirects,
          maxRedirects: maxRedirects,
          requestEncoder: requestEncoder,
          responseDecoder: responseDecoder,
        );

  final ValidateCode validateCode;

  /// Create a Option from current instance with merging attributes.
  @override
  BaseOptions merge({
    String method,
    String baseUrl,
    Map<String, dynamic> queryParameters,
    String path,
    int connectTimeout,
    int receiveTimeout,
    int sendTimeout,
    Map<String, dynamic> extra,
    Map<String, dynamic> headers,
    ResponseType responseType,
    String contentType,
    ValidateStatus validateStatus,
    bool receiveDataWhenStatusError,
    bool followRedirects,
    int maxRedirects,
    RequestEncoder requestEncoder,
    ResponseDecoder responseDecoder,
    ValidateCode validateCode,
  }) {
    return GioBaseOptions(
      method: method ?? this.method,
      baseUrl: baseUrl ?? this.baseUrl,
      queryParameters: queryParameters ?? this.queryParameters,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      extra: extra ?? Map<String, dynamic>.from(this.extra ?? <String, dynamic>{}),
      headers: headers ?? Map<String, dynamic>.from(this.headers ?? <String, dynamic>{}),
      responseType: responseType ?? this.responseType,
      contentType: contentType ?? this.contentType,
      validateStatus: validateStatus ?? this.validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      requestEncoder: requestEncoder,
      responseDecoder: responseDecoder ?? this.responseDecoder,
      validateCode: validateCode ?? this.validateCode,
    );
  }
}

class GioRequestOptions extends RequestOptions {
  GioRequestOptions({
    String method,
    int sendTimeout,
    int receiveTimeout,
    int connectTimeout,
    dynamic data,
    String path,
    Map<String, dynamic> queryParameters,
    String baseUrl,
    ProgressCallback onReceiveProgress,
    ProgressCallback onSendProgress,
    CancelToken cancelToken,
    Map<String, dynamic> extra,
    Map<String, dynamic> headers,
    ResponseType responseType,
    String contentType,
    ValidateStatus validateStatus,
    bool receiveDataWhenStatusError = true,
    bool followRedirects = true,
    int maxRedirects,
    RequestEncoder requestEncoder,
    ResponseDecoder responseDecoder,
    this.validateCode,
  }) : super(
          method: method,
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
          connectTimeout: connectTimeout,
          data: data,
          path: path,
          queryParameters: queryParameters,
          baseUrl: baseUrl,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          cancelToken: cancelToken,
          extra: extra,
          headers: headers,
          responseType: responseType,
          contentType: contentType,
          validateStatus: validateStatus,
          receiveDataWhenStatusError: receiveDataWhenStatusError,
          followRedirects: followRedirects,
          maxRedirects: maxRedirects,
          requestEncoder: requestEncoder,
          responseDecoder: responseDecoder,
        );

  final ValidateCode validateCode;

  /// Create a Option from current instance with merging attributes.
  @override
  RequestOptions merge({
    String method,
    int sendTimeout,
    int receiveTimeout,
    int connectTimeout,
    dynamic data,
    String path,
    Map<String, dynamic> queryParameters,
    String baseUrl,
    ProgressCallback onReceiveProgress,
    ProgressCallback onSendProgress,
    CancelToken cancelToken,
    Map<String, dynamic> extra,
    Map<String, dynamic> headers,
    ResponseType responseType,
    String contentType,
    ValidateStatus validateStatus,
    bool receiveDataWhenStatusError = true,
    bool followRedirects = true,
    int maxRedirects,
    RequestEncoder requestEncoder,
    ResponseDecoder responseDecoder,
    ValidateCode validateCode,
  }) {
    return GioRequestOptions(
      method: method ?? this.method,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      data: data ?? this.data,
      path: path ?? this.path,
      queryParameters: queryParameters ?? this.queryParameters,
      baseUrl: baseUrl ?? this.baseUrl,
      onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
      onSendProgress: onSendProgress ?? this.onSendProgress,
      cancelToken: cancelToken ?? this.cancelToken,
      extra: extra ?? Map<String, dynamic>.from(this.extra ?? <String, dynamic>{}),
      headers: headers ?? Map<String, dynamic>.from(this.headers ?? <String, dynamic>{}),
      responseType: responseType ?? this.responseType,
      contentType: contentType ?? this.contentType,
      validateStatus: validateStatus ?? this.validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      requestEncoder: requestEncoder,
      responseDecoder: responseDecoder ?? this.responseDecoder,
      validateCode: validateCode ?? this.validateCode,
    );
  }
}
