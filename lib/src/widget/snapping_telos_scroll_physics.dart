/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

/// Created by changlei on 2020/7/27.
///
/// 吸附到两端
class SnappingTelosScrollPhysics extends ScrollPhysics {
  /// 回弹
  const SnappingTelosScrollPhysics({
    ScrollPhysics parent,
    this.maxScrollOffset,
  }) : super(parent: parent);

  /// 最大偏移量
  final double maxScrollOffset;

  /// 最大偏移量
  @protected
  double computeMaxScrollOffset(ScrollMetrics position) => maxScrollOffset;

  @override
  SnappingTelosScrollPhysics applyTo(ScrollPhysics ancestor) {
    return SnappingTelosScrollPhysics(
      parent: buildParent(ancestor),
      maxScrollOffset: maxScrollOffset,
    );
  }

  double _getPage(ScrollMetrics position) {
    final double maxScrollOffset = computeMaxScrollOffset(position);
    assert(maxScrollOffset != null);
    return position.pixels / computeMaxScrollOffset(position);
  }

  double _getPixels(ScrollMetrics position, double page) {
    final double maxScrollOffset = computeMaxScrollOffset(position);
    assert(maxScrollOffset != null);
    return position.minScrollExtent + maxScrollOffset * page;
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
    final double maxScrollOffset = computeMaxScrollOffset(position);
    assert(maxScrollOffset != null);
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= maxScrollOffset)) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Create a test simulation to see where it would have ballistically fallen
    // naturally without settling onto items.
    final Simulation testFrictionSimulation = super.createBallisticSimulation(position, velocity);

    // If it was going to end up past the scroll extent, defer back to the
    // parent physics' ballistics again which should put us on the scrollable's
    // boundary.
    if (testFrictionSimulation != null &&
        (testFrictionSimulation.x(double.infinity) == position.minScrollExtent ||
            testFrictionSimulation.x(double.infinity) == position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final double target = _getTargetPixels(position, tolerance, velocity);

    // If there's no velocity and we're already at where we intend to land,
    // do nothing.
    if (velocity.abs() < tolerance.velocity && (target - position.pixels).abs() < tolerance.distance) {
      return null;
    }

    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
    }

    // Create a new friction simulation except the drag will be tweaked to land
    // exactly on the item closest to the natural stopping point.
    return FrictionSimulation.through(
      position.pixels,
      target,
      velocity,
      tolerance.velocity * velocity.sign,
    );
  }
}
