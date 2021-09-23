/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

const List<String> _FORMATS = <String>['jpg', 'gif', 'png', 'webp'];
const List<int> _COLORS = <int>[2, 4, 8, 16, 32, 64, 128, 256];

/// Created by changlei on 2020/8/26.
///
/// 处理上传到七牛的文件
class QiniuUtils {
  const QiniuUtils._();

  /// 判断一个数字是否有效
  static bool isInvalidValue(double? value) {
    return value == null || value.isInfinite || value.isNaN || value <= 0;
  }

  /// 判断一个[size]是否有效
  static bool isInvalidSize(Size? size) {
    return size == null || size.isInfinite || size.isEmpty;
  }

  /// 详情请查看七牛官网 https://developer.qiniu.com/dora/api/1279/basic-processing-images-imageview2
  static String formatQiniuUrl(
    BuildContext context,
    String url, {
    double? width,
    double? height,
    int mode = 0,
    int? quality,
    String? format,
    bool? interlace,
    int? colors,
  }) {
    if (TextUtils.isEmpty(url) || Uri.parse(url).host.contains('qiniu')) {
      return url;
    }
    assert(mode >= 0 && mode <= 5);
    assert(quality == null || (quality >= 1 && quality <= 100));
    assert(format == null || _FORMATS.contains(format));
    assert(colors == null || _COLORS.contains(colors));
    final params = <dynamic>[];
    params.addAll(<dynamic>['$url?imageView2', mode]);
    params.addAll(<dynamic>['ignore-error', 1]);
    if (quality != null) {
      params.addAll(<dynamic>['q', quality]);
    }
    if (interlace != null) {
      params.addAll(<dynamic>['interlace', if (interlace) 1 else 0]);
    }
    if (colors != null) {
      params.addAll(<dynamic>['colors', colors]);
    }
    if (TextUtils.isNotEmpty(format)) {
      params.addAll(<dynamic>['format', format]);
    }
    final size = MediaQuery.of(context).size;
    if (isInvalidValue(width)) {
      width = size.width;
    }
    if (isInvalidValue(height)) {
      height = size.height;
    }
    if (mode == 1 || mode == 2 || mode == 3) {
      params.addAll(<dynamic>['w', width!.ceil()]);
      params.addAll(<dynamic>['h', height!.ceil()]);
    } else {
      params.addAll(<dynamic>['w', max(width!, height!).ceil()]);
      params.addAll(<dynamic>['h', min(width, height).ceil()]);
    }
    return params.join('/');
  }
}
