import 'package:dio/dio.dart';

import 'gio.dart';

Gio createGio([GioBaseOptions options]) => throw UnsupportedError('');

mixin DioExtendsMixin on DioMixin {
  @override
  RequestOptions mergeOptions(Options opt, String url, dynamic data, Map<String, dynamic> queryParameters) {
    final RequestOptions requestOptions = super.mergeOptions(opt, url, data, queryParameters);
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
      headers: requestOptions.headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      requestEncoder: requestOptions.requestEncoder,
      responseDecoder: requestOptions.responseDecoder,
      validateCode: baseOptions is GioBaseOptions ? baseOptions.validateCode : null,
    );
  }
}
