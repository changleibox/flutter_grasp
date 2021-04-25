import 'package:dio/browser_imp.dart';

import '../entry_stub.dart';
import '../gio.dart';

/// 创建[Gio] for browser
Gio createGio([GioBaseOptions options]) => GioForBrowser(options);

/// Created by changlei on 2020/8/26.
///
/// [Gio] for browser
class GioForBrowser extends DioForBrowser with DioExtendsMixin implements Gio {
  /// 构造函数
  GioForBrowser([GioBaseOptions options]) : super(options);
}
