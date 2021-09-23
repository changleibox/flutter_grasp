/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:dio/dio.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:flutter_grasp/src/framework/iterable_change_notifier.dart';

/// Created by changlei on 2020-02-13.
///
/// [List]类型的[ChangeNotifier]的异步请求扩展类
abstract class ListChangeNotifier<E> extends IterableChangeNotifier<E> {
  @override
  Future<List<E>?> onLoad(bool showProgress, CancelToken? cancelToken);
}
