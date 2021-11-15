/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_grasp/src/rendering/animated_boundary.dart';
import 'package:flutter_grasp/src/rendering/animated_shifted_box_boundary.dart';

/// Created by box on 2020/8/22.
///
/// 在位置和大小改变的时候，加个动画，请在这个布局的根布局上加上[AnimatedShiftedBoxParent]以获取到他的准确位置
class AnimatedBoundary extends StatefulWidget {
  /// Creates a widget that animates its size to match that of its child.
  ///
  /// The [curve] and [duration] arguments must not be null.
  const AnimatedBoundary({
    Key? key,
    this.child,
    this.alignment = Alignment.center,
    this.curve = Curves.linear,
    required this.duration,
    this.reverseDuration,
  }) : super(key: key);

  /// child
  final Widget? child;

  /// The alignment of the child within the parent when the parent is not yet
  /// the same size as the child.
  ///
  /// The x and y values of the alignment control the horizontal and vertical
  /// alignment, respectively. An x value of -1.0 means that the left edge of
  /// the child is aligned with the left edge of the parent whereas an x value
  /// of 1.0 means that the right edge of the child is aligned with the right
  /// edge of the parent. Other values interpolate (and extrapolate) linearly.
  /// For example, a value of 0.0 means that the center of the child is aligned
  /// with the center of the parent.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// The animation curve when transitioning this widget's size to match the
  /// child's size.
  final Curve curve;

  /// The duration when transitioning this widget's size to match the child's
  /// size.
  final Duration duration;

  /// The duration when transitioning this widget's size to match the child's
  /// size when going in reverse.
  ///
  /// If not specified, defaults to [duration].
  final Duration? reverseDuration;

  @override
  _AnimatedBoundaryState createState() => _AnimatedBoundaryState();
}

class _AnimatedBoundaryState extends State<AnimatedBoundary> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return _AnimatedBoundary(
      alignment: widget.alignment,
      curve: widget.curve,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      vsync: this,
      child: widget.child,
    );
  }
}

class _AnimatedBoundary extends SingleChildRenderObjectWidget {
  /// Creates a widget that animates its size to match that of its child.
  ///
  /// The [curve] and [duration] arguments must not be null.
  const _AnimatedBoundary({
    Key? key,
    Widget? child,
    this.alignment = Alignment.center,
    this.curve = Curves.linear,
    required this.duration,
    this.reverseDuration,
    required this.vsync,
  }) : super(key: key, child: child);

  /// The alignment of the child within the parent when the parent is not yet
  /// the same size as the child.
  ///
  /// The x and y values of the alignment control the horizontal and vertical
  /// alignment, respectively. An x value of -1.0 means that the left edge of
  /// the child is aligned with the left edge of the parent whereas an x value
  /// of 1.0 means that the right edge of the child is aligned with the right
  /// edge of the parent. Other values interpolate (and extrapolate) linearly.
  /// For example, a value of 0.0 means that the center of the child is aligned
  /// with the center of the parent.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// The animation curve when transitioning this widget's size to match the
  /// child's size.
  final Curve curve;

  /// The duration when transitioning this widget's size to match the child's
  /// size.
  final Duration duration;

  /// The duration when transitioning this widget's size to match the child's
  /// size when going in reverse.
  ///
  /// If not specified, defaults to [duration].
  final Duration? reverseDuration;

  /// The [TickerProvider] for this widget.
  final TickerProvider vsync;

  void _debugParent(BuildContext context) {
    final animatedPositionParent = context.findAncestorRenderObjectOfType<RenderAnimatedShiftedBoxBoundary>();
    assert(animatedPositionParent != null, '请使用$RenderAnimatedShiftedBoxBoundary包裹根控件');
  }

  @override
  RenderAnimatedBoundary createRenderObject(BuildContext context) {
    _debugParent(context);
    return RenderAnimatedBoundary(
      alignment: alignment,
      duration: duration,
      reverseDuration: reverseDuration,
      curve: curve,
      vsync: vsync,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnimatedBoundary renderObject) {
    _debugParent(context);
    renderObject
      ..alignment = alignment
      ..duration = duration
      ..reverseDuration = reverseDuration
      ..curve = curve
      ..vsync = vsync
      ..textDirection = Directionality.of(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment, defaultValue: Alignment.topCenter));
    properties.add(IntProperty('duration', duration.inMilliseconds, unit: 'ms'));
    properties.add(IntProperty('reverseDuration', reverseDuration?.inMilliseconds, unit: 'ms', defaultValue: null));
  }
}
