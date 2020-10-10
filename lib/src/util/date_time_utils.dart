import 'package:intl/intl.dart';

const int _nd = 1000 * 24 * 60 * 60; // 一天的毫秒数
const int _nh = 1000 * 60 * 60; // 一小时的毫秒数
const int _nm = 1000 * 60; // 一分钟的毫秒数

class DateTimeUtils {
  DateTimeUtils._();

  static DateTime alignment(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute);
  }

  static String formatYMDHM(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static String formatYMD(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String formatYM(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateFormat('yyyy-MM').format(dateTime);
  }

  static DateTime parse(String dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateTime.parse(dateTime);
  }

  static int getDaysInMonth(DateTime dateTime) {
    if (dateTime == null) {
      return 1;
    }
    return getDaysInMonthByYearMonth(dateTime.year, dateTime.month);
  }

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

  static String formatToCN(int milliseconds) {
    if (milliseconds == null) {
      return '0秒';
    }
    final int days = milliseconds ~/ _nd;
    final int hrs = milliseconds ~/ _nh;
    final int min = milliseconds ~/ _nm;
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    if (days > 0 || hrs > 0) {
      return DateFormat('HH时mm分ss秒').format(dateTime);
    } else if (min > 0) {
      return DateFormat('mm分ss秒').format(dateTime);
    } else {
      return DateFormat('ss秒').format(dateTime);
    }
  }
}
