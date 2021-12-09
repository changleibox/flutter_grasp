/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/widgets.dart';

import 'animated_shifted_box.dart';

/// A render object that animates its size to its child's size over a given
/// [duration] and with a given [curve]. If the child's size itself animates
/// (i.e. if it changes size two frames in a row, as opposed to abruptly
/// changing size in one frame then remaining that size in subsequent frames),
/// this render object sizes itself to fit the child instead of animating
/// itself.
///
/// When the child overflows the current animated size of this render object, it
/// is clipped.
class RenderAnimatedBoundary extends RenderAnimatedShiftedBox {
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
  RenderAnimatedBoundary({
    required TickerProvider vsync,
    required Duration duration,
    Duration? reverseDuration,
    Curve curve = Curves.linear,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection? textDirection,
    RenderBox? child,
  }) : super(
          child: child,
          alignment: alignment,
          textDirection: textDirection,
          duration: duration,
          reverseDuration: reverseDuration,
          vsync: vsync,
          curve: curve,
        );

  final RectTween _rectTween = RectTween();
  Rect? _originRect;

  Rect? get _animatedRect {
    return _rectTween.evaluate(animation);
  }

  @override
  void resolvePerformLayout() {
    final animatedRect = _animatedRect;
    var newSize = child?.size ?? Size.zero;
    if (animatedRect != null) {
      newSize = Size(
        newSize.width - animatedRect.width,
        newSize.height - animatedRect.height,
      );
    }
    size = constraints.constrain(newSize);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child == null || constraints.isTight) {
      return constraints.smallest;
    }
    return constraints.constrain(_animatedRect?.size ?? child!.getDryLayout(constraints));
  }

  Rect? _getBounding(RenderBox? box) {
    if (box == null || !hasSize || !attached || !box.hasSize || !box.attached) {
      return null;
    }
    return boundingBoxForParent(box);
  }

  void _layoutAndResize() {
    final currentRect = _getBounding(child);
    if (nearEqualForRect(_originRect, currentRect, Tolerance.defaultTolerance.distance)) {
      return;
    }
    final animatedRect = _animatedRect;
    stop();
    if (currentRect == null || _originRect == null) {
      _originRect = currentRect;
      return;
    }
    var newOriginRect = _originRect!;
    if (animatedRect != null) {
      newOriginRect = Rect.fromPoints(
        newOriginRect.topLeft - animatedRect.topLeft,
        newOriginRect.bottomRight - animatedRect.bottomRight,
      );
    }
    _rectTween.begin = Rect.fromPoints(
      currentRect.topLeft - newOriginRect.topLeft,
      currentRect.bottomRight - newOriginRect.bottomRight,
    );
    _rectTween.end = Rect.zero;
    _originRect = currentRect;
    restartAnimation();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _layoutAndResize();
    final animatedRect = _animatedRect;
    if (animatedRect != null) {
      offset -= animatedRect.topLeft + alongOffsetOfSize(animatedRect.size);
    }
    super.paint(context, offset);
  }
}
