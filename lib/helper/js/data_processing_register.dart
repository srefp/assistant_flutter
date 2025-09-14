import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:assistant/component/dialog.dart';
import 'package:assistant/helper/db/sql_util.dart';
import 'package:assistant/helper/file_utils.dart';
import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart';
import 'package:time_plus/time_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

import 'js_executor.dart';

void registerDataProcessing() {
  // 日期处理
  jsRuntime.onMessage('now', now);
  jsRuntime.onMessage(
      'plusMillis', (params) => plus(params, millis: params[1]));
  jsRuntime.onMessage(
      'plusSeconds', (params) => plus(params, seconds: params[1]));
  jsRuntime.onMessage(
      'plusMinutes', (params) => plus(params, minutes: params[1]));
  jsRuntime.onMessage('plusHours', (params) => plus(params, hours: params[1]));
  jsRuntime.onMessage('plusDays', (params) => plus(params, days: params[1]));
  jsRuntime.onMessage('plusWeeks', (params) => plus(params, weeks: params[1]));
  jsRuntime.onMessage(
      'plusMonths', (params) => plus(params, months: params[1]));
  jsRuntime.onMessage('plusYears', (params) => plus(params, years: params[1]));

  // 代码生成
  jsRuntime.onMessage('getInfo', getInfo);
  jsRuntime.onMessage('gen', gen);
  jsRuntime.onMessage('getSqlStr', getSqlStr);

  // 执行insert sql
  jsRuntime.onMessage('executeSql', executeSql);

  // 随机数
  jsRuntime.onMessage('randInt', randInt);
  jsRuntime.onMessage('randDouble', randDouble);
}

String now(params) {
  return _formatDateTimeWithOffset(DateTime.now());
}

String getSqlStr(params) {
  return params[0] == null ? "null" : "'${params[0]}'";
}

executeSql(params) async {
  print('insert: ${params[0]}');
  final res = await executeInsert(params[0]);
  print('res: $res');
  return res;
}

int randInt(params) {
  return params[0] + Random().nextInt(params[1] - params[0]);
}

double randDouble(params) {
  int precision = params.length > 2 ? params[2] : 2;
  var res = params[0] + Random().nextDouble() * (params[1] - params[0]);
  return double.parse(res.toStringAsFixed(precision));
}

Future<Map<String, dynamic>> getInfo(params) async {
  return await executeQuery(selectTableNameSql, params[0]);
}

void gen(params) async {
  try {
    final templateFilePath = params[1];
    final targetDir = params[2];

    final info = await getInfo(params);

    genByInfo(info, templateFilePath, targetDir);
  } catch (e) {
    dialog(title: '错误', content: e.toString());
  }
}

void genByInfo(
    Map<String, dynamic> info, String templateFilePath, String targetDir) {
  var templateFileName = basename(templateFilePath);
  var targetFileName = convertString(source: templateFileName, model: info);
  final targetFilePath = joinPath(targetDir, targetFileName);

  var templateContent = File(templateFilePath).readAsStringSync();
  var targetContent = convertString(source: templateContent, model: info);
  var file = File(targetFilePath);
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }
  file.writeAsStringSync(targetContent);
}

/// 将字符串模板转换为字符串
String convertString({
  required String source,
  required Map<String, dynamic> model,
}) {
  final template = Template(source, lenient: true, htmlEscapeValues: false);
  return template.renderString(model);
}

String plus(
  params, {
  int? millis,
  int? seconds,
  int? minutes,
  int? hours,
  int? days,
  int? weeks,
  int? months,
  int? years,
}) {
  DateTime dateTime = _parseDateTimeWithOffset(params[0]);
  if (millis != null) {
    dateTime = dateTime.addMilliseconds(millis);
  }
  if (seconds != null) {
    dateTime = dateTime.addSeconds(seconds);
  }
  if (minutes != null) {
    dateTime = dateTime.addMinutes(minutes);
  }
  if (hours != null) {
    dateTime = dateTime.addHours(hours);
  }
  if (days != null) {
    dateTime = dateTime.addDays(days);
  }
  if (weeks != null) {
    dateTime = dateTime.addWeeks(weeks);
  }
  if (months != null) {
    dateTime = dateTime.addMonths(months);
  }
  if (years != null) {
    dateTime = dateTime.addYears(years);
  }
  return _formatDateTimeWithOffset(dateTime);
}

DateTime _parseDateTimeWithOffset(String dateStr) {
  // 将空格替换为T，并补全时区格式
  final isoString = dateStr.replaceFirst(' ', 'T');
  return DateTime.parse(isoString);
}

String _formatDateTimeWithOffset(DateTime date) {
  tz.initializeTimeZones();
  var location = tz.getLocation('Asia/Shanghai');
  tz.setLocalLocation(location);
  var offsetDateTime = tz.TZDateTime.from(date, location);

  return '${offsetDateTime.toString().substring(0, 10)} '
      '${offsetDateTime.hour.toString().padLeft(2, '0')}:'
      '${offsetDateTime.minute.toString().padLeft(2, '0')}:'
      '${offsetDateTime.second.toString().padLeft(2, '0')}'
      '+08';
}
