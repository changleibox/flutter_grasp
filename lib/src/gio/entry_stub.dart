import 'package:dio/dio.dart';

import 'gio.dart';

/// 创建[Gio]
Gio createGio([GioBaseOptions options]) => throw UnsupportedError('');

/// Created by changlei on 2020/8/26.
///
/// 创建[Dio]扩展Mixin
mixin DioExtendsMixin on DioMixin {
  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) {
    return super.fetch(_mergeOptions(requestOptions));
  }

  RequestOptions _mergeOptions(RequestOptions requestOptions) {
    if (requestOptions is GioRequestOptions) {
      return requestOptions;
    }
    final Map<String, dynamic> headers = <String, dynamic>{...?requestOptions.headers};
    final String contentType = requestOptions.contentType;
    if (contentType != null) {
      headers.remove(Headers.contentTypeHeader);
    }
    final BaseOptions baseOptions = options;
    return GioRequestOptions(
      method: requestOptions.method,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      connectTimeout: requestOptions.connectTimeout,
      data: requestOptions.data,
      path: requestOptions.path,
      queryParameters: requestOptions.queryParameters,
      baseUrl: requestOptions.baseUrl,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      cancelToken: requestOptions.cancelToken,
      extra: requestOptions.extra,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: contentType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      requestEncoder: requestOptions.requestEncoder,
      responseDecoder: requestOptions.responseDecoder,
      listFormat: requestOptions.listFormat,
      setRequestContentTypeWhenNoPayload: baseOptions?.setRequestContentTypeWhenNoPayload,
      validateCode: baseOptions is GioBaseOptions ? baseOptions?.validateCode : null,
      dataKeyOptions: baseOptions is GioBaseOptions ? baseOptions?.dataKeyOptions : null,
    );
  }
}
