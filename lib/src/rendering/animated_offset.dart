// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

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
class RenderAnimatedOffset extends RenderAnimatedShiftedBox {
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
  RenderAnimatedOffset({
    @required TickerProvider vsync,
    @required Duration duration,
    Duration reverseDuration,
    Curve curve = Curves.linear,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection textDirection,
    RenderBox child,
  }) : super(
          child: child,
          alignment: alignment,
          textDirection: textDirection,
          duration: duration,
          reverseDuration: reverseDuration,
          vsync: vsync,
          curve: curve,
        );

  final Tween<Offset> _offsetTween = Tween<Offset>();
  Offset _originOffset;

  Offset get _animatedOffset {
    return _offsetTween.evaluate(animation);
  }

  Offset _getOffset(RenderBox box) {
    if (box == null || !hasSize || !attached || !box.hasSize || !box.attached) {
      return null;
    }
    return localToGlobalForParent(box);
  }

  void _layoutAndResize() {
    final Offset currentOffset = _getOffset(child);
    if (nearEqualForOffset(_originOffset, currentOffset, Tolerance.defaultTolerance.distance)) {
      return;
    }
    final Offset animatedOffset = _animatedOffset;
    stop();
    if (currentOffset == null || _originOffset == null) {
      _originOffset = currentOffset;
      return;
    }
    Offset newOriginOffset = _originOffset;
    if (animatedOffset != null) {
      newOriginOffset -= animatedOffset;
    }
    _offsetTween.begin = currentOffset - newOriginOffset;
    _offsetTween.end = Offset.zero;
    _originOffset = currentOffset;
    restartAnimation();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _layoutAndResize();
    if (_animatedOffset != null) {
      offset -= _animatedOffset;
    }
    super.paint(context, offset);
  }
}
