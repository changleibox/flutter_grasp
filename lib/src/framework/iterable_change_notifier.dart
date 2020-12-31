/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:flutter_grasp/src/framework/future_change_notifier.dart';

/// Created by changlei on 2020-02-13.
///
/// [Iterable]类型的的异步请求扩展类
abstract class IterableChangeNotifier<E> extends FutureChangeNotifier<Iterable<E>> implements LoadOptionsBuilder {
  final RefreshScrollController _refreshController = RefreshScrollController.manual(
    style: RefreshControllerStyle.material,
  );
  final List<E> _objects = <E>[];

  /// 异步加载返回的数据
  Iterable<E> get objects => List<E>.unmodifiable(_objects);

  @override
  bool get showProgress => false;

  /// 已加载的数据条数
  int get itemCount => objects.length;

  @override
  bool get isEmpty => objects.isEmpty;

  @override
  bool get isNotEmpty => objects.isNotEmpty;

  E operator [](int index) => objects.elementAt(index);

  E get first => objects.first;

  E get last => objects.last;

  E get single => objects.single;

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
  Future<void> onQuery(String queryText) async {
    if (!isQueryChanged(queryText)) {
      return;
    }
    return super.onQuery(queryText);
  }

  @protected
  @override
  // ignore: avoid_renaming_method_parameters
  Iterable<E> resolve(Iterable<E> objects) {
    _objects.clear();
    if (objects != null && objects.isNotEmpty) {
      _objects.addAll(objects);
    }
    return List<E>.unmodifiable(_objects);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onLoaded(Iterable<E> objects) {}

  /// 设置默认缓存数据，会在加载完成的时候覆盖
  void setObjects(Iterable<E> objects) {
    resolve(objects);
    notifyListeners();
  }
}
