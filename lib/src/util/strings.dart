/*
 * Copyright © 2019 CHANGLEI. All rights reserved.
 */

class Strings {
  static String format(String format, List<Object> args) {
    if (format == null || args == null || args.isEmpty) {
      return format;
    }
    final RegExp exp = RegExp(r'(\%s)');
    final Iterable<Match> matches = exp.allMatches(format);
    assert(matches.length == args.length, 'format中的通配符\'%s\'的数量应该与args.length相等。');
    String tmpFormat = format;
    for (int i = 0; i < args.length; i++) {
      final Object arg = args[i] ?? '';
      tmpFormat = tmpFormat.replaceFirst('%s', arg.toString());
    }
    return tmpFormat;
  }

  static bool isEmpty(String str) {
    return str == null || str.isEmpty;
  }

  static bool isNotEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  static bool equals(String a, String b) {
    if (a == b) {
      return true;
    }
    int length;
    if (a != null && b != null && (length = a.length) == b.length) {
      if (a is String && b is String) {
        return a == b;
      } else {
        for (int i = 0; i < length; i++) {
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
