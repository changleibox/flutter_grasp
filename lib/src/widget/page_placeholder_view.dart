/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by box on 2019-11-11.
///
/// 页面占位符widget
class DefaultPagePlaceholderView extends StatelessWidget {
  /// 构造函数
  const DefaultPagePlaceholderView({
    Key key,
    this.message = '暂无数据',
    this.isLoading = false,
  })  : assert(isLoading != null),
        super(key: key);

  /// message
  final String message;

  /// 是否正在加载
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return PagePlaceholderView(
      isLoading: isLoading,
      message: message,
      icon: Image.asset(
        'assets/images/empty.png',
        width: 185.5,
        height: 185.0,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// 页面占位符
class PagePlaceholderView extends StatefulWidget {
  /// 构造函数
  const PagePlaceholderView({
    Key key,
    @required this.icon,
    this.message = '暂无数据',
    this.isLoading = false,
  })  : assert(icon != null),
        assert(isLoading != null),
        super(key: key);

  /// icon
  final Widget icon;

  /// message
  final String message;

  /// 是否正在加载
  final bool isLoading;

  @override
  _PagePlaceholderViewState createState() => _PagePlaceholderViewState();
}

class _PagePlaceholderViewState extends State<PagePlaceholderView> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String message = widget.message;
    if (widget.isLoading) {
      message = '正在加载…';
    }
    Widget loadingWidget = widget.icon;
    //    if (isLoading) {
    //      loadingWidget = SizedBox(
    //        width: 163,
    //        height: 145,
    //        child: CupertinoActivityIndicator(
    //          radius: 14,
    //        ),
    //      );
    //    }
    loadingWidget = ColorFiltered(
      colorFilter: ColorFilter.mode(
        CupertinoDynamicColor.resolve(
          CupertinoDynamicColor.withBrightness(
            color: const Color(0x00000000),
            darkColor: CupertinoColors.black.withOpacity(0.2),
          ),
          context,
        ),
        BlendMode.dstOut,
      ),
      child: loadingWidget,
    );
    return FadeTransition(
      opacity: _curvedAnimation,
      child: SizedBox.expand(
        child: Center(
          child: WidgetGroup.spacing(
            spacing: 15,
            alignment: MainAxisAlignment.center,
            direction: Axis.vertical,
            children: <Widget>[
              loadingWidget,
              if (message != null)
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
