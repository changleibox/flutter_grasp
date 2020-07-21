/*
 * Copyright © 2019 CHANGLEI. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'entry_stub.dart'
    if (dart.library.html) 'entry/gio_for_browser.dart'
    if (dart.library.io) 'entry/gio_for_native.dart';

const int _kValidStatus = 200;
const int _kValidCode = 200;
const int _kTimeout = 90 * 1000;
const String _kCodeKey = 'code';
const String _kMessageKey = 'message';
const String _kDataKey = 'data';

typedef ValidateCode = bool Function(int code);

dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

dynamic _parseJson(String text) {
  return compute<String, dynamic>(_parseAndDecode, text);
}

class IResponse {
  const IResponse._(
    this.code,
    this.message,
    this.data,
    this._originalData,
  );

  final int code;
  final String message;
  final dynamic data;
  final Map<String, dynamic> _originalData;

  @override
  String toString() {
    return _originalData?.toString() ?? super.toString();
  }
}

class GioError extends DioError {
  GioError._({
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
    return identical(this, other) || other is GioError && other._code == _code;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _code;

  static DioError _assureDioError(dynamic err) {
    if (err is GioError) {
      return err;
    } else if (err is DioError) {
      return GioError._convert(err);
    } else {
      final GioError _err = GioError._();
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
    if (error is GioError) {
      return error;
    }
    try {
      int code = -1;
      final Response<dynamic> response = error.response;
      if (response != null) {
        final dynamic data = response.data;
        code = data['code'] as int;
      }
      return GioError._(
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
    final RequestOptions requestOptions = response?.request;
    final IResponse iResponse = _convert<dynamic>(response, requestOptions);
    if (iResponse == null) {
      throw GioError._convert(err);
    } else {
      throw GioError._assureDioError(iResponse);
    }
  }

  @override
  Future<dynamic> onResponse(Response<dynamic> response) async {
    final RequestOptions requestOptions = response.request;
    final IResponse iResponse = _convert<dynamic>(response, requestOptions);
    if (!_validateCode(iResponse, requestOptions)) {
      throw GioError._assureDioError(iResponse);
    }
    return response..data = iResponse ?? response.data;
  }

  bool _validateCode(IResponse iResponse, RequestOptions options) {
    if (iResponse == null || options is! GioRequestOptions) {
      return true;
    }
    return (options as GioRequestOptions).validateCode(iResponse.code);
  }

  IResponse _convert<T>(Response<dynamic> response, RequestOptions options) {
    if (response == null || response.data is! Map) {
      return null;
    }
    final Map<String, dynamic> dataMap = response?.data as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }
    final DataKeyOptions keyOptions = (options is GioRequestOptions ? options : null)?.dataKeyOptions;
    final int code = dataMap[keyOptions?.codeKey ?? _kCodeKey] as int;
    final String message = dataMap[keyOptions?.messageKey ?? _kMessageKey] as String;
    final dynamic data = dataMap[keyOptions?.dataKey ?? _kDataKey];
    if (code != null || message != null || data != null) {
      return IResponse._(code, message, data, dataMap);
    }
    return null;
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
    String codeKey = _kCodeKey,
    String messageKey = _kMessageKey,
    String dataKey = _kDataKey,
  }) {
    assert(connectTimeout != null);
    assert(receiveTimeout != null);
    assert(validStatus != null);
    assert(validCode != null);
    assert(codeKey != null);
    assert(messageKey != null);
    assert(dataKey != null);
    return Gio(GioBaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (int status) => status == validStatus,
      validateCode: (int code) => code == validCode,
      dataKeyOptions: DataKeyOptions(
        codeKey: codeKey,
        messageKey: messageKey,
        dataKey: dataKey,
      ),
    ));
  }
}

class DataKeyOptions {
  const DataKeyOptions({
    this.codeKey = _kCodeKey,
    this.messageKey = _kMessageKey,
    this.dataKey = _kDataKey,
  })  : assert(codeKey != null),
        assert(messageKey != null),
        assert(dataKey != null);

  final String codeKey;
  final String messageKey;
  final String dataKey;
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
    this.dataKeyOptions = const DataKeyOptions(),
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
  final DataKeyOptions dataKeyOptions;

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
    DataKeyOptions dataKeyOptions,
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
      dataKeyOptions: dataKeyOptions ?? this.dataKeyOptions,
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
    this.dataKeyOptions = const DataKeyOptions(),
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
  final DataKeyOptions dataKeyOptions;

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
    DataKeyOptions dataKeyOptions,
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
      dataKeyOptions: dataKeyOptions ?? this.dataKeyOptions,
    );
  }
}
