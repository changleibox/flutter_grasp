import 'package:dio/native_imp.dart';

import '../entry_stub.dart';
import '../gio.dart';

/// 创建[Gio] for native
Gio createGio([GioBaseOptions options]) => GioForNative(options);

/// Created by changlei on 2020/8/26.
///
/// [Gio] for native
class GioForNative extends DioForNative with DioExtendsMixin implements Gio {
  /// 构造函数
  GioForNative([GioBaseOptions options]) : super(options);
}
