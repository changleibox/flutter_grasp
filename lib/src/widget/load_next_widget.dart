/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grasp/src/widget/widget_group.dart';

/// Created by changlei on 12/31/20.
///
/// 加载下一页控件
/// 加载更多控件，显示在最底部
class LoadNextWidget extends StatelessWidget {
  /// 构造函数
  const LoadNextWidget({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.hasNext = false,
    this.isLoading = false,
  }) : super(key: key);

  /// 滚动方向
  final Axis scrollDirection;

  /// 是否有下一页
  final bool hasNext;

  /// 是否正在加载
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isVertical = scrollDirection == Axis.vertical;
    var text = isLoading && hasNext
        ? '正在加载更多'
        : hasNext
            ? '上拉加载更多'
            : '我是有底线的';
    if (!isVertical) {
      text = List<String>.generate(text.length, (int index) => text[index]).join('\n');
    }

    final Widget divider = isVertical
        ? Expanded(
            child: Container(
              height: 1.0 / MediaQuery.of(context).devicePixelRatio,
              color: Theme.of(context).dividerColor,
            ),
          )
        : Expanded(
            child: Container(
              width: 1.0 / MediaQuery.of(context).devicePixelRatio,
              color: Theme.of(context).dividerColor,
            ),
          );

    return SizedBox(
      width: isVertical ? double.infinity : 44,
      height: isVertical ? 44 : double.infinity,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isVertical ? 10 : 0,
            vertical: isVertical ? 0 : 10,
          ),
          child: WidgetGroup.spacing(
            alignment: MainAxisAlignment.center,
            direction: isVertical ? Axis.horizontal : Axis.vertical,
            spacing: 10,
            children: <Widget>[
              divider,
              WidgetGroup.spacing(
                mainAxisSize: MainAxisSize.min,
                alignment: MainAxisAlignment.center,
                direction: isVertical ? Axis.horizontal : Axis.vertical,
                spacing: 4,
                children: <Widget>[
                  if (hasNext && isLoading)
                    const CupertinoActivityIndicator(
                      radius: 8,
                    ),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
              divider,
            ],
          ),
        ),
      ),
    );
  }
}
