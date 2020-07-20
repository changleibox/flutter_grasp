import 'package:dio/native_imp.dart';

import '../entry_stub.dart';
import '../gio.dart';

Gio createGio([GioBaseOptions options]) => GioForNative(options);

class GioForNative extends DioForNative with DioExtendsMixin implements Gio {
  GioForNative([GioBaseOptions options]) : super(options);
}
