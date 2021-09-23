/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'dart:collection';
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

/// 返回有效的code，比如：200
typedef ValidateCode = bool Function(int code);

dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

dynamic _parseJson(String text) {
  return compute<String, dynamic>(_parseAndDecode, text);
}

/// 自定义Response
class IResponse with MapMixin<String, dynamic> {
  const IResponse._(
    this.code,
    this.message,
    this.data,
    this._originalData,
  );

  /// 返回的code
  final int code;

  /// 返回的message
  final String? message;

  /// 返回的data
  final Object? data;
  final Map<String, dynamic> _originalData;

  @override
  String toString() {
    return _originalData.toString();
  }

  @override
  Object? operator [](Object? key) {
    return _originalData[key];
  }

  @override
  void operator []=(String key, dynamic value) {
    _originalData[key] = value;
  }

  @override
  void clear() {
    _originalData.clear();
  }

  @override
  Iterable<String> get keys => _originalData.keys;

  @override
  Object? remove(Object? key) {
    _originalData.remove(key);
  }
}

/// 自定义Error
class GioError extends DioError {
  GioError._({
    required RequestOptions requestOptions,
    Response<dynamic>? response,
    DioErrorType type = DioErrorType.other,
    dynamic error,
    int? code,
  })  : _code = code,
        super(
          requestOptions: requestOptions,
          response: response,
          type: type,
          error: error,
        );

  int? _code;

