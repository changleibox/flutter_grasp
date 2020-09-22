/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image;

/// Created by box on 2020/4/4.
///
/// 创建一个图片滤镜源
class ImageFilterSrc {
  /// 创建一个图片滤镜源
  ImageFilterSrc({
    @required this.image,
    @required this.matrix,
  })  : assert(image != null),
        assert(matrix != null && matrix.length == 20);

  /// 图片数据
  final Uint8List image;

  /// 滤镜的矩阵数据
  final List<double> matrix;
}

Future<Uint8List> _colorMatrixFilter(ImageFilterSrc params) {
  return compute(_colorMatrixFilterAsSync, params);
}

Uint8List _colorMatrixFilterAsSync(ImageFilterSrc params) {
  final image.Image src = image.decodeImage(params.image);
  final List<double> matrix = params.matrix;

  final image.Image tmp = image.Image.from(src);

  for (int y = 0; y < src.height; ++y) {
    for (int x = 0; x < src.width; ++x) {
      final int c = tmp.getPixel(x, y);
      final int red = image.getRed(c);
      final int green = image.getGreen(c);
      final int blue = image.getBlue(c);
      final int alpha = image.getAlpha(c);

      final List<num> oldColors = <num>[red, green, blue, alpha, 1.0];
      final Float64List newColors = Float64List(4);

      for (int col = 0; col < 5; ++col) {
        for (int row = 0; row < 4; ++row) {
          newColors[row] += oldColors[col] * matrix[col + row * 5];
        }
      }

      num r = newColors[0];
      num g = newColors[1];
      num b = newColors[2];
      num a = newColors[3];

      r = (r > 255.0) ? 255.0 : ((r < 0.0) ? 0.0 : r);
      g = (g > 255.0) ? 255.0 : ((g < 0.0) ? 0.0 : g);
      b = (b > 255.0) ? 255.0 : ((b < 0.0) ? 0.0 : b);
      a = (a > 255.0) ? 255.0 : ((a < 0.0) ? 0.0 : a);

      src.setPixel(x, y, image.getColor(r.toInt(), g.toInt(), b.toInt(), a.toInt()));
    }
  }

  return Uint8List.fromList(image.encodePng(src));
}

/// 滤镜工具类
class ImageFilters {
  /// 添加滤镜
  static Future<Uint8List> colorMatrixFilter(ImageFilterSrc src) {
    return _colorMatrixFilter(src);
  }
}
