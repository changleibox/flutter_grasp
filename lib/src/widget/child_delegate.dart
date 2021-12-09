/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 创建child
typedef SemanticIndexCallback = int? Function(Widget widget, int localIndex);

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

/// Created by changlei on 2020/5/20.
///
/// 用来创建一个widget集合，详情请看[SliverChildDelegate]
abstract class ChildDelegate {
  /// 构造函数
  const ChildDelegate();

  /// 构建child
  Widget? build(BuildContext context, int index);

  /// child的数量
  int? get estimatedChildCount => null;

  @override
  String toString() {
    final description = <String>[];
    debugFillDescription(description);
    return '${describeIdentity(this)}(${description.join(", ")})';
  }

  /// Add additional information to the given description for use by [toString].
  @protected
  @mustCallSuper
  void debugFillDescription(List<String> description) {
    try {
      final children = estimatedChildCount;
      if (children != null) {
        description.add('estimated child count: $children');
      }
    } catch (e) {
      description.add('estimated child count: EXCEPTION (${e.runtimeType})');
    }
  }
}

class _SaltedValueKey extends ValueKey<Key> {
  const _SaltedValueKey(Key key) : super(key);
}

/// 用来创建一个widget集合，详情请看[SliverChildBuilderDelegate]
class ChildBuilderDelegate extends ChildDelegate {
  /// 构造函数
  const ChildBuilderDelegate(
    this.builder, {
    this.childCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
    this.semanticIndexOffset = 0,
  });

  /// 构建item
  final IndexedWidgetBuilder builder;

  /// child数量
  final int? childCount;

  /// 是否保持活力
  final bool addAutomaticKeepAlives;

  /// 是否添加一个[RepaintBoundary]
  final bool addRepaintBoundaries;

  /// 是否增加semantic index偏移
  final bool addSemanticIndexes;

  /// semantic index偏移
  final int semanticIndexOffset;

  /// semantic index偏移回调
  final SemanticIndexCallback semanticIndexCallback;

  @override
  Widget? build(BuildContext context, int index) {
    if (index < 0 || (childCount != null && index >= childCount!)) {
      return null;
    }
    Widget child;
    try {
      child = builder(context, index);
    } catch (exception, stackTrace) {
      child = _createErrorWidget(exception, stackTrace);
    }
    final Key? key = child.key != null ? _SaltedValueKey(child.key!) : null;
    if (addRepaintBoundaries) {
      child = RepaintBoundary(child: child);
    }
    if (addSemanticIndexes) {
      final semanticIndex = semanticIndexCallback(child, index);
      if (semanticIndex != null) {
        child = IndexedSemantics(index: semanticIndex + semanticIndexOffset, child: child);
      }
    }
    if (addAutomaticKeepAlives) {
      child = AutomaticKeepAlive(child: child);
    }
    return addRepaintBoundaries || addSemanticIndexes || addAutomaticKeepAlives
        ? KeyedSubtree(key: key, child: child)
        : child;
  }

  @override
  int? get estimatedChildCount => childCount;
}

/// 用来创建一个widget集合，详情请看[SliverChildListDelegate]
class ChildListDelegate extends ChildDelegate {
  /// 构造函数
  const ChildListDelegate(
    this.children, {
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
    this.semanticIndexOffset = 0,
  });

  /// fixed
  const ChildListDelegate.fixed(
    this.children, {
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
    this.semanticIndexOffset = 0,
  });

  /// 是否保持活力
  final bool addAutomaticKeepAlives;

  /// 是否添加一个[RepaintBoundary]
  final bool addRepaintBoundaries;

  /// 是否增加semantic index偏移
  final bool addSemanticIndexes;

  /// semantic index偏移
  final int semanticIndexOffset;

  /// semantic index偏移回调
  final SemanticIndexCallback semanticIndexCallback;

  /// The widgets to display.
  final List<Widget> children;

  @override
  Widget? build(BuildContext context, int index) {
    if (index < 0 || index >= children.length) {
      return null;
    }
    Widget? child = children[index];
    final Key? key = child.key != null ? _SaltedValueKey(child.key!) : null;
    if (addRepaintBoundaries) {
      child = RepaintBoundary(child: child);
    }
    if (addSemanticIndexes) {
      final semanticIndex = semanticIndexCallback(child, index);
      if (semanticIndex != null) {
        child = IndexedSemantics(index: semanticIndex + semanticIndexOffset, child: child);
      }
    }
    if (addAutomaticKeepAlives) {
      child = AutomaticKeepAlive(child: child);
    }
    return addRepaintBoundaries || addSemanticIndexes || addAutomaticKeepAlives
        ? KeyedSubtree(key: key, child: child)
        : child;
  }

  @override
  int get estimatedChildCount => children.length;
}

// Return a Widget for the given Exception
Widget _createErrorWidget(Object exception, StackTrace stackTrace) {
  final details = FlutterErrorDetails(
    exception: exception,
    stack: stackTrace,
    library: 'widgets library',
    context: ErrorDescription('building'),
  );
  FlutterError.reportError(details);
  return ErrorWidget.builder(details);
}
