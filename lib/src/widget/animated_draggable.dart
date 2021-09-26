/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_grasp/src/widget/animated_offset.dart';
import 'package:flutter_grasp/src/widget/geometry.dart';

/// Created by changlei on 2020/8/26.
///
/// 系统[Draggable]加动画
class AnimatedDraggable<T extends Object> extends StatefulWidget {
  /// 加了动画的[Draggable]
  const AnimatedDraggable({
    Key? key,
    required this.child,
    this.feedback,
    this.data,
    this.axis,
    this.childWhenDragging,
    this.feedbackOffset = Offset.zero,
    this.dragAnchorStrategy = childDragAnchorStrategy,
    this.affinity,
    this.maxSimultaneousDrags,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDraggableCanceled,
    this.onDragEnd,
    this.onDragCompleted,
    this.ignoringFeedbackSemantics = true,
    required this.duration,
    this.curve = Curves.linear,
    this.alignment = Alignment.center,
    this.rootOverlay = false,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
  })  : assert(maxSimultaneousDrags == null || maxSimultaneousDrags >= 0),
        super(key: key);

  /// The data that will be dropped by this draggable.
  final T? data;

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
  final Axis? axis;

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
  final Widget? childWhenDragging;

  /// The widget to show under the pointer when a drag is under way.
  ///
  /// See [child] and [childWhenDragging] for information about what is shown
  /// at the location of the [Draggable] itself when a drag is under way.
  final Widget? feedback;

  /// The feedbackOffset can be used to set the hit test target point for the
  /// purposes of finding a drag target. It is especially useful if the feedback
  /// is transformed compared to the child.
  final Offset feedbackOffset;

  /// A strategy that is used by this draggable to get the anchor offset when it
  /// is dragged.
  ///
  /// The anchor offset refers to the distance between the users' fingers and
  /// the [feedback] widget when this draggable is dragged.
  ///
  /// This property's value is a function that implements [DragAnchorStrategy].
  /// There are two built-in functions that can be used:
  ///
  ///  * [childDragAnchorStrategy], which displays the feedback anchored at the
  ///    position of the original child.
  ///
  ///  * [pointerDragAnchorStrategy], which displays the feedback anchored at the
  ///    position of the touch that started the drag.
  final DragAnchorStrategy? dragAnchorStrategy;

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
  final Axis? affinity;

  /// How many simultaneous drags to support.
  ///
  /// When null, no limit is applied. Set this to 1 if you want to only allow
  /// the drag source to have one item dragged at a time. Set this to 0 if you
  /// want to prevent the draggable from actually being dragged.
  ///
  /// If you set this property to 1, consider supplying an "empty" widget for
  /// [childWhenDragging] to create the illusion of actually moving [child].
  final int? maxSimultaneousDrags;

  /// Called when the draggable starts being dragged.
  final VoidCallback? onDragStarted;

  /// Called when the draggable is dragged.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true), and if this widget has actually moved.
  final DragUpdateCallback? onDragUpdate;

  /// Called when the draggable is dropped without being accepted by a [DragTarget].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up being canceled, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final DraggableCanceledCallback? onDraggableCanceled;

  /// Called when the draggable is dropped and accepted by a [DragTarget].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up completing, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final VoidCallback? onDragCompleted;

  /// Called when the draggable is dropped.
  ///
  /// The velocity and offset at which the pointer was moving when it was
  /// dropped is available in the [DraggableDetails]. Also included in the
  /// `details` is whether the draggable's [DragTarget] accepted it.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true).
  final DragEndCallback? onDragEnd;

  /// The length of time this animation should last.
  final Duration duration;

  /// The curve to use in the forward direction.
  final Curve curve;

  /// The alignment of the child within the parent when the parent is not yet
  /// the same size as the child.
  final AlignmentGeometry alignment;

  /// Whether the feedback widget will be put on the root [Overlay].
  ///
  /// When false, the feedback widget will be put on the closest [Overlay]. When
  /// true, the [feedback] widget will be put on the farthest (aka root)
  /// [Overlay].
  ///
  /// Defaults to false.
  final bool rootOverlay;

  /// How to behave during hit test.
  ///
  /// Defaults to [HitTestBehavior.deferToChild].
  final HitTestBehavior hitTestBehavior;

  /// Whether haptic feedback should be triggered on drag start.
  bool get _hapticFeedbackOnStart => true;

  bool get _isLongPressDrag => false;

  /// The duration that a user has to press down before a long press is registered.
  ///
  /// Defaults to [kLongPressTimeout].
  Duration get _delay => Duration.zero;

