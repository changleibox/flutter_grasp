/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// 刷新回调
typedef SupportRefreshCallback = Future<void> Function();

/// 创建占位图
typedef PlaceholderBuilder = Widget Function(BuildContext context, bool isLoading, Axis scrollDirection);

/// 加载配置，可以设置刷新controller实现手动刷新，下拉刷新回调和加载更多回调和是否有下一页标签
class LoadOptions {
  const LoadOptions({
    this.controller,
    this.onRefresh,
    this.onLoadNext,
    this.hasNext = false,
  }) : assert(onLoadNext == null || hasNext != null);

  final RefreshScrollController controller;
  final SupportRefreshCallback onRefresh;
  final SupportRefreshCallback onLoadNext;
  final bool hasNext;

  LoadOptions copyWith({
    SupportRefreshCallback onRefresh,
    SupportRefreshCallback onLoadNext,
    bool hasNext,
    bool hasElements,
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
  LoadOptions get loadOptions;
}

/// 默认加载配置
class DefaultLoadOptionsBuilder implements LoadOptionsBuilder {
  const DefaultLoadOptionsBuilder({
    LoadOptions loadOptions = const LoadOptions(),
  })  : assert(loadOptions != null),
        _loadOptions = loadOptions;

  final LoadOptions _loadOptions;

  @override
  LoadOptions get loadOptions => _loadOptions;

  LoadOptionsBuilder copyWith({LoadOptions loadOptions}) {
    return DefaultLoadOptionsBuilder(loadOptions: loadOptions ?? _loadOptions);
  }
}

/// 手动刷新控制器，效果为[RefreshIndicator]的效果
class RefreshScrollController {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> onRefresh() {
    final RefreshIndicatorState currentState = _refreshKey.currentState;
    if (currentState == null) {
      return Future<void>.value();
    }
    return currentState.show();
  }

  @protected
  void attach(_SupportCustomScrollViewState state) {}

  bool get hasClients => _refreshKey.currentState != null;

  void dispose() {}
}

/// 另一种方式的手动刷新控制器，效果为在没有数据和正在加载时，显示'正在加载……'
class ManualRefreshScrollController extends RefreshScrollController {
  AsyncCallback _onManualRefresh;

  @override
  Future<void> onRefresh() {
    if (_onManualRefresh == null) {
      return Future<void>.value();
    }
    return _onManualRefresh();
  }

  @override
  void attach(_SupportCustomScrollViewState state) {
    _onManualRefresh = state._onRefresh;
    super.attach(state);
  }

  @override
  bool get hasClients => _onManualRefresh != null;
}

/// 加载更多控件，显示在最底部
class LoadNextWidget extends StatelessWidget {
  const LoadNextWidget({
    Key key,
    this.scrollDirection = Axis.vertical,
    this.hasNext = false,
    this.isLoading = false,
  }) : super(key: key);

  final Axis scrollDirection;
  final bool hasNext;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isVertical = scrollDirection == Axis.vertical;
    String text = isLoading && hasNext
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

/// Created by changlei on 2020-02-13.
///
/// 封装了下拉刷新和上拉加载更多功能的ScrollView
class SupportCustomScrollView extends StatefulWidget {
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
    this.placeholderBuilder = buildPlaceholder,
  })  : assert(hasElements != null),
        assert(placeholderBuilder != null),
        loadOptions = LoadOptions(
          onRefresh: onRefresh,
          onLoadNext: onLoadNext,
          hasNext: hasNext,
        ),
        super(key: key);

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
    this.placeholderBuilder = buildPlaceholder,
  })  : assert(hasElements != null),
        assert(builder != null),
        assert(placeholderBuilder != null),
        loadOptions = builder.loadOptions ?? const LoadOptions(),
        super(key: key);

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
    this.placeholderBuilder = buildPlaceholder,
  })  : assert(hasElements != null),
        assert(loadOptions != null),
        assert(placeholderBuilder != null),
        super(key: key);

  final List<Widget> slivers;
  final ScrollController controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final Key center;
  final double anchor;
  final double cacheExtent;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final EdgeInsetsGeometry padding;
  final LoadOptions loadOptions;
  final bool hasElements;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final PlaceholderBuilder placeholderBuilder;

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
  bool _isLoading = false;

  SupportRefreshCallback get _refresh => widget.loadOptions.onRefresh;

  SupportRefreshCallback get _loadNext => widget.loadOptions.onLoadNext;

  bool get _hasSlivers => widget.slivers != null && widget.slivers.isNotEmpty;

  bool get _showSlivers => _hasSlivers && widget.hasElements;

  bool get _showRefresh => _refresh != null && widget.scrollDirection == Axis.vertical;

  bool get _showLoadNext => _loadNext != null && _showSlivers;

  bool get _hasNext => widget.loadOptions.hasNext;

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
    _isLoading = true;
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _loadComplete() {
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      _isLoading = false;
      if (!mounted) {
        return;
      }
      setState(() {});
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
    widget.loadOptions.controller?.attach(this);
    super.initState();
  }

  @override
  void didUpdateWidget(SupportCustomScrollView oldWidget) {
    if (widget.loadOptions.controller != oldWidget.loadOptions.controller) {
      widget.loadOptions.controller?.attach(this);
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

    final List<Widget> slivers = <Widget>[];
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
        child: widget.placeholderBuilder(context, _isLoading, widget.scrollDirection),
      );
      slivers.add(buildSliver(sliver, true, true));
    }
    if (_showLoadNext) {
      final Widget sliver = SliverToBoxAdapter(
        child: LoadNextWidget(
          hasNext: _hasNext,
          isLoading: _isLoading,
          scrollDirection: widget.scrollDirection,
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
    if (_showRefresh) {
      child = RefreshIndicator(
        key: widget.loadOptions.controller?._refreshKey,
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
