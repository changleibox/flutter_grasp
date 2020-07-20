import 'package:dio/dio.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gio test.', () async {
    final Gio gio = Gio.normal(
      baseUrl: 'http://weshoptest.graspyun.com:5000',
      validCode: 0,
    );
    gio.interceptors.add(LogInterceptor(request: true, responseBody: true));
    final Response<IResponse<dynamic>> response = await gio.get<IResponse<dynamic>>('/manage/agreement/list');
    print(response.data.data);
  });
}