  /// 获取动画
  static Animation<double>? of(BuildContext context) => _AnimationScope.of(context);

  @override
  _AnimatedDraggableState<T> createState() => _AnimatedDraggableState<T>();
}

class _AnimatedDraggableState<T extends Object> extends State<AnimatedDraggable<T>> with TickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  _DragAvatar? _dragAvatar;
  SizeTween? _feedbackTween;
  Size? _originSize;
  Offset? _dragStartPoint;
  Alignment? _dragStartAlignment;

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
      SchedulerBinding.instance!.addPostFrameCallback(_onPostFrame);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onPostFrame(Duration timeStamp) {
    if (_dragAvatar != null) {
      return;
    }
    final currentSize = localToGlobal(context).size;
    final lastSize = _lastSize ?? Size.zero;
    if (currentSize == lastSize) {
      return;
    }
    _feedbackTween = SizeTween(
      begin: lastSize,
      end: currentSize,
    );
    _controller.forward(
      from: _controller.lowerBound,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Size? get _lastSize => _feedbackTween?.evaluate(_curvedAnimation);

  Rect _globalToLocalRect() {
    final position = globalToLocal(context);
    return -position.topLeft & position.size;
  }

  void _onDragStarted() {
    _originSize = localToGlobal(context).size;
    if (_dragStartPoint != null && _originSize != null) {
      final originAlignment = Alignment(
        _dragStartPoint!.dx / _originSize!.width,
        _dragStartPoint!.dy / _originSize!.height,
      );
      _dragStartAlignment = originAlignment * 2 - Alignment.bottomRight;
    }

    _feedbackTween = SizeTween(
      begin: _originSize,
      end: _originSize,
    );
    _controller.forward(
      from: _controller.lowerBound,
    );

    widget.onDragStarted?.call();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    widget.onDragUpdate?.call(details);
  }

  void _onDragEnd(DraggableDetails details) {
    final originSize = _originSize ?? Size.zero;
    final lastSize = _lastSize ?? Size.zero;
    final tickerFuture = _controller.reverse(
      from: _controller.upperBound,
    );
    tickerFuture.whenCompleteOrCancel(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedbackTween = null;
        _originSize = null;
        _dragAvatar = null;
        _dragStartPoint = null;
        _dragStartAlignment = null;
      });
    });
    final beginRect = _globalToLocalRect();
    final offset = _resolveSizeChangedOffset(originSize, lastSize);
    final endRect = (details.offset + offset) & lastSize;
    final animation = _curvedAnimation.drive(RectTween(
      begin: beginRect,
      end: endRect,
    ) as Animatable<Rect>);
    _dragAvatar = _DragAvatar(
      overlay: Overlay.of(
        context,
        debugRequiredFor: widget,
        rootOverlay: widget.rootOverlay,
      )!,
      animation: animation,
      child: _feedback,
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
    final sizeOffset = originSize - currentSize as Offset;
    return _dragStartAlignment?.alongOffset(sizeOffset) ?? Offset.zero;
  }

  Widget _buildChild(BuildContext context) {
    return AnimatedOpacity(
      opacity: _dragAvatar == null ? 1.0 : 0.0,
      duration: Duration.zero,
      curve: widget.curve,
      child: widget.child,
    );
  }

  Widget get _feedback {
    return _AnimationScope(
      animation: _curvedAnimation,
      child: widget.feedback ?? widget.child,
    );
  }

  Widget _buildFeedback(BuildContext context) {
    final originSize = _originSize ?? Size.zero;
    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (BuildContext context, Widget? child) {
        final currentSize = _feedbackTween?.evaluate(_curvedAnimation) ?? originSize;
        return Transform.translate(
          offset: _resolveSizeChangedOffset(originSize, currentSize),
          child: SizedBox.fromSize(
            size: currentSize,
            child: child,
          ),
        );
      },
      child: _feedback,
    );
  }

  Widget _buildDraggingChild(BuildContext context) {
    return AnimatedOpacity(
      opacity: 0.0,
      duration: Duration.zero,
      curve: widget.curve,
      child: widget.childWhenDragging ?? widget.child,
    );
  }

  Widget _buildDraggable() {
    return Draggable<T>(
      feedback: Builder(
        builder: _buildFeedback,
      ),
      childWhenDragging: Builder(
        builder: _buildDraggingChild,
      ),
      data: widget.data,
      maxSimultaneousDrags: widget.maxSimultaneousDrags,
      onDragStarted: _onDragStarted,
      onDragUpdate: _onDragUpdate,
      onDragEnd: _onDragEnd,
      onDraggableCanceled: _onDraggableCanceled,
      onDragCompleted: _onDragCompleted,
      dragAnchorStrategy: widget.dragAnchorStrategy,
      feedbackOffset: widget.feedbackOffset,
      axis: widget.axis,
      ignoringFeedbackSemantics: widget.ignoringFeedbackSemantics,
      affinity: widget.affinity,
      hitTestBehavior: widget.hitTestBehavior,
      rootOverlay: widget.rootOverlay,
      child: Builder(
        builder: _buildChild,
      ),
    );
  }

  Widget _buildLongPressDraggable() {
    return LongPressDraggable<T>(
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
      onDragUpdate: _onDragUpdate,
      onDragEnd: _onDragEnd,
      onDraggableCanceled: _onDraggableCanceled,
      onDragCompleted: _onDragCompleted,
      dragAnchorStrategy: widget.dragAnchorStrategy,
      feedbackOffset: widget.feedbackOffset,
      axis: widget.axis,
      ignoringFeedbackSemantics: widget.ignoringFeedbackSemantics,
      delay: widget._delay,
      child: Builder(
        builder: _buildChild,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var child = widget._isLongPressDrag ? _buildLongPressDraggable() : _buildDraggable();
    if (widget.duration != Duration.zero) {
      child = AnimatedOffset(
        vsync: this,
        alignment: widget.alignment,
        duration: widget.duration,
        curve: widget.curve,
        child: child,
      );
    }
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _dragStartPoint = globalToLocal(context, point: details.globalPosition).topLeft;
      },
      child: child,
    );
  }
}

