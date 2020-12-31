// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_grasp/src/rendering/animated_shifted_box_boundary.dart';

/// Created by box on 2020/8/22.
///
/// 这个控件用在[AnimatedOffset]和[AnimatedBoundary]控件上用来界定他们的边界，以获取到准确的位置，
/// 不加这个控件的话，在滚动布局上，在滚动的适合，会有闪屏，出现这个问题的原因是他们在屏幕中的位置一直在变化
class AnimatedShiftedBoxBoundary extends RepaintBoundary {
  /// 这个控件用在[AnimatedOffset]和[AnimatedBoundary]控件上用来界定他们的边界，以获取到准确的位置
  const AnimatedShiftedBoxBoundary({Key key, Widget child}) : super(key: key, child: child);

  /// Wraps the given child in a [AnimatedShiftedBoxBoundary].
  ///
  /// The key for the [AnimatedShiftedBoxBoundary] is derived either from the child's key
  /// (if the child has a non-null key) or from the given `childIndex`.
  factory AnimatedShiftedBoxBoundary.wrap(Widget child, int childIndex) {
    assert(child != null);
    final Key key = child.key != null ? ValueKey<Key>(child.key) : ValueKey<int>(childIndex);
    return AnimatedShiftedBoxBoundary(key: key, child: child);
  }

  /// Wraps each of the given children in [AnimatedShiftedBoxBoundary]s.
  ///
  /// The key for each [AnimatedShiftedBoxBoundary] is derived either from the wrapped
  /// child's key (if the wrapped child has a non-null key) or from the wrapped
  /// child's index in the list.
  static List<AnimatedShiftedBoxBoundary> wrapAll(List<Widget> widgets) {
    final List<AnimatedShiftedBoxBoundary> result = <AnimatedShiftedBoxBoundary>[]..length = widgets.length;
    for (int i = 0; i < result.length; ++i) {
      result[i] = AnimatedShiftedBoxBoundary.wrap(widgets[i], i);
    }
    return result;
  }

  @override
  RenderAnimatedShiftedBoxBoundary createRenderObject(BuildContext context) {
    return RenderAnimatedShiftedBoxBoundary();
  }
}
