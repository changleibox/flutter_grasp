/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2020-02-13.
///
/// presenter的异步请求扩展类
mixin RequestPresenterMixin<T extends StatefulWidget, E> on Presenter<T> {
  CancelToken _cancelToken;
  bool _isLoading = false;
  String _queryText;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 搜索的文本
  String get queryText => _queryText;

  /// 是否在页面加载完成的时候调用异步请求，默认返回true
  @protected
  bool get defaultRefresh => true;

  /// 是否需要显示加载进度条
  @protected
  bool get showProgress;

  /// 是否为空
  bool get isEmpty;

  /// 是否不为空
  bool get isNotEmpty;

  /// 搜索的文本是否改变
  bool isQueryChanged(String queryText) {
    queryText = Strings.isEmpty(queryText) ? null : queryText;
    return queryText != this.queryText;
  }

  /// 搜索，一般手动搜索的时候，调用这个方法
  @mustCallSuper
  Future<void> query() async {
    return onQuery(queryText);
  }

  /// 搜索，一般在[TextField]文本改变的时候，调用这个方法
  @mustCallSuper
  Future<void> onQuery(String queryText) async {
    if (!isQueryChanged(queryText)) {
      return;
    }
    _queryText = Strings.isEmpty(queryText) ? null : queryText;
    return _load(false);
  }

  /// 再刷新的时候，回调此方法
  @mustCallSuper
  Future<void> onRefresh() async {
    return _load(showProgress);
  }

  /// 当[defaultRefresh]返回true的时候，页面加载完成，回调此方发
  @protected
  Future<void> onDefaultRefresh() async {
    return onRefresh();
  }

  /// 当页面加载完成的时候
  @mustCallSuper
  @override
  void onPostFrame(Duration timeStamp) {
    super.onPostFrame(timeStamp);
    if (defaultRefresh) {
      onDefaultRefresh();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  /// 异步加载实现方法
  @protected
  Future<E> request(bool showProgress, CancelToken cancelToken) async {
    return await onLoad(showProgress, cancelToken) as E;
  }

  /// 异步加载实现方法
  @protected
  Future<dynamic> onLoad(bool showProgress, CancelToken cancelToken);

  /// 对加载完的数据进行解析
  @protected
  E resolve(E object);

  /// 开始加载
  @protected
  void onStart() {
    markNeedsBuild();
  }

  /// 已加载完成
  @protected
  void onLoaded(E object) {}

  /// 加载错误的时候
  @protected
  void onError(Object error, StackTrace stackTrace) {}

  /// 加载完成的时候，无论错误、正确都会回调
  @protected
  void onComplete() {
    markNeedsBuild();
  }

  Future<void> _load(bool showProgress) async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    _isLoading = true;
    onStart();
    await request(showProgress, _cancelToken).then((E object) {
      _callback(object);
    }).catchError((Object error, StackTrace stackTrace) {
      onError(error, stackTrace);
    }).whenComplete(() {
      _isLoading = false;
      onComplete();
    });
  }

  void _callback(E object) {
    onLoaded(resolve(object));
  }
}

/// presenter的异步请求扩展类
abstract class RequestPresenter<T extends StatefulWidget, E> extends Presenter<T> with RequestPresenterMixin<T, E> {}
