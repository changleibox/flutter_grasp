/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/widgets.dart';

/// Created by changlei on 2020/8/26.
///
/// 系统[DragTarget]加动画
class AnimatedDragTarget<T> extends StatelessWidget {
  /// 系统[DragTarget]加动画
  const AnimatedDragTarget({
    Key key,
    @required this.builder,
    this.onWillAccept,
    this.onAccept,
    this.onAcceptWithDetails,
    this.onLeave,
    this.onMove,
    @required this.duration,
    this.curve = Curves.linear,
  }) : super(key: key);

  /// Called to build the contents of this widget.
  ///
  /// The builder can build different widgets depending on what is being dragged
  /// into this drag target.
  final DragTargetBuilder<T> builder;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final DragTargetWillAccept<T> onWillAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  ///
  /// Equivalent to [onAcceptWithDetails], but only includes the data.
  final DragTargetAccept<T> onAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  ///
  /// Equivalent to [onAccept], but with information, including the data, in a
  /// [DragTargetDetails].
  final DragTargetAcceptWithDetails<T> onAcceptWithDetails;

  /// Called when a given piece of data being dragged over this target leaves
  /// the target.
  final DragTargetLeave onLeave;

  /// Called when a [Draggable] moves within this [DragTarget].
  ///
  /// Note that this includes entering and leaving the target.
  final DragTargetMove onMove;

  /// The length of time this animation should last.
  final Duration duration;

  /// The curve to use in the forward direction.
  final Curve curve;

  Widget _buildTargetChild(BuildContext context, List<T> candidateData, List<dynamic> rejectedData) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      padding: candidateData.isEmpty ? EdgeInsets.zero : const EdgeInsets.all(2),
      child: AnimatedOpacity(
        opacity: candidateData.isEmpty ? 1.0 : 0.4,
        duration: duration,
        curve: curve,
        child: builder?.call(context, candidateData, rejectedData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onAccept: onAccept,
      onAcceptWithDetails: onAcceptWithDetails,
      onWillAccept: onWillAccept,
      onLeave: onLeave,
      onMove: onMove,
      builder: _buildTargetChild,
    );
  }
}
