/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:flutter_grasp/src/widget/load_next_widget.dart';
import 'package:flutter_grasp/src/widget/support_refresh_indicator.dart';

/// 刷新回调
typedef SupportRefreshCallback = Future<void> Function();

/// 创建占位图
typedef PlaceholderBuilder = Widget Function(BuildContext context, bool isLoading, Axis scrollDirection);

/// 创建加载更多控件
typedef LoadNextBuilder = Widget Function(BuildContext context, bool hasNext, bool isLoading, Axis scrollDirection);

/// 加载配置，可以设置刷新controller实现手动刷新，下拉刷新回调和加载更多回调和是否有下一页标签
class LoadOptions {
  /// 构造函数
  const LoadOptions({
    this.controller,
    this.onRefresh,
    this.onLoadNext,
    this.hasNext = false,
  }) : assert(onLoadNext == null || hasNext != null);

  /// 刷新控制器
  final RefreshScrollController controller;

  /// 刷新回调
  final SupportRefreshCallback onRefresh;

  /// 读取下一页回调
  final SupportRefreshCallback onLoadNext;

  /// 是否有下一页
  final bool hasNext;

  /// 复制
  LoadOptions copyWith({
    SupportRefreshCallback onRefresh,
    SupportRefreshCallback onLoadNext,
    bool hasNext,
  }) {
    return LoadOptions(
      controller: controller,
      onRefresh: onRefresh ?? this.onRefresh,
      onLoadNext: onLoadNext ?? this.onLoadNext,
      hasNext: hasNext ?? this.hasNext ?? false,
    );
  }
}

/// 加载配置的包裹类，可以继承该类，实现统一的加载配置
abstract class LoadOptionsBuilder {
  /// load配置
  LoadOptions get loadOptions;
}

/// 默认加载配置
class DefaultLoadOptionsBuilder implements LoadOptionsBuilder {
  /// 构造函数
  const DefaultLoadOptionsBuilder({
    LoadOptions loadOptions = const LoadOptions(),
  })  : assert(loadOptions != null),
        _loadOptions = loadOptions;

  final LoadOptions _loadOptions;

  @override
  LoadOptions get loadOptions => _loadOptions;

  /// 复制
  LoadOptionsBuilder copyWith({LoadOptions loadOptions}) {
    return DefaultLoadOptionsBuilder(loadOptions: loadOptions ?? _loadOptions);
  }
}

/// Created by changlei on 2020-02-13.
///
/// 封装了下拉刷新和上拉加载更多功能的ScrollView
class SupportCustomScrollView extends StatefulWidget {
  /// 构造函数
  SupportCustomScrollView({
    Key key,
    this.controller,
    this.slivers,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.padding,
    SupportRefreshCallback onRefresh,
    SupportRefreshCallback onLoadNext,
    bool hasNext = false,
    this.hasElements = true,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.loadNextBuilder = buildLoadNext,
    this.placeholderBuilder = buildPlaceholder,
  })  : assert(hasElements != null),
        assert(loadNextBuilder != null),
        assert(placeholderBuilder != null),
        loadOptions = LoadOptions(
          onRefresh: onRefresh,
          onLoadNext: onLoadNext,
          hasNext: hasNext,
        ),
        super(key: key);

  /// builder构造器
  SupportCustomScrollView.builder({
    Key key,
    @required LoadOptionsBuilder builder,
    this.controller,
    this.slivers,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.padding,
    this.hasElements = true,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.loadNextBuilder = buildLoadNext,
    this.placeholderBuilder = buildPlaceholder,
  })  : assert(hasElements != null),
        assert(builder != null),
        assert(loadNextBuilder != null),
        assert(placeholderBuilder != null),
        loadOptions = builder.loadOptions ?? const LoadOptions(),
        super(key: key);

  /// 可以用一个[LoadOptions]构造
  const SupportCustomScrollView.options({
    Key key,
    @required this.loadOptions,
    this.controller,
    this.slivers,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.padding,
    this.hasElements = true,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.loadNextBuilder = buildLoadNext,
    this.placeholderBuilder = buildPlaceholder,
  })  : assert(hasElements != null),
        assert(loadOptions != null),
        assert(loadNextBuilder != null),
        assert(placeholderBuilder != null),
        super(key: key);

  /// children
  final List<Widget> slivers;

  /// 滚动控制器
  final ScrollController controller;

  /// 滚动方向
  final Axis scrollDirection;

  /// 是否翻转list
  final bool reverse;

  /// 是否使用[PrimaryScrollController]
  final bool primary;

  /// 插值器，可以自定义滚动效果
  final ScrollPhysics physics;

