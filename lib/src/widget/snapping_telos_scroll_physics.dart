/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

/// Created by changlei on 2020/7/27.
///
/// 吸附到两端
class SnappingTelosScrollPhysics extends ScrollPhysics {
  /// 回弹
  const SnappingTelosScrollPhysics({
    ScrollPhysics? parent,
    this.maxScrollOffset,
  }) : super(parent: parent);

  /// 最大偏移量
  final double? maxScrollOffset;

  /// 最大偏移量
  @protected
  double? computeMaxScrollExtent(ScrollMetrics position) => maxScrollOffset;

  double _maxScrollExtent(ScrollMetrics position) {
    final minScrollExtent = position.minScrollExtent;
    final maxScrollExtent = computeMaxScrollExtent(position);
    assert(maxScrollExtent != null && maxScrollExtent >= minScrollExtent);
    return maxScrollExtent ?? 1;
  }

  @override
  SnappingTelosScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappingTelosScrollPhysics(
      parent: buildParent(ancestor),
      maxScrollOffset: maxScrollOffset,
    );
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / _maxScrollExtent(position);
  }

  double _getPixels(ScrollMetrics position, double page) {
    return position.minScrollExtent + _maxScrollExtent(position) * page;
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    var page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final minScrollExtent = position.minScrollExtent;
    final maxScrollExtent = _maxScrollExtent(position);
    if ((velocity <= 0.0 && position.pixels <= minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Create a test simulation to see where it would have ballistically fallen
    // naturally without settling onto items.
    final testFrictionSimulation = super.createBallisticSimulation(position, velocity);

    // If it was going to end up past the scroll extent, defer back to the
    // parent physics' ballistics again which should put us on the scrollable's
    // boundary.
    if (testFrictionSimulation != null &&
        (testFrictionSimulation.x(double.infinity) == minScrollExtent ||
            testFrictionSimulation.x(double.infinity) == maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final targetPixels = _getTargetPixels(position, tolerance, velocity);

    // If there's no velocity and we're already at where we intend to land,
    // do nothing.
    if (velocity.abs() < tolerance.velocity && (targetPixels - position.pixels).abs() < tolerance.distance) {
      return null;
    }

    if (targetPixels != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, targetPixels, velocity, tolerance: tolerance);
    }

    // Create a new friction simulation except the drag will be tweaked to land
    // exactly on the item closest to the natural stopping point.
    return FrictionSimulation.through(
      position.pixels,
      targetPixels,
      velocity,
      tolerance.velocity * velocity.sign,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