/// Makes its child draggable starting from long press.
class AnimatedLongPressDraggable<T extends Object> extends AnimatedDraggable<T> {
  /// Creates a widget that can be dragged starting from long press.
  ///
  /// The [child] and [feedback] arguments must not be null. If
  /// [maxSimultaneousDrags] is non-null, it must be non-negative.
  const AnimatedLongPressDraggable({
    Key? key,
    required Widget child,
    Widget? feedback,
    T? data,
    Axis? axis,
    Widget? childWhenDragging,
    Offset feedbackOffset = Offset.zero,
    DragAnchorStrategy? dragAnchorStrategy,
    int? maxSimultaneousDrags,
    VoidCallback? onDragStarted,
    DragUpdateCallback? onDragUpdate,
    DraggableCanceledCallback? onDraggableCanceled,
    DragEndCallback? onDragEnd,
    VoidCallback? onDragCompleted,
    this.hapticFeedbackOnStart = true,
    bool ignoringFeedbackSemantics = true,
    this.delay = kLongPressTimeout,
    required Duration duration,
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
          dragAnchorStrategy: dragAnchorStrategy,
          maxSimultaneousDrags: maxSimultaneousDrags,
          onDragStarted: onDragStarted,
          onDragUpdate: onDragUpdate,
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

  /// The duration that a user has to press down before a long press is registered.
  ///
  /// Defaults to [kLongPressTimeout].
  final Duration delay;

  @override
  bool get _hapticFeedbackOnStart => hapticFeedbackOnStart;

  @override
  bool get _isLongPressDrag => true;

  @override
  Duration get _delay => delay;
}

class _DragAvatar {
  _DragAvatar({
    required this.overlay,
    required this.animation,
    required this.child,
  }) {
    _entry = OverlayEntry(builder: _build);
    overlay.insert(_entry);
    animation.addStatusListener(_onAnimationStatusChanged);
  }

  final OverlayState overlay;
  final Animation<Rect> animation;
  final Widget child;

  late OverlayEntry _entry;

  Widget _build(BuildContext context) {
    final box = overlay.context.findRenderObject()! as RenderBox;
    final overlayTopLeft = box.localToGlobal(Offset.zero);
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Positioned.fromRect(
          rect: animation.value.shift(-overlayTopLeft),
          child: child!,
        );
      },
      child: child,
    );
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    animation.removeStatusListener(_onAnimationStatusChanged);
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        _entry.remove();
        break;
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
    }
  }
}

/// 下穿[Animation<double>]
class _AnimationScope extends InheritedWidget {
  /// 下穿[Animation<double>]
  const _AnimationScope({
    Key? key,
    required Widget child,
    required this.animation,
  }) : super(key: key, child: child);

  /// 下穿[Animation<double>]
  final Animation<double> animation;

  /// 获取
  static Animation<double>? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AnimationScope>()?.animation;
  }

  @override
  bool updateShouldNotify(covariant _AnimationScope oldWidget) {
    return animation != oldWidget.animation;
  }
}