  /// 错误码
  int? get code => _code;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is GioError && other._code == _code;
  }

  @override
  int get hashCode => _code.hashCode;

  static DioError _assureDioError(RequestOptions requestOptions, dynamic err, [dynamic origin]) {
    if (err is GioError) {
      return err;
    } else if (err is DioError) {
      return GioError._convert(err);
    } else {
      final _err = GioError._(
        requestOptions: requestOptions,
      );
      if (err is Error) {
        _err.error = err;
      } else if (err is IResponse) {
        Response<dynamic>? response;
        if (origin is Response<dynamic>) {
          response = origin;
        } else if (origin is DioError) {
          response = origin.response;
        }

        response?.data = err.data;
        response?.statusMessage = err.message;

        _err.error = err.message;
        _err._code = err.code;
        _err.response = response;
        _err.type = DioErrorType.response;
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
      var code = -1;
      final response = error.response;
      if (response != null) {
        final dynamic data = response.data;
        final options = response.requestOptions;
        final keyOptions = (options is GioRequestOptions ? options : null)?.dataKeyOptions;
        code = data[keyOptions?.codeKey ?? _kCodeKey] as int;
      }
      return GioError._(
        requestOptions: error.requestOptions,
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

/// 拦截器，解析服务器返回的数据
class ConvertInterceptor extends InterceptorsWrapper {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final requestOptions = err.requestOptions;
    final iResponse = _convert(response, requestOptions);
    if (iResponse == null) {
      handler.next(GioError._convert(err));
    } else {
      handler.next(GioError._assureDioError(requestOptions, iResponse, err));
    }
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final requestOptions = response.requestOptions;
    final iResponse = _convert(response, requestOptions);
    if (!_validateCode(iResponse, requestOptions)) {
      handler.reject(GioError._assureDioError(requestOptions, iResponse, response), true);
    } else {
      handler.next(response..data = iResponse == null ? response.data : iResponse.data);
    }
  }

  bool _validateCode(IResponse? iResponse, RequestOptions options) {
    if (iResponse == null || options is! GioRequestOptions) {
      return true;
    }
    return options.validateCode?.call(iResponse.code) != false;
  }

  IResponse? _convert(Response<dynamic>? response, RequestOptions options) {
    if (response == null || response.data is! Map<String, dynamic>) {
      return null;
    }
    final Map<String, dynamic>? dataMap = response.data as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }
    final keyOptions = (options is GioRequestOptions ? options : null)?.dataKeyOptions;
    final int? code = dataMap[keyOptions?.codeKey ?? _kCodeKey] as int;
    final String? message = dataMap[keyOptions?.messageKey ?? _kMessageKey] as String;
    final dynamic data = dataMap[keyOptions?.dataKey ?? _kDataKey];
    if (code != null && (message != null || data != null)) {
      return IResponse._(code, message, data, dataMap);
    }
    return null;
  }
}

/// Created by changlei on 2020/8/26.
///
/// gio，最终通过它调用
abstract class Gio with DioMixin implements Dio {
  /// 默认构造函数
  factory Gio([GioBaseOptions? options]) {
    final gio = createGio(options);
    (gio.transformer as DefaultTransformer).jsonDecodeCallback = _parseJson;
    gio.interceptors.add(ConvertInterceptor());
    return gio;
  }

  /// 创建一个通用的[Gio]
  factory Gio.normal({
    String baseUrl = '',
    int connectTimeout = _kTimeout,
    int receiveTimeout = _kTimeout,
    int sendTimeout = _kTimeout,
    int validStatus = _kValidStatus,
    int validCode = _kValidCode,
    String codeKey = _kCodeKey,
    String messageKey = _kMessageKey,
    String dataKey = _kDataKey,
  }) {
    return Gio(GioBaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (int? status) => status == validStatus,
      validateCode: (int code) => code == validCode,
      dataKeyOptions: DataKeyOptions(
        codeKey: codeKey,
        messageKey: messageKey,
        dataKey: dataKey,
      ),
    ));
  }
}

/// 配置key
class DataKeyOptions {
  /// 构造函数
  const DataKeyOptions({
    this.codeKey = _kCodeKey,
    this.messageKey = _kMessageKey,
    this.dataKey = _kDataKey,
  });

  /// code对应的key
  final String codeKey;

  /// message对应的key
  final String messageKey;

  /// data对应的key
  final String dataKey;
}

/// [Gio]base options
class GioBaseOptions extends BaseOptions {
  /// 构造函数
  GioBaseOptions({
    String? method,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    String baseUrl = '',
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    String? contentType,
    ValidateStatus? validateStatus,
    bool receiveDataWhenStatusError = true,
    bool followRedirects = true,
    int maxRedirects = 5,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ListFormat? listFormat,
    bool setRequestContentTypeWhenNoPayload = false,
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
          listFormat: listFormat,
          setRequestContentTypeWhenNoPayload: setRequestContentTypeWhenNoPayload,
        );

  /// 验证code是否有效
  final ValidateCode? validateCode;

  /// key配置
  final DataKeyOptions dataKeyOptions;

  /// Create a Option from current instance with merging attributes.
  @override
  BaseOptions copyWith({
    String? method,
    String? baseUrl,
    Map<String, dynamic>? queryParameters,
    String? path,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    String? contentType,
    ValidateStatus? validateStatus,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ListFormat? listFormat,
    bool? setRequestContentTypeWhenNoPayload,
    ValidateCode? validateCode,
    DataKeyOptions? dataKeyOptions,
  }) {
    return GioBaseOptions(
      method: method ?? this.method,
      baseUrl: baseUrl ?? this.baseUrl,
      queryParameters: queryParameters ?? this.queryParameters,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      extra: extra ?? Map<String, dynamic>.from(this.extra),
      headers: headers ?? Map<String, dynamic>.from(this.headers),
      responseType: responseType ?? this.responseType,
      contentType: contentType ?? this.contentType,
      validateStatus: validateStatus ?? this.validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      requestEncoder: requestEncoder,
      responseDecoder: responseDecoder ?? this.responseDecoder,
      listFormat: listFormat ?? this.listFormat,
      setRequestContentTypeWhenNoPayload: setRequestContentTypeWhenNoPayload ?? this.setRequestContentTypeWhenNoPayload,
      validateCode: validateCode ?? this.validateCode,
      dataKeyOptions: dataKeyOptions ?? this.dataKeyOptions,
    );
  }
}

/// [Gio]request options
class GioRequestOptions extends RequestOptions {
  /// 构造函数
  GioRequestOptions({
    String? method,
    int? sendTimeout,
    int? receiveTimeout,
    int? connectTimeout,
    Object? data,
    required String path,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    String? baseUrl,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    String? contentType,
    ValidateStatus? validateStatus,
    bool receiveDataWhenStatusError = true,
    bool followRedirects = true,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ListFormat? listFormat,
    this.setRequestContentTypeWhenNoPayload = false,
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
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          cancelToken: cancelToken,
          baseUrl: baseUrl,
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
          listFormat: listFormat,
          setRequestContentTypeWhenNoPayload: setRequestContentTypeWhenNoPayload,
        );

  /// 验证code
  final ValidateCode? validateCode;

  /// keys配置
  final DataKeyOptions? dataKeyOptions;

  /// if false, content-type in request header will be deleted when method is not on of `_allowPayloadMethods`
  final bool setRequestContentTypeWhenNoPayload;

  /// Create a Option from current instance with merging attributes.
  @override
  RequestOptions copyWith({
    String? method,
    int? sendTimeout,
    int? receiveTimeout,
    int? connectTimeout,
    Object? data,
    String? path,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    String? contentType,
    ValidateStatus? validateStatus,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ListFormat? listFormat,
    bool? setRequestContentTypeWhenNoPayload,
    ValidateCode? validateCode,
    DataKeyOptions? dataKeyOptions,
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
      extra: extra ?? Map<String, dynamic>.from(this.extra),
      headers: headers ?? Map<String, dynamic>.from(this.headers),
      responseType: responseType ?? this.responseType,
      contentType: contentType ?? this.contentType,
      validateStatus: validateStatus ?? this.validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      requestEncoder: requestEncoder,
      responseDecoder: responseDecoder ?? this.responseDecoder,
      listFormat: listFormat ?? this.listFormat,
      setRequestContentTypeWhenNoPayload: setRequestContentTypeWhenNoPayload ?? this.setRequestContentTypeWhenNoPayload,
      validateCode: validateCode ?? this.validateCode,
      dataKeyOptions: dataKeyOptions ?? this.dataKeyOptions,
    );
  }
}
