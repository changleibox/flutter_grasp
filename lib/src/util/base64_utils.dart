import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

class Base64Utils {
  static String base64Encode(String data) {
    final List<int> content = convert.utf8.encode(data);
    final String digest = convert.base64Encode(content);
    return digest;
  }

  static String base64Decode(String data) {
    return convert.utf8.decode(base64DecodeToBytes(data));
  }

  static List<int> base64DecodeToBytes(String data) {
    return convert.base64Decode(data);
  }

  static Future<String> image2Base64(String path) async {
    final File file = File(path);
    final List<int> imageBytes = await file.readAsBytes();
    return convert.base64Encode(imageBytes);
  }

  static Future<String> imageFile2Base64(File file) async {
    final List<int> imageBytes = await file.readAsBytes();
    return convert.base64Encode(imageBytes);
  }

  static Image base642Image(
    String base64Txt, {
    double width = 100,
    double height = 100,
    BoxFit fit = BoxFit.fitWidth,
  }) {
    final Uint8List decodeTxt = convert.base64.decode(base64Txt);
    return Image.memory(
      decodeTxt,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
    );
  }
}
