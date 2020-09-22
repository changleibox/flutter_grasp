/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_grasp/src/widget/animated_offset.dart';
import 'package:flutter_grasp/src/widget/geometry.dart';

/// Created by changlei on 2020/8/26.
///
/// 系统[Draggable]加动画
class AnimatedDraggable<T> extends StatefulWidget {
  /// 加了动画的[Draggable]
  const AnimatedDraggable({
    Key key,
    @required this.child,
    this.feedback,
    this.data,
    this.axis,
    this.childWhenDragging,
    this.feedbackOffset = Offset.zero,
    this.dragAnchor = DragAnchor.child,
    this.affinity,
    this.maxSimultaneousDrags,
    this.onDragStarted,
    this.onDraggableCanceled,
    this.onDragEnd,
    this.onDragCompleted,
    this.ignoringFeedbackSemantics = true,
    @required this.duration,
    this.curve = Curves.linear,
    this.alignment = Alignment.center,
  })  : assert(child != null),
        assert(ignoringFeedbackSemantics != null),
        assert(maxSimultaneousDrags == null || maxSimultaneousDrags >= 0),
        assert(curve != null),
        super(key: key);

  /// The data that will be dropped by this draggable.
  final T data;

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

  /// The widget below this widget in the tree.
  ///
  /// This widget displays [child] when zero drags are under way. If
  /// [childWhenDragging] is non-null, this widget instead displays
  /// [childWhenDragging] when one or more drags are underway. Otherwise, this
  /// widget always displays [child].
  ///
  /// The [feedback] widget is shown under the pointer when a drag is under way.
  ///
  /// To limit the number of simultaneous drags on multitouch devices, see
  /// [maxSimultaneousDrags].
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The widget to display instead of [child] when one or more drags are under way.
  ///
  /// If this is null, then this widget will always display [child] (and so the
  /// drag source representation will not change while a drag is under
  /// way).
  ///
  /// The [feedback] widget is shown under the pointer when a drag is under way.
  ///
  /// To limit the number of simultaneous drags on multitouch devices, see
  /// [maxSimultaneousDrags].
  final Widget childWhenDragging;

  /// The widget to show under the pointer when a drag is under way.
  ///
  /// See [child] and [childWhenDragging] for information about what is shown
  /// at the location of the [Draggable] itself when a drag is under way.
  final Widget feedback;

  /// The feedbackOffset can be used to set the hit test target point for the
  /// purposes of finding a drag target. It is especially useful if the feedback
  /// is transformed compared to the child.
  final Offset feedbackOffset;

  /// Where this widget should be anchored during a drag.
  final DragAnchor dragAnchor;

  /// Whether the semantics of the [feedback] widget is ignored when building
  /// the semantics tree.
  ///
  /// This value should be set to false when the [feedback] widget is intended
  /// to be the same object as the [child].  Placing a [GlobalKey] on this
  /// widget will ensure semantic focus is kept on the element as it moves in
  /// and out of the feedback position.
  ///
  /// Defaults to true.
  final bool ignoringFeedbackSemantics;

  /// Controls how this widget competes with other gestures to initiate a drag.
  ///
  /// If affinity is null, this widget initiates a drag as soon as it recognizes
  /// a tap down gesture, regardless of any directionality. If affinity is
  /// horizontal (or vertical), then this widget will compete with other
  /// horizontal (or vertical, respectively) gestures.
  ///
  /// For example, if this widget is placed in a vertically scrolling region and
  /// has horizontal affinity, pointer motion in the vertical direction will
  /// result in a scroll and pointer motion in the horizontal direction will
  /// result in a drag. Conversely, if the widget has a null or vertical
  /// affinity, pointer motion in any direction will result in a drag rather
  /// than in a scroll because the draggable widget, being the more specific
  /// widget, will out-compete the [Scrollable] for vertical gestures.
  ///
  /// For the directions this widget can be dragged in after the drag event
  /// starts, see [Draggable.axis].
  final Axis affinity;

  /// How many simultaneous drags to support.
  ///
  /// When null, no limit is applied. Set this to 1 if you want to only allow
  /// the drag source to have one item dragged at a time. Set this to 0 if you
  /// want to prevent the draggable from actually being dragged.
  ///
  /// If you set this property to 1, consider supplying an "empty" widget for
  /// [childWhenDragging] to create the illusion of actually moving [child].
  final int maxSimultaneousDrags;

  /// Called when the draggable starts being dragged.
  final VoidCallback onDragStarted;

  /// Called when the draggable is dropped without being accepted by a [DragTarget].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up being canceled, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final DraggableCanceledCallback onDraggableCanceled;

