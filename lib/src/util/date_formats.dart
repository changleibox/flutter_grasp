/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:intl/intl.dart';

/// Created by changlei on 2020/8/26.
///
/// 格式化[DateTime]
class DateFormats {
  const DateFormats._();

  /// 对齐
  @Deprecated('请使用DateUtils.days')
  static DateTime alignment(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute);
  }

  /// 格式化为'yyyy-MM-dd HH:mm'格式
  static String? formatYMDHM(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  /// 格式化为'yyyy-MM-dd'格式
  static String? formatYMD(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// 格式化为'yyyy-MM'格式
  static String? formatYM(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateFormat('yyyy-MM').format(dateTime);
  }

  /// 解析为[DateTime]
  static DateTime? parse(String? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateTime.tryParse(dateTime);
  }

  /// 获取一个月有多少天
  @Deprecated('请使用DateUtils.getDaysInMonth')
  static int getDaysInMonth(DateTime? dateTime) {
    if (dateTime == null) {
      return 1;
    }
    return getDaysInMonthByYearMonth(dateTime.year, dateTime.month);
  }

  /// 获取一个月有多少天，通过[y]，[m]
  @Deprecated('请使用DateUtils.getDaysInMonth')
  static int getDaysInMonthByYearMonth(int y, int m) {
    if (m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12) {
      return 31;
    } else if (m == 2) {
      if (((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)) {
        //闰年 2月29
        return 29;
      } else {
        //平年 2月28
        return 28;
      }
    } else {
      return 30;
    }
  }

  /// 格式化成中文，比如：12分12秒
  static String formatToConcise(int? milliseconds) {
    if (milliseconds == null) {
      return '0秒';
    }
    final days = milliseconds ~/ Duration.millisecondsPerDay;
    final hrs = milliseconds ~/ Duration.millisecondsPerHour;
    final min = milliseconds ~/ Duration.millisecondsPerMinute;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    if (days > 0 || hrs > 0) {
      return DateFormat('HH时mm分ss秒').format(dateTime);
    } else if (min > 0) {
      return DateFormat('mm分ss秒').format(dateTime);
    } else {
      return DateFormat('ss秒').format(dateTime);
    }
  }
}
