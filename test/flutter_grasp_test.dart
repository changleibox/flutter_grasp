import 'package:dio/dio.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gio test.', () async {
    final Gio gio = Gio.normal(
      baseUrl: 'http://weshoptest.graspyun.com:5000',
      validCode: 0,
      messageKey: 'msg',
    );
    gio.interceptors.add(LogInterceptor(request: true, responseBody: true));
    try {
      final Response<dynamic> response = await gio.get<dynamic>('/manage/agreement/list');
      expect(response.data, isA<List<dynamic>>());
    } catch (e) {
      print('网络异常-$e');
    }

    try {
      await gio.put<dynamic>('/manage/agreement/list');
    } on GioError catch (e) {
      expect(e.code, -1);
      expect(e.message, contains('404'));
    }
  });
}
