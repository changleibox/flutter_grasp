/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/src/widget/support_activity_indicator.dart';

const double _defaultRefreshTriggerPullDistance = 100.0;
const double _defaultRefreshIndicatorExtent = 60.0;

/// Created by box on 2020/3/30.
///
/// 自定义的下拉刷新
class SupportSliverRefreshIndicator extends StatelessWidget {
  /// 构造函数
  const SupportSliverRefreshIndicator({
    Key? key,
    this.onRefresh,
    this.refreshTriggerPullDistance = _defaultRefreshTriggerPullDistance,
    this.refreshIndicatorExtent = _defaultRefreshIndicatorExtent,
  })  : assert(refreshTriggerPullDistance > 0.0),
        assert(refreshIndicatorExtent >= 0.0),
        assert(
            refreshTriggerPullDistance >= refreshIndicatorExtent,
            'The refresh indicator cannot take more space in its final state '
            'than the amount initially created by overscrolling.'),
        super(key: key);

  /// 刷新回调
  final RefreshCallback? onRefresh;

  /// 刷新距离
  final double refreshTriggerPullDistance;

  /// 刷新区域
  final double refreshIndicatorExtent;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      builder: buildSimpleRefreshIndicator,
      refreshIndicatorExtent: refreshIndicatorExtent,
      refreshTriggerPullDistance: _defaultRefreshTriggerPullDistance,
    );
  }

  /// Builds a simple refresh indicator that fades in a bottom aligned down
  /// arrow before the refresh is triggered, a [CupertinoActivityIndicator]
  /// during the refresh and fades the [CupertinoActivityIndicator] away when
  /// the refresh is done.
  static Widget buildSimpleRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    const Curve opacityCurve = Interval(0.4, 1.0, curve: Curves.easeInOut);
    final opacityOffset = math.min(pulledExtent / refreshIndicatorExtent, 1.0);
    final progressOffset = math.min(pulledExtent / refreshTriggerPullDistance, 1.0);
    Widget child = Opacity(
      opacity: opacityCurve.transform(opacityOffset),
      child: const SupportCupertinoActivityIndicator(
        radius: 12.0,
      ),
    );
    if (refreshState == RefreshIndicatorMode.drag) {
      child = SupportCupertinoActivityIndicator(
        radius: 12.0,
        animating: false,
        position: progressOffset * 0.9,
      );
    }
    return ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: child,
        ),
      ),
    );
  }
}
