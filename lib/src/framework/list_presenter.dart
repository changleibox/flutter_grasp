/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2020-02-13.
///
/// [List]类型的[Presenter]的异步请求扩展类
abstract class ListPresenter<T extends StatefulWidget, E> extends IterablePresenter<T, E> {
  @override
  Future<List<E>?> onLoad(bool showProgress, CancelToken? cancelToken);
}