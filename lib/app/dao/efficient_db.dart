import '../../helper/db_helper.dart';
import '../module/efficient/efficient.dart';

class EfficientDb {
  static const tableName = "efficient";

  static const ddl = '''
    create table if not exists $tableName (
      id integer primary key autoincrement, -- 主键
      uniqueId text, -- 唯一ID
      name text, -- 名称
      comment text, -- 备注
      script text, -- 脚本
      status integer, -- 状态
      createdOn integer, -- 创建时间
      updatedOn integer -- 更新时间
    );
  ''';
}

Future<List<Efficient>> loadAllEfficient() async {
  final List<Map<String, Object?>> scriptNameList =
      await db.query(EfficientDb.tableName);
  return scriptNameList.map((e) => Efficient.fromJson(e)).toList();
}

/// 删除宏
Future<void> deleteEfficientById(int id) async {
  await db.delete(EfficientDb.tableName, where: 'id = ?', whereArgs: [id]);
}

Future<void> updateEfficient(Efficient efficient) {
  efficient.updatedOn = DateTime.now().millisecondsSinceEpoch;
  return db.update(
    EfficientDb.tableName,
    efficient.toJson(),
    where: 'id = ?',
    whereArgs: [efficient.id],
  );
}

Future<void> addEfficient(Efficient efficient) {
  return db.insert(
    EfficientDb.tableName,
    efficient.toJson(),
  );
}
