import 'package:dio/browser_imp.dart';

import '../entry_stub.dart';
import '../gio.dart';

Gio createGio([GioBaseOptions options]) => GioForBrowser(options);

class GioForBrowser extends DioForBrowser with DioExtendsMixin implements Gio {
  GioForBrowser([GioBaseOptions options]) : super(options);
}
