import 'package:assistant/model/macro.dart';

import '../util/db_helper.dart';

class MacroDb {
  static const tableName = "macro";

  static const ddl = '''
    create table if not exists $tableName (
      id integer primary key autoincrement, -- 主键
      uniqueId text, -- 唯一ID
      name text, -- 名称
      comment text, -- 备注
      script text, -- 脚本
      triggerType integer, -- 触发类型
      triggerKey text, -- 触发键
      processName text, -- 进程名称
      status integer, -- 状态
      createdOn integer, -- 创建时间
      updatedOn integer -- 更新时间
    );
  ''';
}

Future<List<Macro>> loadAllMacro() async {
  final List<Map<String, Object?>> scriptNameList = await db.query(
      MacroDb.tableName);
  return scriptNameList.map((e) => Macro.fromJson(e)).toList();
}

/// 删除宏
Future<void> deleteMacroById(int id) async {
  await db.delete(MacroDb.tableName,
      where: 'id = ?',
      whereArgs: [id]);
}

Future<void> updateMacro(Macro macro) {
  macro.updatedOn = DateTime.now().millisecondsSinceEpoch;
  return db.update(
    MacroDb.tableName,
    macro.toJson(),
    where: 'id = ?',
    whereArgs: [macro.id],
  );
}

Future<void> addMacro(Macro macro) {
  return db.insert(
    MacroDb.tableName,
    macro.toJson(),
  );
}

