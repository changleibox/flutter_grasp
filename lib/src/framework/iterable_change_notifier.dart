/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2020-02-13.
///
/// [Iterable]类型的[ChangeNotifier]的异步请求扩展类
abstract class IterableChangeNotifier<E> extends FutureChangeNotifier<Iterable<E>>
    with IterableMixin<E>
    implements LoadOptionsBuilder {
  final RefreshScrollController _refreshController = RefreshScrollController.manual(
    style: RefreshControllerStyle.material,
  );
  final List<E> _objects = <E>[];

  /// 异步加载返回的数据
  Iterable<E> get objects => List<E>.unmodifiable(_objects);

  @override
  bool get showProgress => false;

  /// 已加载的数据条数
  int get itemCount => length;

  /// The object at the given [index] in the list.
  ///
  /// The [index] must be a valid index of this list,
  /// which means that `index` must be non-negative and
  /// less than [length].
  E operator [](int index) => objects.elementAt(index);

  @override
  Iterator<E> get iterator => objects.iterator;

  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
  }

  /// 加载配置，用于[SupportCustomScrollView]
  @override
  LoadOptions get loadOptions {
    return LoadOptions(
      controller: _refreshController,
      onRefresh: onRefresh,
    );
  }

  @protected
  @override
  Future<void> onDefaultRefresh() {
    return refresh();
  }

  /// 手动刷新的时候，调用此方法
  @mustCallSuper
  Future<void> refresh() {
    if (isEmpty && _refreshController.hasClients) {
      return _refreshController.onRefresh();
    } else {
      return onRefresh();
    }
  }

  @override
  Future<void> onQuery(String? queryText) async {
    if (!isQueryChanged(queryText)) {
      return;
    }
    return super.onQuery(queryText);
  }

  @protected
  @override
  // ignore: avoid_renaming_method_parameters
  Iterable<E> resolve(Iterable<E>? objects) {
    _objects.clear();
    if (objects != null && objects.isNotEmpty) {
      _objects.addAll(objects);
    }
    return List<E>.unmodifiable(_objects);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onLoaded(Iterable<E>? objects) {}

  /// 设置默认缓存数据，会在加载完成的时候覆盖
  void setObjects(Iterable<E>? objects) {
    resolve(objects);
    notifyListeners();
  }
}
