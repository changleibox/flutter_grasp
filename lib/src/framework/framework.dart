/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';

import 'presenter.dart';

/// Created by changlei on 2020-02-13.
///
/// state和presenter的抽象模板
abstract class StateAbstractMethod<T extends StatefulWidget> {
  /// 页面是否有效
  bool get mounted;

  /// 同state.widget
  T get widget;

  /// 同state.context
  BuildContext get context;

  /// 同state.initState
  void initState();

  /// 同state.didUpdateWidget
  void didUpdateWidget(covariant T oldWidget);

  /// 同state.reassemble
  void reassemble();

  /// 同state.deactivate
  void deactivate();

  /// 同state.dispose
  void dispose();

  /// 同state.didChangeDependencies
  void didChangeDependencies();

  /// 同state.setState
  void markNeedsBuild([VoidCallback fn]);

  /// 页面在第一次绘制完成时回调
  void onPostFrame(Duration timeStamp);

  /// 隐藏键盘
  void hideKeyboard();
}

/// [StateAbstractMethod]的[state]具体实现类
abstract class PageState<T extends StatefulWidget> extends State<T> implements StateAbstractMethod<T> {
  @protected
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(onPostFrame);
  }

  @protected
  @mustCallSuper
  @override
  void onPostFrame(Duration timeStamp) {}

  @protected
  @mustCallSuper
  @override
  void markNeedsBuild([VoidCallback fn]) {
    if (!mounted) {
      return;
    }
    setState(fn ?? () {});
  }

  @protected
  @mustCallSuper
  @override
  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }
}

/// 用来绑定state和presenter
abstract class PresenterState<T extends StatefulWidget, P extends Presenter<T>> extends PageState<T> {
  PresenterState() {
    _presenter = createPresenter();
    assert(_presenter != null);
    _presenter?.state = this;
  }

  P _presenter;

  @protected
  P createPresenter();

  P get presenter => _presenter;

  @mustCallSuper
  @protected
  @override
  void initState() {
    super.initState();
    presenter?.initState();
  }

  @mustCallSuper
  @protected
  @override
  void onPostFrame(Duration timeStamp) {
    super.onPostFrame(timeStamp);
    presenter?.onPostFrame(timeStamp);
  }

  @mustCallSuper
  @protected
  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    presenter?.didUpdateWidget(oldWidget);
  }

  @mustCallSuper
  @protected
  @override
  void reassemble() {
    super.reassemble();
    presenter?.reassemble();
  }

  @mustCallSuper
  @protected
  @override
  void deactivate() {
    super.deactivate();
    presenter?.deactivate();
  }

  @mustCallSuper
  @protected
  @override
  void dispose() {
    super.dispose();
    presenter?.dispose();
  }

  @mustCallSuper
  @protected
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    presenter?.didChangeDependencies();
  }
}
