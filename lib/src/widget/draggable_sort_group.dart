/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grasp/src/widget/animated_drag_target.dart';
import 'package:flutter_grasp/src/widget/draggable_sort.dart';

/// 拖动排序回调
typedef DraggableSortGroupCallback = void Function(int fromGroupIndex, int toGroupIndex, int fromIndex, int toIndex);

/// 自定拖动排序规则
typedef DraggableSortGroupHandler = bool Function(int fromGroupIndex, int toGroupIndex, int fromIndex, int toIndex);

/// 构建[feedback]
typedef DraggableSortGroupFeedbackBuilder = Widget Function(
  BuildContext context,
  int groupIndex,
  int index,
  Widget child,
);

/// Created by changlei on 2020/8/20.
///
/// 一组拖动排序
class DraggableSortGroup extends StatefulWidget {
  /// 一组拖动排序
  const DraggableSortGroup({
    Key key,
    @required this.builder,
    @required this.itemCounts,
    this.onDragSort,
    this.onSortHandler,
    this.feedbackBuilder,
    this.axis,
  })  : assert(builder != null),
        assert(itemCounts != null),
        super(key: key);

  /// child
  final WidgetBuilder builder;

  /// 触发排序
  final DraggableSortGroupCallback onDragSort;

  /// 自定义排序
  final DraggableSortGroupHandler onSortHandler;

  /// 每个item对应的数量
  final List<int> itemCounts;

  /// 构建拖动的feedback
  final DraggableSortGroupFeedbackBuilder feedbackBuilder;

  /// The [Axis] to restrict this draggable's movement, if specified.
  ///
  /// When axis is set to [Axis.horizontal], this widget can only be dragged
  /// horizontally. Behavior is similar for [Axis.vertical].
  ///
  /// Defaults to allowing drag on both [Axis.horizontal] and [Axis.vertical].
  ///
  /// When null, allows drag on both [Axis.horizontal] and [Axis.vertical].
  ///
  /// For the direction of gestures this widget competes with to start a drag
  /// event, see [Draggable.affinity].
  final Axis axis;

  @override
  DraggableSortGroupState createState() => DraggableSortGroupState();
}

/// 一组拖动排序
class DraggableSortGroupState extends State<DraggableSortGroup> {
  final GlobalKey<DraggableSortState> _sortKey = GlobalKey<DraggableSortState>();

  int _itemCount = 0;
  DragSortData _lastDragSortData;

