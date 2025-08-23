import 'package:assistant/db/efficient_db.dart';
import 'package:assistant/db/macro_db.dart';
import 'package:assistant/db/pic_record_db.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:ulid/ulid.dart';

import '../db/tp_route_db.dart';
import 'db_helper.dart';

Future<void> initWithDdl(sqflite.Database db) async {
// 执行数据库创建操作
  await db.execute(TpRouteDb.ddl);
  await db.execute(PicRecordDb.ddl);
  await db.execute(MacroDb.ddl);
  await db.execute(EfficientDb.ddl);
}

/// 数据库升级回调
void onUpgrade(db, oldVersion, newVersion) async {
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
    final hasVideoUrl = columns.any((col) => col['name'] == 'videoUrl');

    if (!hasVideoUrl) {
      // 不存在则添加列（TEXT类型，允许NULL）
      await db.database.rawUpdate('''
                    ALTER TABLE ${TpRouteDb.tableName} ADD COLUMN videoUrl TEXT
                  ''');
    }
  }
  if (oldVersion < 5 && newVersion >= 5) {
    await db.execute(MacroDb.ddl);
  }
  if (oldVersion < 6 && newVersion >= 6) {
    // 查询表结构获取现有列
    final routeColumns =
        await db.rawQuery('PRAGMA table_info(${TpRouteDb.tableName})');
    final routeHasUniqueId =
        routeColumns.any((col) => col['name'] == 'uniqueId');

    if (!routeHasUniqueId) {
      await db.database.rawUpdate('''
                    ALTER TABLE ${TpRouteDb.tableName} ADD COLUMN uniqueId TEXT
                  ''');
    }

    final routeIds = await db.query(TpRouteDb.tableName,
        columns: ['id']).then((value) => value.map((e) => e['id']).toList());
    for (final id in routeIds) {
      await db.update(TpRouteDb.tableName, {'uniqueId': Ulid().toString()},
          where: 'uniqueId is null and id = ?', whereArgs: [id]);
    }

    final macroColumns =
        await db.rawQuery('PRAGMA table_info(${MacroDb.tableName})');
    final macroHasUniqueId =
        macroColumns.any((col) => col['name'] == 'uniqueId');

    if (!macroHasUniqueId) {
      await db.database.rawUpdate('''
                    ALTER TABLE ${MacroDb.tableName} ADD COLUMN uniqueId TEXT
                  ''');
    }

    final macroIds = await db.query(MacroDb.tableName,
        columns: ['id']).then((value) => value.map((e) => e['id']).toList());
    for (final id in macroIds) {
      await db.update(MacroDb.tableName, {'uniqueId': Ulid().toString()},
          where: 'uniqueId is null and id = ?', whereArgs: [id]);
    }
  }
  if (oldVersion < 7 && newVersion >= 7) {
    await db.execute(EfficientDb.ddl);

    // 查询表结构获取现有列
    final picRecordColumns =
        await db.rawQuery('PRAGMA table_info(${PicRecordDb.tableName})');

    // 添加width列
    final picRecordHasWidth =
        picRecordColumns.any((col) => col['name'] == 'width');

    if (!picRecordHasWidth) {
      await db.database.rawUpdate('''
                    ALTER TABLE ${PicRecordDb.tableName} ADD COLUMN width INTEGER
                  ''');
    }

    // 添加height列
    final picRecordHasHeight =
        picRecordColumns.any((col) => col['name'] == 'height');

    if (!picRecordHasHeight) {
      await db.database.rawUpdate('''
                    ALTER TABLE ${PicRecordDb.tableName} ADD COLUMN height INTEGER
                  ''');
    }

    // 添加key列
    final picRecordHasKey = picRecordColumns.any((col) => col['name'] == 'key');

    if (!picRecordHasKey) {
      await db.database.rawUpdate('''
                    ALTER TABLE ${PicRecordDb.tableName} ADD COLUMN key TEXT
                  ''');
    }

    // 添加comment列
    final picRecordHasComment =
        picRecordColumns.any((col) => col['name'] == 'comment');

    if (!picRecordHasComment) {
      await db.database.rawUpdate('''
                    ALTER TABLE ${PicRecordDb.tableName} ADD COLUMN comment TEXT
                  ''');
    }
  }
}
