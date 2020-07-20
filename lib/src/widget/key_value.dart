/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/material.dart';

const TextStyle _style = TextStyle(
  color: Colors.black12,
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

const TextStyle _valueStyle = TextStyle(
  color: Colors.black12,
);

/// Created by changlei on 2020/5/26.
///
/// 显示一个'key：value'格式，例如：姓名：小明
class KeyValue extends StatelessWidget {
  const KeyValue({
    Key key,
    @required this.name,
    @required this.value,
    this.defaultValue,
    this.style = _style,
    this.valueStyle = _valueStyle,
  })  : assert(name != null),
        super(key: key);

  final String name;
  final String value;
  final String defaultValue;
  final TextStyle style;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: name,
        children: <InlineSpan>[
          TextSpan(
            text: value ?? defaultValue ?? '',
            style: valueStyle,
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}
