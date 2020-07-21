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
      final Response<IResponse> response = await gio.get<IResponse>('/manage/agreement/list');
      expect(response.data.data, isA<List<dynamic>>());
    } catch (e) {
      print('网络异常-$e');
    }

    try {
      await gio.put<IResponse>('/manage/agreement/list');
    } catch (e) {
      expect(e.code, -1);
      expect(e.message, contains('404'));
    }
  });
}
