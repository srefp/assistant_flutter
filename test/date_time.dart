import 'package:timezone/timezone.dart' as tz;

/// 格式化带时区偏移的时间
String formatOffsetDateTime(tz.TZDateTime dateTime) {
  return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
      '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)} '
      '${dateTime.timeZoneName}(${dateTime.timeZoneOffset.inHours}:${_twoDigits(dateTime.timeZoneOffset.inMinutes.remainder(60))})';
}

String _twoDigits(int n) {
  if (n >= 10) return '$n';
  return '0$n';
}

main() {
  final date = DateTime.parse('2025-01-01 00:00:00');
  final res = date.add(Duration(days: 1)).toString();
  print(res);
}