  /// Called when the draggable is dropped and accepted by a [DragTarget].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up completing, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final VoidCallback onDragCompleted;

  /// Called when the draggable is dropped.
  ///
  /// The velocity and offset at which the pointer was moving when it was
  /// dropped is available in the [DraggableDetails]. Also included in the
  /// `details` is whether the draggable's [DragTarget] accepted it.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true).
  final DragEndCallback onDragEnd;

  /// The length of time this animation should last.
  final Duration duration;

  /// The curve to use in the forward direction.
  final Curve curve;

  /// The alignment of the child within the parent when the parent is not yet
  /// the same size as the child.
  final AlignmentGeometry alignment;

  /// Whether haptic feedback should be triggered on drag start.
  bool get _hapticFeedbackOnStart => true;

  bool get _isLongPressDrag => false;

  @override
  _AnimatedDraggableState<T> createState() => _AnimatedDraggableState<T>();
}

class _AnimatedDraggableState<T> extends State<AnimatedDraggable<T>> with TickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  _DragAvatar _dragAvatar;
  SizeTween _feedbackTween;
  Size _originSize;
  Size _lastSize;
  Offset _dragStartPoint;
  Alignment _dragStartAlignment;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedDraggable<T> oldWidget) {
    if (widget.data != oldWidget.data) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        final Size currentSize = localToGlobal(context).size;
        if (_lastSize == null || currentSize == _lastSize) {
          return;
        }
        _feedbackTween = SizeTween(
          begin: _lastSize,
          end: currentSize,
        );
        _lastSize = currentSize;
        _controller.forward(from: _controller.lowerBound);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Rect _globalToLocalRect() {
    final Rect position = globalToLocal(context);
    return -position.topLeft & position.size;
  }

  void _onDragStarted() {
    _originSize = _lastSize = localToGlobal(context)?.size;
    if (_dragStartPoint != null && _originSize != null) {
      final Alignment originAlignment = Alignment(
        _dragStartPoint.dx / _originSize.width,
        _dragStartPoint.dy / _originSize.height,
      );
      _dragStartAlignment = originAlignment * 2 - Alignment.bottomRight;
    }

    widget.onDragStarted?.call();
  }

  void _onDragEnd(DraggableDetails details) {
    final Size originSize = _originSize ?? Size.zero;
    final Size lastSize = _lastSize ?? Size.zero;
    final TickerFuture tickerFuture = _controller.forward(
      from: _controller.lowerBound,
    );
    tickerFuture.whenCompleteOrCancel(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _dragAvatar = null;
        _dragStartPoint = null;
        _dragStartAlignment = null;
        _originSize = _lastSize = null;
      });
    });
    final Offset offset = _resolveSizeChangedOffset(originSize, lastSize);
    final Rect beginRect = (details.offset + offset) & lastSize;
    final Rect endRect = _globalToLocalRect();
    final Animation<Rect> animation = _curvedAnimation.drive(RectTween(
      begin: beginRect,
      end: endRect,
    ));
    _dragAvatar = _DragAvatar(
      context: context,
      animation: animation,
      child: widget.child,
    );

    widget.onDragEnd?.call(details);
  }

  void _onDraggableCanceled(Velocity velocity, Offset offset) {
    widget.onDraggableCanceled?.call(velocity, offset);
  }

  void _onDragCompleted() {
    widget.onDragCompleted?.call();
  }

  Offset _resolveSizeChangedOffset(Size originSize, Size currentSize) {
    final Offset sizeOffset = originSize - currentSize as Offset;
    return _dragStartAlignment?.alongOffset(sizeOffset) ?? Offset.zero;
  }

  Widget _buildChild(BuildContext context) {
    return AnimatedOpacity(
      opacity: _dragAvatar == null ? 1.0 : 0.0,
      duration: Duration.zero,
      curve: _curvedAnimation.curve,
      child: widget.child,
    );
  }

  Widget _buildFeedback(BuildContext context) {
    final Size originSize = _originSize ?? Size.zero;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.feedback ?? widget.child,
      builder: (BuildContext context, Widget child) {
        final Size currentSize = _feedbackTween?.evaluate(_curvedAnimation) ?? originSize;
        return Transform.translate(
          offset: _resolveSizeChangedOffset(originSize, currentSize),
          child: SizedBox.fromSize(
            size: currentSize,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildDraggingChild(BuildContext context) {
    return AnimatedOpacity(
      opacity: 0.0,
      duration: Duration.zero,
      curve: _curvedAnimation.curve,
      child: widget.childWhenDragging ?? widget.child,
    );
  }

  Widget _buildDraggable() {
    return Draggable<T>(
      child: Builder(
        builder: _buildChild,
      ),
      feedback: Builder(
        builder: _buildFeedback,
      ),
      childWhenDragging: Builder(
        builder: _buildDraggingChild,
      ),
      data: widget.data,
      maxSimultaneousDrags: widget.maxSimultaneousDrags,
      onDragStarted: _onDragStarted,
      onDragEnd: _onDragEnd,
      onDraggableCanceled: _onDraggableCanceled,
      onDragCompleted: _onDragCompleted,
      dragAnchor: widget.dragAnchor,
      feedbackOffset: widget.feedbackOffset,
      axis: widget.axis,
      ignoringFeedbackSemantics: widget.ignoringFeedbackSemantics,
    );
  }

  Widget _buildLongPressDraggable() {
    return LongPressDraggable<T>(
      child: Builder(
        builder: _buildChild,
      ),
      feedback: Builder(
        builder: _buildFeedback,
      ),
      childWhenDragging: Builder(
        builder: _buildDraggingChild,
      ),
      data: widget.data,
      maxSimultaneousDrags: widget.maxSimultaneousDrags,
      hapticFeedbackOnStart: widget._hapticFeedbackOnStart,
      onDragStarted: _onDragStarted,
      onDragEnd: _onDragEnd,
      onDraggableCanceled: _onDraggableCanceled,
      onDragCompleted: _onDragCompleted,
      dragAnchor: widget.dragAnchor,
      feedbackOffset: widget.feedbackOffset,
      axis: widget.axis,
      ignoringFeedbackSemantics: widget.ignoringFeedbackSemantics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _dragStartPoint = globalToLocal(context, point: details.globalPosition)?.topLeft;
      },
      child: AnimatedOffset(
        vsync: this,
        alignment: widget.alignment,
        duration: _controller.duration,
        curve: _curvedAnimation.curve,
        child: widget._isLongPressDrag ? _buildLongPressDraggable() : _buildDraggable(),
      ),
    );
  }
}

/// Makes its child draggable starting from long press.
class AnimatedLongPressDraggable<T> extends AnimatedDraggable<T> {
  /// Creates a widget that can be dragged starting from long press.
  ///
  /// The [child] and [feedback] arguments must not be null. If
  /// [maxSimultaneousDrags] is non-null, it must be non-negative.
  const AnimatedLongPressDraggable({
    Key key,
    @required Widget child,
    Widget feedback,
    T data,
    Axis axis,
    Widget childWhenDragging,
    Offset feedbackOffset = Offset.zero,
    DragAnchor dragAnchor = DragAnchor.child,
    int maxSimultaneousDrags,
    VoidCallback onDragStarted,
    DraggableCanceledCallback onDraggableCanceled,
    DragEndCallback onDragEnd,
    VoidCallback onDragCompleted,
    this.hapticFeedbackOnStart = true,
    bool ignoringFeedbackSemantics = true,
    @required Duration duration,
    Curve curve = Curves.linear,
    AlignmentGeometry alignment = Alignment.center,
  }) : super(
          key: key,
          child: child,
          feedback: feedback,
          data: data,
          axis: axis,
          childWhenDragging: childWhenDragging,
          feedbackOffset: feedbackOffset,
          dragAnchor: dragAnchor,
          maxSimultaneousDrags: maxSimultaneousDrags,
          onDragStarted: onDragStarted,
          onDraggableCanceled: onDraggableCanceled,
          onDragEnd: onDragEnd,
          onDragCompleted: onDragCompleted,
          ignoringFeedbackSemantics: ignoringFeedbackSemantics,
          duration: duration,
          curve: curve,
          alignment: alignment,
        );

  /// Whether haptic feedback should be triggered on drag start.
  final bool hapticFeedbackOnStart;

  @override
  bool get _hapticFeedbackOnStart => hapticFeedbackOnStart;

  @override
  bool get _isLongPressDrag => true;
}

class _DragAvatar {
  _DragAvatar({
    @required BuildContext context,
    @required this.animation,
    @required this.child,
  })  : assert(context != null),
        assert(animation != null),
        assert(child != null) {
    _entry = OverlayEntry(builder: _build);
    Overlay.of(context, rootOverlay: true).insert(_entry);
    animation.addStatusListener(_onAnimationStatusChanged);
  }

  final Animation<Rect> animation;
  final Widget child;

  OverlayEntry _entry;

  Widget _build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget child) {
        return Positioned.fromRect(
          rect: animation.value,
          child: child,
        );
      },
    );
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    animation.removeStatusListener(_onAnimationStatusChanged);
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        _entry?.remove();
        _entry = null;
        break;
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
    }
  }
}
