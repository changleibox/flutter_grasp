/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2020/5/28.
///
/// 监听tab切换，实现在tab切换时刷新数据
mixin TabPresenterMixin<T extends StatefulWidget> on Presenter<T> {
  TabController _tabController;
  int _index;

  @mustCallSuper
  @override
  void initState() {
    _index = tabIndex;
    super.initState();
  }

  @mustCallSuper
  @override
  void didChangeDependencies() {
    final TabController newTabController = DefaultTabController.of(context);
    assert(() {
      if (newTabController == null) {
        throw FlutterError('No TabController for ${widget.runtimeType}.\n'
            'When creating a ${widget.runtimeType}, you must either provide an explicit '
            'TabController using the "controller" property, or you must ensure that there '
            'is a DefaultTabController above the ${widget.runtimeType}.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());
    if (newTabController == _tabController) {
      return;
    }
    _tabController?.removeListener(onTabChanged);
    _tabController = newTabController;
    _tabController?.addListener(onTabChanged);
    super.didChangeDependencies();
  }

  @mustCallSuper
  @override
  void dispose() {
    _tabController?.removeListener(onTabChanged);
    super.dispose();
  }

  /// tab切换时回调
  void onTabChanged();

  /// 当前页面对应的索引
  int get tabIndex;

  /// 判断是否在当前页
  bool get isCurrentTab {
    final int index = _tabController?.index;
    return index == tabIndex;
  }

  /// 判断tab是否从其他页面回到当前页面
  bool get isTabChanged {
    final int index = _tabController?.index;
    if (index == _index || indexIsChanging) {
      return false;
    }
    _index = index;
    return isCurrentTab;
  }

  /// 返回[TabController]是否正在改变
  bool get indexIsChanging {
    return _tabController?.indexIsChanging == true;
  }

  /// [TabController]动画对象
  Animation<double> get animation => _tabController?.animation;
}
