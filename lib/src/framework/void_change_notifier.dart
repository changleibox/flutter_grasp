/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2020-02-13.
///
/// [Object]类型的的异步请求扩展类
abstract class VoidChangeNotifier extends ObjectChangeNotifier<void> {
  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;
}