  @override
  void initState() {
    if (widget.itemCounts.isNotEmpty) {
      _itemCount = widget.itemCounts.reduce((int value, int element) => value + element);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(DraggableSortGroup oldWidget) {
    if (!listEquals(widget.itemCounts, oldWidget.itemCounts)) {
      _itemCount = widget.itemCounts.reduce((int value, int element) => value + element);
    }
    super.didUpdateWidget(oldWidget);
  }

  bool _onWillAccept(DragSortData dragSortData, int toGroupIndex) {
    _lastDragSortData ??= dragSortData;
    final _GroupIndexes indexes = _collapseIndex(_lastDragSortData.index);
    final int fromGroupIndex = indexes.groupIndex;
    if (widget.itemCounts[toGroupIndex] > 0 || fromGroupIndex == toGroupIndex) {
      return false;
    }
    int toIndex = 0;
    if (fromGroupIndex > toGroupIndex) {
      toIndex = widget.itemCounts[toGroupIndex] - 1;
    } else if (fromGroupIndex < toGroupIndex) {
      toIndex = 0;
    }
    final bool isIntercept = widget.onSortHandler?.call(
      fromGroupIndex,
      toGroupIndex,
      indexes.index,
      toIndex,
    );
    if (isIntercept == true) {
      return false;
    }
    _sortKey.currentState.sort(
      _lastDragSortData.index,
      _expandIndex(toGroupIndex, toIndex),
    );
    return true;
  }

  /// 创建排序组item
  Widget createGroupItem(int groupIndex, Widget child) {
    return AnimatedDragTarget<DragSortData>(
      duration: const Duration(milliseconds: 300),
      onWillAccept: (DragSortData data) => _onWillAccept(data, groupIndex),
      builder: (BuildContext context, List<DragSortData> candidateData, List<dynamic> rejectedData) {
        return child;
      },
    );
  }

  /// 创建排序item
  Widget createItem(int groupIndex, int index, Widget child) {
    return _sortKey.currentState.createItem(_expandIndex(groupIndex, index), child);
  }

  int _expandIndex(int groupIndex, int index) {
    assert(groupIndex >= 0);
    if (groupIndex == 0) {
      return index;
    }
    return widget.itemCounts.sublist(0, groupIndex).reduce((int value, int element) => value + element) + index;
  }

  _GroupIndexes _collapseIndex(int index) {
    int groupIndex = 0;
    int indexSum = 0;
    if (index < 0) {
      return _GroupIndexes(groupIndex, 0);
    }
    if (index >= _itemCount) {
      return _GroupIndexes(widget.itemCounts.length - 1, index - _itemCount);
    }
    final List<int> itemCounts = widget.itemCounts;
    for (int i = 0; i < itemCounts.length; i++) {
      final int itemCount = itemCounts[i];
      if (index >= indexSum - 1 && index < indexSum + itemCount) {
        groupIndex = i;
        break;
      }
      indexSum += itemCount;
    }
    return _GroupIndexes(groupIndex, index - indexSum);
  }

  void _onDragSort(int fromIndex, int toIndex) {
    final _GroupIndexes fromIndexes = _collapseIndex(fromIndex);
    final _GroupIndexes toIndexes = _collapseIndex(toIndex);
    _lastDragSortData = DragSortData(
      _sortKey.currentState,
      toIndex,
    );
    widget.onDragSort?.call(
      fromIndexes.groupIndex,
      toIndexes.groupIndex,
      fromIndexes.index,
      toIndexes.index,
    );
  }

  void _onDragEnd(DragSortData dragSortData) {
    _lastDragSortData = null;
    setState(() {});
  }

  int _onSortHandler(int fromIndex, int toIndex) {
    final _GroupIndexes fromIndexes = _collapseIndex(fromIndex);
    final _GroupIndexes toIndexes = _collapseIndex(toIndex);
    final int fromGroupIndex = fromIndexes.groupIndex;
    final int toGroupIndex = toIndexes.groupIndex;
    final bool isIntercept = widget.onSortHandler?.call(
      fromGroupIndex,
      toGroupIndex,
      fromIndexes.index,
      toIndexes.index,
    );
    if (isIntercept == true) {
      return fromIndex;
    }
    if (fromGroupIndex < toGroupIndex) {
      return toIndex - 1;
    }
    return toIndex;
  }

  @override
  Widget build(BuildContext context) {
    DraggableSortFeedbackBuilder feedbackBuilder;
    if (widget.feedbackBuilder != null) {
      feedbackBuilder = (BuildContext context, int index, Widget child) {
        final _GroupIndexes indexes = _collapseIndex(index);
        return widget.feedbackBuilder(context, indexes.groupIndex, indexes.index, child);
      };
    }
    return DraggableSort(
      key: _sortKey,
      itemCount: _itemCount,
      onDragSort: _onDragSort,
      onDragEnd: _onDragEnd,
      onSortHandler: _onSortHandler,
      builder: widget.builder,
      feedbackBuilder: feedbackBuilder,
      axis: widget.axis,
    );
  }
}

@immutable
class _GroupIndexes {
  const _GroupIndexes(this.groupIndex, this.index);

  final int groupIndex;
  final int index;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GroupIndexes &&
          runtimeType == other.runtimeType &&
          groupIndex == other.groupIndex &&
          index == other.index;

  @override
  int get hashCode => groupIndex.hashCode ^ index.hashCode;

  @override
  String toString() {
    return '_GroupIndexes{groupIndex: $groupIndex, index: $index}';
  }
}
