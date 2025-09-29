import 'package:assistant/helper/db_helper.dart';

import '../../helper/image/image_helper.dart';
import '../../helper/log/log_util.dart';
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
      sourceHeight integer, -- 截图来源的窗口高度
      createdOn integer, -- 创建时间
      updatedOn integer -- 更新时间
    );
  ''';
}

final Map<String, PicRecord> picRecordMap = {};

int prevWindowHeight = 0;

/// 对截图进行缩放处理
/// [picRecord] 截图记录对象
void resizePicRecord(int windowHeight) async {
  if (prevWindowHeight == windowHeight) {
    return;
  }

  // 更新窗口高度
  prevWindowHeight = windowHeight;

  appLog.info('重新调整截图大小，当前窗口高度: $windowHeight');

  // 批量缩放图片
  for (final picRecord in picRecordMap.values) {
    // 图片为空或窗口高度与截图来源高度相同，无需缩放
    if (picRecord.mat == null ||
        picRecord.sourceHeight == 0 ||
        windowHeight == picRecord.sourceHeight) {
      continue;
    }

    picRecord.setMat();

    picRecord.mat =
        resize(picRecord.mat!, windowHeight / picRecord.sourceHeight);
  }
}

/// 保存截图
Future<bool> savePicRecord(PicRecord picRecord) async {
  picRecord.setMat();
  if (picRecord.id != null) {
    await db.update(PicRecordDb.tableName, picRecord.toJson(),
        where: 'id = ?', whereArgs: [picRecord.id]);
    return true;
  } else {
    // 检查是否出现键冲突
    final dbRecord = await db.query(PicRecordDb.tableName,
        where: 'key = ?', whereArgs: [picRecord.key]);
    if (dbRecord.isNotEmpty) {
      return false;
    }
    picRecord.id = await db.insert(PicRecordDb.tableName, picRecord.toJson());
    return true;
  }
}

/// 加载所有截图
Future<List<PicRecord>> loadAllPicRecord() async {
  final List<Map<String, Object?>> picRecordList =
      await db.query(PicRecordDb.tableName);
  return picRecordList.map((e) => PicRecord.fromJson(e)).toList();
}

/// 删除截图
Future<void> deletePickRecord(PicRecord picRecord) async {
  if (picRecord.id == null) {
    return;
  }
  await db.delete(
    PicRecordDb.tableName,
    where: 'id = ?',
    whereArgs: [picRecord.id],
  );
}
