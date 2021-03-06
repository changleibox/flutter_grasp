/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'child_delegate.dart';

/// Created by changlei on 2020-02-13.
///
/// 一组控件，实际上就是对row和column的封装，方便实现统一的边距和分割线
class WidgetGroup extends StatelessWidget {
  /// 构造函数
  WidgetGroup({
    Key? key,
    this.alignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    required List<Widget>? children,
    Widget? divider,
    this.direction = Axis.horizontal,
  })  : assert(crossAxisAlignment != CrossAxisAlignment.baseline || textBaseline != null),
        childrenDelegate = divider == null || children == null
            ? ChildListDelegate(
                children ?? <Widget>[],
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                addSemanticIndexes: false,
              )
            : ChildBuilderDelegate(
                (BuildContext context, int index) {
                  final itemIndex = index ~/ 2;
                  Widget widget;
                  if (index.isEven) {
                    widget = children[itemIndex];
                  } else {
                    widget = divider;
                  }
                  return widget;
                },
                childCount: _computeActualChildCount(children.length),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                addSemanticIndexes: false,
                semanticIndexCallback: (Widget _, int index) {
                  return index.isEven ? index ~/ 2 : null;
                },
              ),
        super(key: key);

  /// 可以加分割距离
  factory WidgetGroup.spacing({
    Key? key,
    MainAxisAlignment alignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    required List<Widget>? children,
    double? spacing = 0,
    Axis direction = Axis.horizontal,
  }) {
    assert(spacing == null || spacing >= 0);
    Widget? divider;
    if (spacing != null && spacing > 0) {
      divider = Container(
        width: direction == Axis.vertical ? null : spacing,
        height: direction == Axis.vertical ? spacing : null,
        padding: EdgeInsets.zero,
      );
    }
    return WidgetGroup(
      key: key,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      direction: direction,
      divider: divider,
      children: children,
    );
  }

  /// 自定义item
  WidgetGroup.builder({
    Key? key,
    this.alignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    required IndexedWidgetBuilder itemBuilder,
    required int? itemCount,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.direction = Axis.horizontal,
  })  : assert(crossAxisAlignment != CrossAxisAlignment.baseline || textBaseline != null),
        assert(itemCount == null || itemCount >= 0),
        childrenDelegate = ChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          addSemanticIndexes: false,
        ),
        super(key: key);

  /// build item和分割器
  WidgetGroup.separated({
    Key? key,
    this.alignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatorBuilder,
    required int? itemCount,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.direction = Axis.horizontal,
  })  : assert(crossAxisAlignment != CrossAxisAlignment.baseline || textBaseline != null),
        assert(itemCount == null || itemCount >= 0),
        childrenDelegate = ChildBuilderDelegate(
          (BuildContext context, int index) {
            final itemIndex = index ~/ 2;
            Widget widget;
            if (index.isEven) {
              widget = itemBuilder(context, itemIndex);
            } else {
              widget = separatorBuilder(context, itemIndex);
            }
            return widget;
          },
          childCount: _computeActualChildCount(itemCount!),
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          addSemanticIndexes: false,
          semanticIndexCallback: (Widget _, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        ),
        super(key: key);

  /// 自定义
  const WidgetGroup.custom({
    Key? key,
    this.alignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    required this.childrenDelegate,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  /// 主轴对齐方式
  final MainAxisAlignment alignment;

  /// 主轴大小
  final MainAxisSize mainAxisSize;

  /// 交叉轴对齐方式
  final CrossAxisAlignment crossAxisAlignment;

  /// [textDirection]
  final TextDirection? textDirection;

  /// 处置方向的[TextDirection]
  final VerticalDirection verticalDirection;

  /// 设置对准基线
  final TextBaseline? textBaseline;

  /// 方向
  final Axis direction;

  /// 构建children
  final ChildDelegate childrenDelegate;

  @override
  Widget build(BuildContext context) {
    final childCount = childrenDelegate.estimatedChildCount ?? 0;
    final children = List<Widget>.generate(childCount, (int index) {
      return childrenDelegate.build(context, index)!;
    });

    switch (direction) {
      case Axis.horizontal:
        return Row(
          mainAxisAlignment: alignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children,
        );
      case Axis.vertical:
        return Column(
          mainAxisAlignment: alignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children,
        );
    }
  }

  // Helper method to compute the actual child count for the separated constructor.
  static int _computeActualChildCount(int itemCount) {
    return max(0, itemCount * 2 - 1);
  }
}
