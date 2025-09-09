import 'package:assistant/helper/db_helper.dart';

import '../module/pic/pic_record.dart';

class PicRecordDb {
  static const tableName = "pic_record";

  static const ddl = '''
    create table if not exists $tableName (
      id integer primary key autoincrement, -- 主键
      picName text, -- 图片名称
      key text, -- 图片key
      comment text, -- 图片注释
      image text, -- 图片的base64编码
      width integer, -- 宽度
      height integer, -- 高度
      createdOn integer, -- 创建时间
      updatedOn integer -- 更新时间
    );
  ''';
}

final Map<String, PicRecord> picRecordMap = {};

/// 保存截图
Future<void> savePickRecord(PicRecord picRecord) async {
  picRecord.setMat();
  final picRecordInDb = await loadPicRecord(picRecord.key);
  picRecordMap[picRecord.key] = picRecord;

  if (picRecordInDb != null) {
    picRecord.id = picRecordInDb.id;
    picRecord.createdOn = picRecordInDb.createdOn;
    await db.update(PicRecordDb.tableName, picRecord.toJson(),
        where: 'id = ?', whereArgs: [picRecord.id]);
  } else {
    await db.insert(PicRecordDb.tableName, picRecord.toJson());
  }
}

/// 加载所有截图
Future<List<PicRecord>> loadAllPicRecord() async {
  final List<Map<String, Object?>> picRecordList =
      await db.query(PicRecordDb.tableName);
  return picRecordList.map((e) => PicRecord.fromJson(e)).toList();
}

/// 查询截图
Future<PicRecord?> loadPicRecord(String key) async {
  final List<Map<String, Object?>> picRecordList =
      await db.query(PicRecordDb.tableName, where: 'key = ?', whereArgs: [key]);
  if (picRecordList.isEmpty) {
    return null;
  }
  return PicRecord.fromJson(picRecordList.first);
}

/// 删除截图
Future<void> deletePickRecord(PicRecord picRecord) async {
  await db.delete(
    PicRecordDb.tableName,
    where: 'id = ?',
    whereArgs: [picRecord.id],
  );
}
