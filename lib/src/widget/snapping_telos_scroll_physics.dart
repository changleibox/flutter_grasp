/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';

/// Created by changlei on 2020/7/27.
///
/// 吸附到两端
class SnappingTelosScrollPhysics extends ScrollPhysics {
  /// 回弹
  const SnappingTelosScrollPhysics({
    ScrollPhysics parent,
    @required this.midScrollOffset,
  })  : assert(midScrollOffset != null),
        _maxScrollOffset = midScrollOffset * 2,
        super(parent: parent);

  /// 中间的偏移量。用于区分
  final double midScrollOffset;

  /// 最大偏移量
  final double _maxScrollOffset;

  @override
  SnappingTelosScrollPhysics applyTo(ScrollPhysics ancestor) {
    return SnappingTelosScrollPhysics(
      parent: buildParent(ancestor),
      midScrollOffset: midScrollOffset,
    );
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / _maxScrollOffset;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return position.minScrollExtent + _maxScrollOffset * page;
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    final double pixels = position.pixels;
    if ((velocity <= 0.0 && pixels <= position.minScrollExtent) || (velocity >= 0.0 && pixels >= _maxScrollOffset)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != pixels) {
      return ScrollSpringSimulation(spring, pixels, target, velocity, tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
