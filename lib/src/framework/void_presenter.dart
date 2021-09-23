/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2020-02-13.
///
/// [void]类型的[Presenter]的异步请求扩展类
abstract class VoidPresenter<T extends StatefulWidget> extends ObjectPresenter<T, void> {
  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;
}
