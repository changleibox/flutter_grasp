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

  final ScrollController controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;
  final double itemExtent;
  final double cacheExtent;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final SliverListView _sliverListView;
  final LoadOptionsBuilder loadOptionsBuilder;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
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
      placeholderBuilder: placeholderBuilder,
      slivers: <Widget>[
        _sliverListView,
      ],
    );
  }
}
