/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/rendering.dart';

/// Created by box on 2020/8/22.
///
/// 这个控件用在[AnimatedOffset]和[AnimatedBoundary]控件上用来界定他们的边界，以获取到准确的位置，
/// 不加这个控件的话，在滚动布局上，在滚动的适合，会有闪屏，出现这个问题的原因是他们在屏幕中的位置一直在变化
class RenderAnimatedShiftedBoxBoundary extends RenderRepaintBoundary {
  /// 初始化
  RenderAnimatedShiftedBoxBoundary({RenderBox? child}) : super(child: child);
}
