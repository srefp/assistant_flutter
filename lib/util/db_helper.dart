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

/// `[系统文档路径]/Efficient` 作为程序数据路径
Future<String> getDataPath() async =>
    path.join((await getDocumentDir()).path, 'Assistant');

class DbHelper {
  static sqlite_api.Database? _dbOnWindows;
  static const int _version = 1;

  /// 在windows平台初始化数据库
  static Future<sqlite_api.Database> getDbOnWindows() async {
    if (_dbOnWindows != null) {
      return _dbOnWindows!;
    }
    sqflite_ffi.sqfliteFfiInit();
    try {
      final databasesPath = await getDataPath();
      String dbPathOnWindows = path.join(databasesPath, 'assistant.db');
      _dbOnWindows = await sqflite_ffi.databaseFactoryFfi.openDatabase(
        dbPathOnWindows,
        options: sqlite_api.OpenDatabaseOptions(
          singleInstance: false,
          version: _version,
          onCreate: (db, version) async {
            // 执行数据库创建操作
            await db.execute(TpRouteDb.ddl);
            await db.execute(await TpRouteDb.initRouteSql);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2 && newVersion >= 2) {
              // 执行版本2的升级操作
            }
            if (oldVersion < 3 && newVersion >= 3) {
              // 执行版本3的升级操作
            }
          }
        ),
      );
    } catch (_) {}
    return _dbOnWindows!;
  }
}