  /// 是否压缩包裹
  final bool shrinkWrap;

  /// The first child in the [GrowthDirection.forward] growth direction.
  ///
  /// Children after [center] will be placed in the [AxisDirection] determined
  /// by [scrollDirection] and [reverse] relative to the [center]. Children
  /// before [center] will be placed in the opposite of the axis direction
  /// relative to the [center]. This makes the [center] the inflection point of
  /// the growth direction.
  ///
  /// The [center] must be the key of one of the slivers built by [buildSlivers].
  ///
  /// Of the built-in subclasses of [ScrollView], only [CustomScrollView]
  /// supports [center]; for that class, the given key must be the key of one of
  /// the slivers in the [CustomScrollView.slivers] list.
  ///
  /// See also:
  ///
  ///  * [anchor], which controls where the [center] as aligned in the viewport.
  final Key center;

  /// {@template flutter.widgets.scroll_view.anchor}
  /// The relative position of the zero scroll offset.
  ///
  /// For example, if [anchor] is 0.5 and the [AxisDirection] determined by
  /// [scrollDirection] and [reverse] is [AxisDirection.down] or
  /// [AxisDirection.up], then the zero scroll offset is vertically centered
  /// within the viewport. If the [anchor] is 1.0, and the axis direction is
  /// [AxisDirection.right], then the zero scroll offset is on the left edge of
  /// the viewport.
  /// {@endtemplate}
  final double anchor;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double cacheExtent;

  /// The number of children that will contribute semantic information.
  ///
  /// Some subtypes of [ScrollView] can infer this value automatically. For
  /// example [ListView] will use the number of widgets in the child list,
  /// while the [ListView.separated] constructor will use half that amount.
  ///
  /// For [CustomScrollView] and other types which do not receive a builder
  /// or list of widgets, the child count must be explicitly provided. If the
  /// number is unknown or unbounded this should be left unset or set to null.
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.scrollChildCount], the corresponding semantics property.
  final int semanticChildCount;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// [LoadOptions]
  final LoadOptions loadOptions;

  /// 是否有元素
  final bool hasElements;

  /// {@template flutter.widgets.scroll_view.keyboardDismissBehavior}
  /// [ScrollViewKeyboardDismissBehavior] the defines how this [ScrollView] will
  /// dismiss the keyboard automatically.
  /// {@endtemplate}
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// 上拉加载更多配置
  final LoadNextBuilder loadNextBuilder;

  /// 占位图
  final PlaceholderBuilder placeholderBuilder;

  /// 构建默认的上拉加载控件
  static Widget buildLoadNext(BuildContext context, bool hasNext, bool isLoading, Axis scrollDirection) {
    return LoadNextWidget(
      hasNext: hasNext,
      isLoading: isLoading,
      scrollDirection: scrollDirection,
    );
  }

  /// 构建默认的占位图
  static Widget buildPlaceholder(BuildContext context, bool isLoading, Axis scrollDirection) {
    final bool isVertical = scrollDirection == Axis.vertical;
    return SizedBox.fromSize(
      size: isVertical ? const Size.fromHeight(300) : const Size.fromWidth(300),
      child: DefaultPagePlaceholderView(
        isLoading: isLoading,
      ),
    );
  }

  @override
  _SupportCustomScrollViewState createState() => _SupportCustomScrollViewState();
}

class _SupportCustomScrollViewState extends State<SupportCustomScrollView> {
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  SupportRefreshCallback get _refresh => widget.loadOptions.onRefresh;

  SupportRefreshCallback get _loadNext => widget.loadOptions.onLoadNext;

  bool get _hasSlivers => widget.slivers != null && widget.slivers.isNotEmpty;

  bool get _showSlivers => _hasSlivers && widget.hasElements;

  bool get _showRefresh => _refresh != null && widget.scrollDirection == Axis.vertical;

  bool get _showLoadNext => _loadNext != null && _showSlivers;

  bool get _hasNext => widget.loadOptions.hasNext;

  bool get _isLoading => _isLoadingNotifier.value;

  Future<void> _onRefresh() async {
    if (!_isLoading && _showRefresh) {
      _loadStart();
      await _refresh().whenComplete(_loadComplete);
    }
  }

  Future<void> _onLoadNext() async {
    if (!_isLoading && _showLoadNext && _hasNext) {
      _loadStart();
      await _loadNext().whenComplete(_loadComplete);
    }
  }

  void _loadStart() {
    _isLoadingNotifier.value = true;
  }

