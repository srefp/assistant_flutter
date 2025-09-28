import 'dart:io';

import 'package:assistant/main.dart';
import 'package:assistant/helper/path_manage.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqlite_api.dart' as sqlite_api;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

import 'db_sql.dart';

late sqlite_api.Database db;

/// 初始化数据库
Future<void> initDb() async {
  db = await DbHelper.getDb();
}

/// `[系统文档路径]/Assistant` 作为程序数据路径
Future<String> getStoragePath() async =>
    path.join((await getDocumentDir()).path, 'Assistant');

class DbHelper {
  static sqlite_api.Database? _dbOnAndroid;
  static sqlite_api.Database? _dbOnWindows;
  static const int _version = 8;

  /// 获取数据库
  static Future<sqlite_api.Database> getDb() async {
    if (Platform.isWindows) {
      return await getDbOnWindows();
    } else if (Platform.isAndroid) {
      return await getDbOnAndroid();
    } else {
      throw UnimplementedError('不支持此类型的操作系统！');
    }
  }

  /// 在android平台初始化数据库
  static Future<sqlite_api.Database> getDbOnAndroid() async {
    if (_dbOnAndroid != null) {
      return _dbOnAndroid!;
    }
    try {
      String databasesPath = await sqflite.getDatabasesPath();
      String dbPathOnAndroid = path.join(databasesPath, '$appId.db');
      _dbOnAndroid = await sqflite.openDatabase(
        dbPathOnAndroid,
        version: _version,
        onCreate: (db, version) async {
          // 执行数据库创建操作
          await initWithDdl(db);
        },
        onUpgrade: onUpgrade,
      );
    } catch (e) {
      throw Exception('数据库初始化失败！');
    }
    return _dbOnAndroid!;
  }

  /// 在windows平台初始化数据库
  static Future<sqlite_api.Database> getDbOnWindows() async {
    if (_dbOnWindows != null) {
      return _dbOnWindows!;
    }
    sqflite_ffi.sqfliteFfiInit();
    try {
      final databasesPath = await getStoragePath();
      String dbPathOnWindows = path.join(databasesPath, '$appId.db');
      _dbOnWindows = await sqflite_ffi.databaseFactoryFfi.openDatabase(
        dbPathOnWindows,
        options: sqlite_api.OpenDatabaseOptions(
          singleInstance: false,
          version: _version,
          onCreate: (db, version) async {
            // 执行数据库创建操作
            await initWithDdl(db);
          },
          onUpgrade: onUpgrade,
        ),
      );
    } catch (e) {
      print('Error opening database: $e');
    }
    return _dbOnWindows!;
  }
}

String convertV2(String input) {
  // 按行拆分输入
  List<String> lines = input.split('\n');
  List<String> convertedLines = [];

  final nameRegExp = RegExp(r',?\s*name:\s*"([^"]+)"');
  final scriptRegExp = RegExp(r',?\s*script:\s*"([^"]+)"');

  for (var line in lines) {
    String name = '';
    String script = '';

    final nameMatch = nameRegExp.firstMatch(line);
    if (nameMatch != null && nameMatch.groupCount >= 1) {
      name = nameMatch.group(1)!;
    }

    final scriptMatch = scriptRegExp.firstMatch(line);
    if (scriptMatch != null && scriptMatch.groupCount >= 1) {
      script = scriptMatch.group(1)!;
    }

    if (name.isNotEmpty && script.isNotEmpty) {
      // 构建替换后的字符串
      String newPart = '$name { $script }';
      String convertedLine = line
          .replaceFirst(nameRegExp, '')
          .replaceFirst(scriptRegExp, '')
          .replaceFirst(RegExp(r'\s+'), ' ')
          .trim();
      convertedLine = convertedLine.replaceFirst(RegExp(r'^\s*'), '$newPart ');
      convertedLines.add(convertedLine);
    } else {
      // 若没有有效的 name 和 script，直接保留原始行
      convertedLines.add(line);
    }
  }

  // 将转换后的行用换行符连接起来
  return convertedLines.join('\n');
}
