/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'animated_shifted_box_boundary.dart';

/// A render object that animates its size to its child's size over a given
/// [duration] and with a given [curve]. If the child's size itself animates
/// (i.e. if it changes size two frames in a row, as opposed to abruptly
/// changing size in one frame then remaining that size in subsequent frames),
/// this render object sizes itself to fit the child instead of animating
/// itself.
///
/// When the child overflows the current animated size of this render object, it
/// is clipped.
abstract class RenderAnimatedShiftedBox extends RenderAligningShiftedBox {
  /// Creates a render object that animates its size to match its child.
  /// The [duration] and [curve] arguments define the animation.
  ///
  /// The [alignment] argument is used to align the child when the parent is not
  /// (yet) the same size as the child.
  ///
  /// The [duration] is required.
  ///
  /// The [vsync] should specify a [TickerProvider] for the animation
  /// controller.
  ///
  /// The arguments [duration], [curve], [alignment], and [vsync] must
  /// not be null.
  RenderAnimatedShiftedBox({
    required TickerProvider vsync,
    required Duration duration,
    Duration? reverseDuration,
    Curve curve = Curves.linear,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection? textDirection,
    RenderBox? child,
  })  : _vsync = vsync,
        super(child: child, alignment: alignment, textDirection: textDirection) {
    _controller = AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
    )..addListener(() {
        if (_controller.value != _lastValue) {
          markNeedsLayout();
        }
      });
    _animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );
  }

  @override
  bool get alwaysNeedsCompositing => child != null && isAnimating;

  late AnimationController _controller;
  late CurvedAnimation _animation;
  double? _lastValue;

  /// The duration of the animation.
  Duration? get duration => _controller.duration;

  set duration(Duration? value) {
    assert(value != null);
    if (value == _controller.duration) {
      return;
    }
    _controller.duration = value;
  }

  /// The duration of the animation when running in reverse.
  Duration? get reverseDuration => _controller.reverseDuration;

  set reverseDuration(Duration? value) {
    if (value == _controller.reverseDuration) {
      return;
    }
    _controller.reverseDuration = value;
  }

  /// The curve of the animation.
  Curve get curve => _animation.curve;

  set curve(Curve value) {
    if (value == _animation.curve) {
      return;
    }
    _animation.curve = value;
  }

  /// Whether the size is being currently animated towards the child's size.
  ///
  /// See [RenderAnimatedPositionState] for situations when we may not be animating
  /// the size.
  bool get isAnimating => _controller.isAnimating;

  /// value
  @protected
  Animation<double> get animation => _animation;

  /// The [TickerProvider] for the [AnimationController] that runs the animation.
  TickerProvider get vsync => _vsync;
  TickerProvider _vsync;

  set vsync(TickerProvider value) {
    if (value == _vsync) {
      return;
    }
    _vsync = value;
    _controller.resync(vsync);
  }

  Alignment? _resolvedAlignment;

  void _resolve() {
    if (_resolvedAlignment != null) {
      return;
    }
    _resolvedAlignment = alignment.resolve(textDirection);
  }

  void _markNeedResolution() {
    _resolvedAlignment = null;
    markNeedsLayout();
  }

  @override
  set alignment(AlignmentGeometry value) {
    super.alignment = value;
    _markNeedResolution();
  }

  @override
  set textDirection(TextDirection? value) {
    super.textDirection = value;
    _markNeedResolution();
  }

  @override
  void detach() {
    _controller.stop();
    super.detach();
  }

  @override
  void performLayout() {
    _lastValue = _controller.value;
    final constraints = this.constraints;
    if (child == null) {
      _controller.stop();
      size = constraints.smallest;
      child?.layout(constraints);
      return;
    }

    child?.layout(constraints, parentUsesSize: true);
    resolvePerformLayout();
    alignChild();
  }

  /// 类似于[performLayout]
  @protected
  void resolvePerformLayout() {
    size = constraints.constrain(child?.size ?? Size.zero);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child == null || constraints.isTight) {
      return constraints.smallest;
    }
    return constraints.constrain(child!.getDryLayout(constraints));
  }

  /// 重启动画
  void restartAnimation() {
    _lastValue = _controller.lowerBound;
    _controller.forward(from: _lastValue);
  }

  /// 开始
  void forward({double? from}) {
    _controller.forward(from: from);
  }

  /// 停止
  void stop({bool canceled = true}) {
    _controller.stop(canceled: canceled);
  }

  /// 判断是否在[epsilon]附近
  bool nearEqualForOffset(Offset? a, Offset? b, double epsilon) {
    return nearEqual(a?.dx, b?.dx, epsilon) && nearEqual(a?.dy, b?.dy, epsilon);
  }

  /// 判断是否在[epsilon]附近
  bool nearEqualForRect(Rect? a, Rect? b, double epsilon) {
    return nearEqualForOffset(a?.topLeft, b?.topLeft, epsilon) &&
        nearEqualForOffset(a?.bottomRight, b?.bottomRight, epsilon);
  }

  /// Returns the offset that is this fraction in the direction of the given offset.
  Offset alongOffset(Offset offset) {
    _resolve();
    if (_resolvedAlignment != null) {
      return _resolvedAlignment!.alongOffset(offset);
    }
    return Offset.zero;
  }

  /// Returns the offset that is this fraction in the direction of the given relativeSize.
  Offset alongOffsetOfSize(Size relativeSize) {
    return alongOffset(relativeSize.bottomRight(Offset.zero));
  }

  /// 获取box的边界
  @protected
  Rect boundingBoxOfAncestorType<T>(RenderBox? box) {
    assert(box != null && box.hasSize);
    return MatrixUtils.transformRect(
      _getTransformToOfAncestorType<T>(box!),
      Offset.zero & box.size,
    );
  }

  /// 获取box的位置
  @protected
  Offset localToGlobalOfAncestorType<T>(RenderBox? box) {
    assert(box != null && box.hasSize);
    return MatrixUtils.transformPoint(
      _getTransformToOfAncestorType<T>(box!),
      Offset.zero,
    );
  }

  /// 获取相对于[RenderAnimatedShiftedBoxBoundary]的边界
  Rect boundingBoxForParent(RenderBox box) {
    return boundingBoxOfAncestorType<RenderAnimatedShiftedBoxBoundary>(box);
  }

  /// 获取相对于[RenderAnimatedShiftedBoxBoundary]的位置
  Offset localToGlobalForParent(RenderBox box) {
    return localToGlobalOfAncestorType<RenderAnimatedShiftedBoxBoundary>(box);
  }

  Matrix4 _getTransformToOfAncestorType<T>(RenderBox box) {
    assert(attached);
    if (T == dynamic) {
      return box.getTransformTo(null);
    }
    final renderers = <RenderObject>[];
    for (RenderObject renderer = this; renderer is! T; renderer = renderer.parent as RenderObject) {
      renderers.add(renderer);
    }
    final transform = Matrix4.identity();
    for (var index = renderers.length - 1; index > 0; index -= 1) {
      renderers[index].applyPaintTransform(renderers[index - 1], transform);
    }
    return transform;
  }
}
