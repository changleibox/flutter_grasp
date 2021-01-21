/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2020-02-13.
///
/// 绑定在[state]上处理逻辑
abstract class Presenter<T extends StatefulWidget> implements StateAbstractMethod<T> {
  /// 绑定的state
  StateAbstractMethod<T> _state;

  @mustCallSuper
  set state(StateAbstractMethod<T> state) {
    assert(_state == null, 'state只能调用一次');
    _state = state;
  }

  @protected
  @mustCallSuper
  @override
  bool get mounted => _state?.mounted;

  @protected
  @mustCallSuper
  @override
  T get widget => _state?.widget;

  @protected
  @mustCallSuper
  @override
  BuildContext get context => _state?.context;

  /// 此方法不要在initState中调用
  @protected
  @mustCallSuper
  RouteSettings get settings => ModalRoute.of(context).settings;

  /// 此方法不要在initState中调用
  @protected
  @mustCallSuper
  dynamic get arguments => settings.arguments;

  @mustCallSuper
  @override
  void initState() {}

  @mustCallSuper
  @override
  void didUpdateWidget(covariant T oldWidget) {}

  @mustCallSuper
  @override
  void reassemble() {}

  @mustCallSuper
  @override
  void deactivate() {}

  @mustCallSuper
  @override
  void dispose() {}

  @mustCallSuper
  @override
  void didChangeDependencies() {}

  @protected
  @mustCallSuper
  @override
  void markNeedsBuild([VoidCallback fn]) => _state?.markNeedsBuild(fn);

  @mustCallSuper
  @override
  void onPostFrame(Duration timeStamp) {}

  @protected
  @override
  void hideKeyboard() => _state?.hideKeyboard();
}
