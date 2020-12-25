/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// 默认的分页加载起始页
const int normalFirstPage = 1;

/// 默认每页加载的条数
const int normalPageSize = 20;

/// Created by changlei on 2020-02-13.
///
/// [Iterable]类型的的异步请求扩展类
abstract class PageResponsePresenter<T extends StatefulWidget, E> extends IterablePresenter<T, E> {
  /// [Iterable]类型的的异步请求扩展类
  PageResponsePresenter({
    int normalFirstPage = normalFirstPage,
    int normalPageSize = normalPageSize,
  })  : assert(normalFirstPage != null),
        assert(normalPageSize != null),
        _normalFirstPage = normalFirstPage,
        _normalPageSize = normalPageSize,
        _currentPage = normalFirstPage,
        _currentPageSize = normalPageSize;

  final int _normalFirstPage;
  final int _normalPageSize;

  int _currentPage;
  int _currentPageSize;
  bool _hasNext = false;

  /// 当前页数
  int get currentPage => _currentPage;

  /// 当前的页面记载条数
  int get currentPageSize => _currentPageSize;

  /// 是否有下一页
  bool get hasNext => _hasNext;

  /// 是否是第一页
  bool get isFirstPage => _currentPage == _normalFirstPage;

  @override
  LoadOptions get loadOptions => super.loadOptions.copyWith(
        onLoadNext: onLoadNext,
        hasNext: hasNext,
      );

  /// 刷新数据，可以指定一个pageSize
  Future<void> onRefreshAsPageSize(int size) {
    _currentPage = _normalFirstPage;
    // _currentPageSize = max(size, normalPageSize);
    // 去掉原来的动态pageSize功能，改成固定pageSize
    _currentPageSize = _normalPageSize;
    return super.onRefresh();
  }

  /// 刷新数据，把当前的[itemCount]数量指定给pageSize
  Future<void> onLosslessRefresh() {
    return onRefreshAsPageSize(itemCount);
  }

  @override
  @mustCallSuper
  Future<void> refresh() {
    if (isEmpty) {
      return super.refresh();
    } else {
      return onLosslessRefresh();
    }
  }

  @override
  Future<void> onRefresh() async {
    _currentPage = _normalFirstPage;
    _currentPageSize = _normalPageSize;
    return super.onRefresh();
  }

  @override
  Future<void> onQuery(String queryText) async {
    if (!isQueryChanged(queryText)) {
      return;
    }
    _currentPage = _normalFirstPage;
    _currentPageSize = _normalPageSize;
    return super.onQuery(queryText);
  }

  /// 加载下一页
  Future<void> onLoadNext() async {
    _currentPageSize = _normalPageSize;
    return super.onRefresh();
  }

  @mustCallSuper
  @override
  Future<List<E>> request(bool showProgress, CancelToken cancelToken) async {
    final Completer<List<E>> completer = Completer<List<E>>.sync();
    onLoad(showProgress, cancelToken).then((List<E> pageResponse) {
      completer.complete(_callback(pageResponse));
    }).catchError((Object error) {
      completer.completeError(error);
    });
    return completer.future;
  }

  @protected
  @override
  Future<List<E>> onLoad(bool showProgress, CancelToken cancelToken);

  List<E> _callback(List<E> pageResponse) {
    final List<E> existedObjects = List<E>.of(super.objects);
    if (pageResponse == null) {
      _currentPage = _normalFirstPage;
      existedObjects.clear();
      _hasNext = false;
    } else {
      final bool isFirstPage = _currentPage == _normalFirstPage;
      _hasNext = pageResponse.length == _currentPageSize;
      if (_hasNext) {
        _currentPage++;
      }
      final List<E> objects = pageResponse;
      if (isFirstPage) {
        existedObjects.clear();
      }
      existedObjects.addAll(objects);
    }
    return existedObjects;
  }

  @override
  void setObjects(Iterable<E> objects) {
    _currentPage = normalFirstPage;
    _hasNext = false;
    super.setObjects(objects);
  }
}
