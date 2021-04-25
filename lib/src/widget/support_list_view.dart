/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2020-02-13.
///
/// 对[SupportCustomScrollView]的简单封装
class SupportListView extends StatelessWidget {
  /// 构造函数
  SupportListView({
    Key key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    List<Widget> children = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.loadOptionsBuilder = const DefaultLoadOptionsBuilder(),
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.loadNextBuilder = SupportCustomScrollView.buildLoadNext,
    this.placeholderBuilder = SupportCustomScrollView.buildPlaceholder,
  })  : assert(loadOptionsBuilder != null),
        _sliverListView = SliverListView(
          children: children,
          padding: EdgeInsets.zero,
          itemExtent: itemExtent,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          scrollDirection: scrollDirection,
        ),
        super(key: key);

  /// builder构造函数
  SupportListView.builder({
    Key key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.loadOptionsBuilder = const DefaultLoadOptionsBuilder(),
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.loadNextBuilder = SupportCustomScrollView.buildLoadNext,
    this.placeholderBuilder = SupportCustomScrollView.buildPlaceholder,
  })  : assert(loadOptionsBuilder != null),
        assert(itemCount == null || itemCount >= 0),
        assert(semanticChildCount == null || semanticChildCount <= itemCount),
        _sliverListView = SliverListView.builder(
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          padding: EdgeInsets.zero,
          itemExtent: itemExtent,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          scrollDirection: scrollDirection,
        ),
        super(key: key);

  /// 分割器
  SupportListView.separated({
    Key key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    @required IndexedWidgetBuilder itemBuilder,
    @required IndexedWidgetBuilder separatorBuilder,
    @required int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    this.loadOptionsBuilder = const DefaultLoadOptionsBuilder(),
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.loadNextBuilder = SupportCustomScrollView.buildLoadNext,
    this.placeholderBuilder = SupportCustomScrollView.buildPlaceholder,
  })  : assert(loadOptionsBuilder != null),
        assert(itemBuilder != null),
        assert(separatorBuilder != null),
        assert(itemCount != null && itemCount >= 0),
        itemExtent = null,
        semanticChildCount = null,
        dragStartBehavior = DragStartBehavior.start,
        _sliverListView = SliverListView.separated(
          itemBuilder: itemBuilder,
          separatorBuilder: separatorBuilder,
          itemCount: itemCount,
          padding: EdgeInsets.zero,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          scrollDirection: scrollDirection,
        ),
        super(key: key);

  /// 自定义
  SupportListView.custom({
    Key key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    @required SliverChildDelegate childrenDelegate,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior,
    this.loadOptionsBuilder = const DefaultLoadOptionsBuilder(),
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.loadNextBuilder = SupportCustomScrollView.buildLoadNext,
    this.placeholderBuilder = SupportCustomScrollView.buildPlaceholder,
  })  : assert(loadOptionsBuilder != null),
        assert(childrenDelegate != null),
        _sliverListView = SliverListView.custom(
          padding: EdgeInsets.zero,
          itemExtent: itemExtent,
          childrenDelegate: childrenDelegate,
          scrollDirection: scrollDirection,
        ),
        super(key: key);

  /// {@template flutter.widgets.scroll_view.controller}
  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  /// {@endtemplate}
  final ScrollController controller;

  /// 滚动方向
  final Axis scrollDirection;

  /// 是否翻转
  final bool reverse;

  /// 是否使用[PrimaryScrollController]
  final bool primary;

  /// 插值器，可以自定义滚动效果
  final ScrollPhysics physics;

  /// 是否压缩包裹
  final bool shrinkWrap;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// item固定高度
  final double itemExtent;

  /// 缓存区域
  final double cacheExtent;

  /// childCount
  final int semanticChildCount;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;
  final SliverListView _sliverListView;

  /// 加载配置
  final LoadOptionsBuilder loadOptionsBuilder;

  /// {@template flutter.widgets.scroll_view.keyboardDismissBehavior}
  /// [ScrollViewKeyboardDismissBehavior] the defines how this [ScrollView] will
  /// dismiss the keyboard automatically.
  /// {@endtemplate}
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// 上拉加载更多配置
  final LoadNextBuilder loadNextBuilder;

  /// 占位图
  final PlaceholderBuilder placeholderBuilder;

  bool get _hasElements => _sliverListView.estimatedChildCount > 0;

  @override
  Widget build(BuildContext context) {
    return SupportCustomScrollView.builder(
      builder: loadOptionsBuilder,
      controller: controller,
      scrollDirection: scrollDirection,
      reverse: reverse,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      padding: padding,
      hasElements: _hasElements,
      keyboardDismissBehavior: keyboardDismissBehavior,
      loadNextBuilder: loadNextBuilder,
      placeholderBuilder: placeholderBuilder,
      slivers: <Widget>[
        _sliverListView,
      ],
    );
  }
}
