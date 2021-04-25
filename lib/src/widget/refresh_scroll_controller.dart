/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grasp/src/widget/support_custom_scroll_view.dart';

const double _defaultRefreshTriggerPullDistance = 100.0;
const Duration _defaultDuration = Duration(milliseconds: 300);

/// 刷新控制器样式
enum RefreshControllerStyle {
  /// material
  material,

  /// cupertino
  cupertino,
}

/// Created by changlei on 12/31/20.
///
/// 刷新控制器
/// 手动刷新控制器，效果为[RefreshIndicator]的效果
abstract class RefreshScrollController {
  /// material样式
  factory RefreshScrollController.material() = _MaterialRefreshScrollController;

  /// cupertino样式
  factory RefreshScrollController.cupertino() = _CupertinoRefreshScrollController;

  /// 静默样式
  factory RefreshScrollController.manual({RefreshControllerStyle style}) = _ManualRefreshScrollController;

  /// 刷新控件的key
  Key get refreshKey;

  /// 刷新回调
  Future<void> onRefresh();

  /// 加载
  void attach(SupportRefreshCallback onRefresh);

  /// 是否有终端
  bool get hasClients;

  /// 释放
  void dispose();

  /// 样式，[Cupertino]或者[Material]或者自定义
  RefreshControllerStyle get style;
}

/// Material风格的刷新控制器
class _MaterialRefreshScrollController implements RefreshScrollController {
  @override
  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Future<void> onRefresh() {
    final RefreshIndicatorState currentState = refreshKey.currentState;
    if (currentState == null) {
      return Future<void>.value();
    }
    return currentState.show();
  }

  @override
  void attach(SupportRefreshCallback onRefresh) {}

  @override
  bool get hasClients => refreshKey.currentState != null;

  @override
  void dispose() {}

  @override
  RefreshControllerStyle get style => RefreshControllerStyle.material;
}

/// Cupertino风格的刷新控制器
class _CupertinoRefreshScrollController implements RefreshScrollController {
  @override
  final GlobalKey refreshKey = GlobalKey<State<StatefulWidget>>();

  @override
  Future<void> onRefresh() {
    return moveTo(-_defaultRefreshTriggerPullDistance, clamp: false);
  }

  Future<void> moveToTop() {
    return moveTo(0);
  }

  Future<void> moveTo(double to, {bool clamp = true}) {
    assert(to != null);
    assert(clamp != null);
    if (!hasClients) {
      return Future<void>.value();
    }
    return position.moveTo(
      to,
      duration: _defaultDuration,
      curve: Curves.linearToEaseOut,
      clamp: clamp,
    );
  }

  @override
  void attach(SupportRefreshCallback onRefresh) {}

  @override
  bool get hasClients => position != null;

  ScrollPosition get position {
    final BuildContext currentContext = refreshKey.currentContext;
    if (currentContext == null) {
      return null;
    }
    return Scrollable.of(currentContext)?.position;
  }

  @override
  void dispose() {}

  @override
  RefreshControllerStyle get style => RefreshControllerStyle.cupertino;
}

/// 另一种方式的手动刷新控制器，效果为在没有数据和正在加载时，显示'正在加载……'
class _ManualRefreshScrollController implements RefreshScrollController {
  _ManualRefreshScrollController({RefreshControllerStyle style}) : style = style ?? _defaultStyle;

  /// 刷新器的样式
  @override
  final RefreshControllerStyle style;

  AsyncCallback _onManualRefresh;

  @override
  Future<void> onRefresh() {
    if (_onManualRefresh == null) {
      return Future<void>.value();
    }
    return _onManualRefresh();
  }

  @override
  void attach(SupportRefreshCallback onRefresh) {
    _onManualRefresh = onRefresh;
  }

  @override
  bool get hasClients => _onManualRefresh != null;

  @override
  void dispose() {}

  @override
  Key get refreshKey => null;

  static RefreshControllerStyle get _defaultStyle {
    if (Platform.isIOS || Platform.isMacOS || Platform.isLinux) {
      return RefreshControllerStyle.cupertino;
    }
    return RefreshControllerStyle.material;
  }
}
