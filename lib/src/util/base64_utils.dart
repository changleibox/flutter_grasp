/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/widgets.dart';

/// Created by changlei on 2020/8/26.
///
/// base64工具类
class Base64Utils {
  Base64Utils._();

  /// 编码
  static String base64Encode(String data) {
    final content = convert.utf8.encode(data);
    final digest = convert.base64Encode(content);
    return digest;
  }

  /// 解码
  static String base64Decode(String data) {
    return convert.utf8.decode(base64DecodeToBytes(data));
  }

  /// 解码为[List<int>]
  static List<int> base64DecodeToBytes(String data) {
    return convert.base64Decode(data);
  }

  /// 编码图片
  static Future<String> image2Base64(String path) async {
    final file = File(path);
    final List<int> imageBytes = await file.readAsBytes();
    return convert.base64Encode(imageBytes);
  }

  /// 编码文件
  static Future<String> imageFile2Base64(File file) async {
    final List<int> imageBytes = await file.readAsBytes();
    return convert.base64Encode(imageBytes);
  }

  /// 解码为[Image]
  static Image base642Image(
    String base64Txt, {
    double width = 100,
    double height = 100,
    BoxFit fit = BoxFit.fitWidth,
  }) {
    final decodeTxt = convert.base64.decode(base64Txt);
    return Image.memory(
      decodeTxt,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
    );
  }
}
