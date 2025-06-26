import 'package:assistant/db/pic_record_db.dart';
import 'package:assistant/main.dart';
import 'package:assistant/util/path_manage.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqlite_api.dart' as sqlite_api;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

import '../db/tp_route_db.dart';

late sqlite_api.Database db;

/// 初始化数据库
Future<void> initWindowsDb() async {
  db = await DbHelper.getDbOnWindows();
}

/// `[系统文档路径]/Assistant` 作为程序数据路径
Future<String> getStoragePath() async =>
    path.join((await getDocumentDir()).path, 'Assistant');

class DbHelper {
  static sqlite_api.Database? _dbOnWindows;
  static const int _version = 4;

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
              await db.execute(TpRouteDb.ddl);
              await db.execute(PicRecordDb.ddl);
              // await db.execute(await TpRouteDb.initRouteSql);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 2 && newVersion >= 2) {
                // 执行版本2的升级操作
                final List<Map<String, dynamic>> routes =
                    await db.query(TpRouteDb.tableName);
                for (final route in routes) {
                  String script = route['content'] as String;

                  script = convertV2(script);

                  // 更新脚本
                  db.update(TpRouteDb.tableName, {'content': script},
                      where: 'id = ?', whereArgs: [route['id']]);
                }
              }
              if (oldVersion < 3 && newVersion >= 3) {
                // 执行版本3的升级操作
                await db.execute(PicRecordDb.ddl);
              }
              if (oldVersion < 4 && newVersion >= 4) {
                // 查询表结构获取现有列
                final columns =
                    await db.rawQuery('PRAGMA table_info(${TpRouteDb.tableName})');
                final hasVideoUrl =
                    columns.any((col) => col['name'] == 'videoUrl');

                if (!hasVideoUrl) {
                  // 不存在则添加列（TEXT类型，允许NULL）
                  await db.database.rawUpdate('''
                    ALTER TABLE ${TpRouteDb.tableName} ADD COLUMN videoUrl TEXT
                  ''');
                }
              }
            }),
      );
    } catch (_) {}
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
