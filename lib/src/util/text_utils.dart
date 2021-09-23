/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

/// Created by changlei on 2020/8/26.
///
/// 处理字符串相关
class TextUtils {
  const TextUtils._();

  /// 格式化占位符
  @Deprecated('请使用`spintf`代替')
  static String? format(String? format, List<Object?>? args) {
    if (format == null || args == null || args.isEmpty) {
      return format;
    }
    final exp = RegExp(r'(\%s)');
    final Iterable<Match> matches = exp.allMatches(format);
    assert(matches.length == args.length, 'format中的通配符\'%s\'的数量应该与args.length相等。');
    var tmpFormat = format;
    for (var i = 0; i < args.length; i++) {
      final arg = args[i] ?? '';
      tmpFormat = tmpFormat.replaceFirst('%s', arg.toString());
    }
    return tmpFormat;
  }

  /// 判断字符串是否为null或者empty
  static bool isEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  /// 判断字符串是否不为空
  static bool isNotEmpty(String? str) {
    return str != null && str.isNotEmpty;
  }

  /// 判断两个字符串是否相等
  static bool equals(String? a, String? b) {
    if (a == b) {
      return true;
    }
    int length;
    if (a != null && b != null && (length = a.length) == b.length) {
      if (a is String && b is String) {
        return a == b;
      } else {
        for (var i = 0; i < length; i++) {
          if (a[i] != b[i]) {
            return false;
          }
        }
        return true;
      }
    }
    return false;
  }
}
