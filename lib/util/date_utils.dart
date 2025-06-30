import 'package:date_format/date_format.dart';

/// 日期工具

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 10, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year + 10, kToday.month, kToday.day);

/// 获取当月总天数
int getDaysNum(int year, int month) {
  if (month == 1 ||
      month == 3 ||
      month == 5 ||
      month == 7 ||
      month == 8 ||
      month == 10 ||
      month == 12) {
    return 31;
  } else if (month == 2) {
    if (((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)) {
      // 闰年 2月29
      return 29;
    } else {
      // 平年 2月28
      return 28;
    }
  } else {
    return 30;
  }
}

/// 比较两个日期是否相同
bool sameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 新增：时间字符串转毫秒工具方法（依赖date_utils）
int? parseDateTimeToMillis(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    final dateTime = DateTime.parse(dateStr);
    return dateTime.millisecondsSinceEpoch;
  } catch (e) {
    print('时间解析失败: $dateStr');
    return null;
  }
}

/// 格式化日期时间
String getFormattedDateTimeFromMillis(int? millis) {
  if (millis == null) {
    return '未知';
  }
  return formatDate(
    DateTime.fromMillisecondsSinceEpoch(millis),
    [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss],
  );
}

/// 格式化日期
String getFormattedDateFromMillis(int? millis) {
  if (millis == null) {
    return '未知';
  }
  return formatDate(
    DateTime.fromMillisecondsSinceEpoch(millis),
    [yyyy, '-', mm, '-', dd],
  );
}

/// 格式化时间
String getFormattedTimeFromMillis(int? millis) {
  if (millis == null) {
    return '未知';
  }
  return formatDate(
    DateTime.fromMillisecondsSinceEpoch(millis),
    [HH, ':', nn],
  );
}

/// 格式化日期时间
String getFormattedDateTime(DateTime dateTime) {
  return formatDate(
    dateTime,
    [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss],
  );
}

/// 格式化日期
String getFormattedDate(DateTime dateTime) {
  return formatDate(
    dateTime,
    [yyyy, '-', mm, '-', dd],
  );
}

/// 格式化时间
String getFormattedTime(DateTime dateTime) {
  return formatDate(
    dateTime,
    [HH, ':', nn],
  );
}

/// 获取日志文件名称 [yyyy-MM-dd HH:mm:ss_SSS]
String getNowLogString() {
  return formatDate(
    DateTime.now(),
    [yyyy, '-', mm, '-', dd, ' ', HH, '_', nn, '_', ss, '_', SSS],
  );
}

/// 获取现在时间 [yyyy-MM-dd HH:mm:ss.SSS]
String getNowMilliSecString() {
  return formatDate(
    DateTime.now(),
    [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS],
  );
}

/// 获取毫秒数
int currentMillis() => DateTime.now().millisecondsSinceEpoch;

/// 获取今天时间 [yyyy-MM-dd HH:mm:ss]
String getTodayString() {
  return formatDate(
    DateTime.now(),
    [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss],
  );
}

/// 获取今天月份
int getMonth() {
  return DateTime.now().month;
}

/// 获取本周的周一日期
DateTime getMonDayDateOfCurrentWeek() {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
}

/// 获取今天日期 [yyyy/MM/dd]
String getTodayDateString() {
  return formatDate(DateTime.now(), [yyyy, '/', m, '/', dd]);
}

/// 计算日期
SpecialDay calDate(DateTime dateTime) {
  return SpecialDay.none;
}

/// 判断日期是否是今天
bool isToday(int? millis) {
  if (millis == null) {
    return false;
  }
  return _isSameDate(
    DateTime.fromMillisecondsSinceEpoch(millis),
    DateTime.now(),
  );
}

/// 判断日期是否是昨天
bool isYesterday(int? millis) {
  if (millis == null) {
    return false;
  }
  return _isSameDate(
    DateTime.fromMillisecondsSinceEpoch(millis),
    DateTime.now().subtract(Duration(days: 1)),
  );
}

bool _isSameDate(DateTime time1, DateTime time2) =>
    time1.year == time2.year &&
    time1.month == time2.month &&
    time1.day == time2.day;

enum SpecialDay {
  /// 今天
  now,

  /// 明天
  tomorrow,

  /// 昨天
  yesterday,

  /// 前天
  theDayBeforeYesterday,

  /// 不是特殊日期
  none
}
