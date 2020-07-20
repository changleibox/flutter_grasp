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

  /// 在state调用build的时候，但是在state和presenter实现不一样，state里会返回一个[Widget]，presenter返回void
  void onBuild(BuildContext context);

  /// 同state.didChangeDependencies
  void didChangeDependencies();

  /// 同state.setState
  void markNeedsBuild({VoidCallback fn});

  /// 页面在第一次绘制完成时回调
  void onPostFrame(Duration timeStamp);

  /// 当[needCallBackPressed]返回true的时候，点击返回键，会回调这个方法
  Future<bool> onBackPressed();

  /// 在根控件点击的时候
  void onRootTap();

  /// 隐藏键盘
  void hideKeyboard();

  /// 请求焦点
  void requestFocus([FocusNode node]);

  /// 判断页面是否需要监听返回键
  bool get needCallBackPressed;
}

/// [StateAbstractMethod]的[state]具体实现类
abstract class PageState<T extends StatefulWidget> extends State<T> implements StateAbstractMethod<T> {
  @protected
  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    Widget child = onBuild(context);
    if (needCallBackPressed) {
      child = WillPopScope(
        onWillPop: onBackPressed,
        child: child,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onRootTap,
      child: child,
    );
  }

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
  void markNeedsBuild({VoidCallback fn}) {
    if (!mounted) {
      return;
    }
    setState(fn ?? () {});
  }

  @protected
  @override
  Future<bool> onBackPressed() async {
    hideKeyboard();
    return true;
  }

  @protected
  @mustCallSuper
  @override
  void onRootTap() => hideKeyboard();

  @protected
  @mustCallSuper
  @override
  Widget onBuild(BuildContext context) => builds(context);

  @protected
  Widget builds(BuildContext context);

  @protected
  @mustCallSuper
  @override
  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @protected
  @mustCallSuper
  @override
  void requestFocus([FocusNode node]) {
    FocusScope.of(context).requestFocus(node);
  }

  @protected
  @override
  bool get needCallBackPressed => false;
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
  Widget build(BuildContext context) {
    return super.build(context);
  }

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

  @mustCallSuper
  @protected
  @override
  Future<bool> onBackPressed() async {
    final bool backPressed = await super.onBackPressed();
    return backPressed && (presenter == null || await presenter.onBackPressed());
  }

  @mustCallSuper
  @protected
  @override
  void onRootTap() {
    super.onRootTap();
    presenter?.onRootTap();
  }

  @mustCallSuper
  @protected
  @override
  Widget onBuild(BuildContext context) {
    final Widget widget = super.onBuild(context);
    presenter?.onBuild(context);
    return widget;
  }

  @override
  bool get needCallBackPressed => presenter != null && presenter.needCallBackPressed;
}