  void _loadComplete() {
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      _isLoadingNotifier.value = false;
    });
  }

  bool _onNotification(ScrollNotification notification) {
    if (widget.keyboardDismissBehavior == ScrollViewKeyboardDismissBehavior.onDrag &&
        notification is ScrollUpdateNotification) {
      final FocusScopeNode focusScope = FocusScope.of(context);
      if (notification.dragDetails != null && focusScope.hasFocus) {
        focusScope.unfocus();
      }
    }
    if (notification.depth != 0 || notification is! ScrollEndNotification) {
      return false;
    }
    final ScrollMetrics metrics = notification.metrics;
    final double pixels = metrics.pixels;
    final double maxScrollExtent = metrics.maxScrollExtent;
    if (pixels >= maxScrollExtent) {
      _onLoadNext();
    }
    return false;
  }

  @override
  void initState() {
    widget.loadOptions.controller?.attach(_onRefresh);
    super.initState();
  }

  @override
  void didUpdateWidget(SupportCustomScrollView oldWidget) {
    if (widget.loadOptions.controller != oldWidget.loadOptions.controller) {
      widget.loadOptions.controller?.attach(_onRefresh);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool isVertical = widget.scrollDirection == Axis.vertical;
    EdgeInsetsGeometry effectivePadding = widget.padding;
    EdgeInsetsGeometry mediaQueryPadding;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    if (widget.padding == null && mediaQuery != null) {
      // Automatically pad sliver with padding from MediaQuery.
      final EdgeInsets mediaQueryHorizontalPadding = mediaQuery.padding.copyWith(top: 0.0, bottom: 0.0);
      final EdgeInsets mediaQueryVerticalPadding = mediaQuery.padding.copyWith(left: 0.0, right: 0.0);
      // Consume the main axis padding with SliverPadding.
      effectivePadding = isVertical ? mediaQueryVerticalPadding : mediaQueryHorizontalPadding;
      mediaQueryPadding = isVertical ? mediaQueryHorizontalPadding : mediaQueryVerticalPadding;
    }

    final EdgeInsets padding = effectivePadding?.resolve(Directionality.of(context));

    Widget buildSliver(Widget sliver, bool isFirst, bool isLast) {
      if (padding == null) {
        return sliver;
      }
      EdgeInsets copyPadding = padding.copyWith();
      if (!isFirst) {
        copyPadding = padding.copyWith(
          left: isVertical ? padding.left : 0,
          top: isVertical ? 0 : padding.top,
        );
      }
      if (!isLast) {
        copyPadding = copyPadding.copyWith(
          right: isVertical ? padding.right : 0,
          bottom: isVertical ? 0 : padding.bottom,
        );
      }

      return SliverPadding(
        padding: copyPadding,
        sliver: sliver,
      );
    }

    final RefreshScrollController controller = widget.loadOptions.controller;

    final List<Widget> slivers = <Widget>[];
    if (_showRefresh && controller?.style == RefreshControllerStyle.cupertino) {
      final Widget child = SupportSliverRefreshIndicator(
        key: controller?.refreshKey,
        onRefresh: _onRefresh,
      );
      slivers.add(child);
    }
    if (_hasSlivers) {
      final int length = widget.slivers.length;
      slivers.addAll(List<Widget>.generate(length, (int index) {
        final bool isFirst = index == 0;
        final bool isLast = index == length - 1 && !_showLoadNext && _showSlivers;
        return buildSliver(widget.slivers[index], isFirst, isLast);
      }));
    }
    if (!_showSlivers) {
      final Widget sliver = SliverToBoxAdapter(
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoadingNotifier,
          builder: (BuildContext context, bool value, Widget child) {
            return widget.placeholderBuilder(context, value, widget.scrollDirection);
          },
        ),
      );
      slivers.add(buildSliver(sliver, true, true));
    }
    if (_showLoadNext) {
      final Widget sliver = SliverToBoxAdapter(
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoadingNotifier,
          builder: (BuildContext context, bool value, Widget child) {
            return widget.loadNextBuilder(context, _hasNext, value, widget.scrollDirection);
          },
        ),
      );
      slivers.add(buildSliver(sliver, false, true));
    }
    Widget child = CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      center: widget.center,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      slivers: slivers,
    );
    if (mediaQuery != null && mediaQueryPadding != null) {
      child = MediaQuery(
        data: mediaQuery.copyWith(
          padding: mediaQueryPadding.resolve(Directionality.of(context)),
        ),
        child: child,
      );
    }
    if (_showRefresh && controller?.style != RefreshControllerStyle.cupertino) {
      child = RefreshIndicator(
        key: controller?.refreshKey,
        onRefresh: _onRefresh,
        child: child,
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: child,
    );
  }
}
