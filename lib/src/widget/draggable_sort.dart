/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_grasp/src/widget/animated_drag_target.dart';
import 'package:flutter_grasp/src/widget/animated_draggable.dart';
import 'package:flutter_grasp/src/widget/animated_shifted_box_boundary.dart';

typedef DraggableSortCallback = void Function(int fromIndex, int toIndex);

typedef DraggableSortHandler = int Function(int fromIndex, int toIndex);

typedef DraggableSortFeedbackBuilder = Widget Function(BuildContext context, int index, Widget child);

/// Created by changlei on 2020/8/12.
///
/// 拖动排序
class DraggableSort extends StatefulWidget {
  /// 拖动排序
  const DraggableSort({
    Key key,
    @required this.builder,
    @required this.itemCount,
    this.onSortHandler,
    this.onDragSort,
    this.onDragStarted,
    this.onDraggableCanceled,
    this.onDragCompleted,
    this.onDragEnd,
    this.feedbackBuilder,
  })  : assert(builder != null),
        assert(itemCount != null && itemCount >= 0),
        super(key: key);

  /// child
  final WidgetBuilder builder;

  /// 自定义排序逻辑
  final DraggableSortHandler onSortHandler;

  /// 触发排序
  final DraggableSortCallback onDragSort;

  /// item的数量
  final int itemCount;

  /// Called when the draggable starts being dragged.
  final ValueChanged<DragSortData> onDragStarted;

  /// Called when the draggable is dropped without being accepted by a [DragTarget].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up being canceled, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final ValueChanged<DragSortData> onDraggableCanceled;

  /// Called when the draggable is dropped and accepted by a [DragTarget].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up completing, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final ValueChanged<DragSortData> onDragCompleted;

  /// Called when the draggable is dropped.
  ///
  /// The velocity and offset at which the pointer was moving when it was
  /// dropped is available in the [DraggableDetails]. Also included in the
  /// `details` is whether the draggable's [DragTarget] accepted it.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true).
  final ValueChanged<DragSortData> onDragEnd;

  /// 构建拖动的feedback
  final DraggableSortFeedbackBuilder feedbackBuilder;

  @override
  DraggableSortState createState() => DraggableSortState();
}

/// 拖动排序state
class DraggableSortState extends State<DraggableSort> {
  final List<GlobalKey<State<StatefulWidget>>> _itemKeys = <GlobalKey>[];

  int _willAcceptIndex;

  @override
  void initState() {
    _itemKeys.addAll(List<GlobalKey>.generate(widget.itemCount, _createKey));
    super.initState();
  }

  @override
  void didUpdateWidget(DraggableSort oldWidget) {
    if (widget.itemCount > oldWidget.itemCount) {
      final int delta = widget.itemCount - oldWidget.itemCount;
      _itemKeys.addAll(List<GlobalKey>.generate(delta, (int n) => _createKey(n)));
    } else if (widget.itemCount < oldWidget.itemCount) {
      _itemKeys.removeRange(widget.itemCount, math.min(oldWidget.itemCount, _itemKeys.length));
    }
    super.didUpdateWidget(oldWidget);
  }

  GlobalKey _createKey(int index) => GlobalKey(debugLabel: index.toString());

  /// 添加一个item
  void add({int index}) {
    assert(index == null || (index >= 0 && index <= _itemKeys.length));
    if (index == null) {
      _itemKeys.add(_createKey(_itemKeys.length));
    } else {
      _itemKeys.insert(index, _createKey(index));
    }
  }

  /// 删除一个item
  void remove({int index}) {
    assert(index == null || (index >= 0 && index < _itemKeys.length));
    if (index == null) {
      _itemKeys.removeLast();
    } else {
      _itemKeys.removeAt(index);
    }
  }

  /// 主动排序，尽量不要使用这个方法，因为他没有经过严格的测试，目前在测试阶段，是提供给[DraggableSortGroup]使用的
  int sort(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) {
      return toIndex;
    }
    _willAcceptIndex = _onSort(fromIndex, toIndex);
    widget.onDragSort?.call(fromIndex, toIndex);
    return _willAcceptIndex;
  }

  int _onSort(int fromIndex, int toIndex) {
    toIndex = widget.onSortHandler?.call(fromIndex, toIndex) ?? toIndex;
    final int maxIndex = _itemKeys.length - 1;
    final int validFromIndex = fromIndex.clamp(0, maxIndex).toInt();
    final int validToIndex = toIndex.clamp(0, maxIndex).toInt();
    if (validFromIndex != validToIndex) {
      final GlobalKey<State<StatefulWidget>> fromKey = _itemKeys[validFromIndex];
      _itemKeys.removeAt(validFromIndex);
      _itemKeys.insert(validToIndex, fromKey);
    }
    return validToIndex;
  }

  bool _onWillAccept(DragSortData data, int index) {
    if (data._state != this) {
      // 不是当前控件
      return false;
    }
    final int fromIndex = _willAcceptIndex ?? data.index;
    final bool accept = fromIndex != index;
    if (accept) {
      final int toIndex = _onSort(fromIndex, index);
      if (fromIndex == toIndex) {
        return false;
      }
      _willAcceptIndex = toIndex;
      widget.onDragSort?.call(fromIndex, index);
    }
    return accept;
  }

  void _onDragStarted(DragSortData dragSortData) {
    widget.onDragStarted?.call(dragSortData);
  }

  void _onDragEnd(DragSortData dragSortData) {
    _willAcceptIndex = null;
    widget.onDragEnd?.call(dragSortData);
  }

  void _onDraggableCanceled(DragSortData dragSortData) {
    widget.onDraggableCanceled?.call(dragSortData);
  }

  void _onDragCompleted(DragSortData dragSortData) {
    widget.onDragCompleted?.call(dragSortData);
  }

  /// 创建排序item
  Widget createItem(int index, Widget child) {
    assert(index >= 0 && _itemKeys.length > index);
    assert(child != null);
    final DragSortData dragSortData = DragSortData(this, index);
    Widget feedback;
    if (widget.feedbackBuilder != null) {
      feedback = Builder(
        builder: (BuildContext context) {
          return widget.feedbackBuilder(context, index, child);
        },
      );
    }
    return KeyedSubtree(
      key: _itemKeys[index],
      child: AnimatedLongPressDraggable<DragSortData>(
        data: dragSortData,
        onDragStarted: () => _onDragStarted(dragSortData),
        onDragEnd: (DraggableDetails details) => _onDragEnd(dragSortData),
        onDraggableCanceled: (Velocity velocity, Offset offset) => _onDraggableCanceled(dragSortData),
        onDragCompleted: () => _onDragCompleted(dragSortData),
        duration: const Duration(milliseconds: 300),
        curve: Curves.linearToEaseOut,
        feedback: feedback,
        child: AnimatedDragTarget<DragSortData>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linearToEaseOut,
          onWillAccept: (DragSortData data) => _onWillAccept(data, index),
          builder: (BuildContext context, List<DragSortData> candidateData, List<dynamic> rejectedData) => child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedShiftedBoxBoundary(
      child: widget.builder(context),
    );
  }
}

/// 拖动排序的数据
@immutable
class DragSortData {
  /// 拖动的数据
  const DragSortData(this._state, this.index);

  final DraggableSortState _state;

  /// 对应的index
  final int index;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DragSortData && runtimeType == other.runtimeType && _state == other._state && index == other.index;

  @override
  int get hashCode => _state.hashCode ^ index.hashCode;

  @override
  String toString() {
    return 'DragData{index: $index}';
  }
}
