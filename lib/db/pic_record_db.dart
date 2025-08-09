import 'package:assistant/model/pic_record.dart';
import 'package:assistant/util/db_helper.dart';

import '../util/date_utils.dart';
import 'package:opencv_dart/opencv.dart' as cv;

class PicRecordDb {
  static const tableName = "pic_record";

  static const ddl = '''
    create table if not exists $tableName (
      id integer primary key autoincrement, -- 主键
      picName text, -- 图片名称
      image text, -- 图片路径
      width integer, -- 宽度
      height integer, -- 高度
      createdOn integer, -- 创建时间
      updatedOn integer -- 更新时间
    );
  ''';
}

final Map<String, PicRecord> picRecordMap = {};

/// 保存截图
Future<void> savePickRecord(String picName, int width, int height, String image, cv.Mat mat) async {
  final picRecord = await loadPicRecord(picName);
  var newPicRecord = PicRecord(picName: picName, width: width, height: height, image: image);
  newPicRecord.mat = mat;
  picRecordMap[picName] = newPicRecord;

  if (picRecord != null) {
    newPicRecord.id = picRecord.id;
    newPicRecord.createdOn = picRecord.createdOn;
    await db.update(
        PicRecordDb.tableName,
        {
          'image': image,
          'updatedOn': currentMillis(),
        },
        where: 'id = ?',
        whereArgs: [picRecord.id]);
  } else {
    await db.insert(PicRecordDb.tableName, newPicRecord.toJson());
  }
}

/// 加载所有截图
Future<List<PicRecord>> loadAllPicRecord() async {
  final List<Map<String, Object?>> picRecordList =
      await db.query(PicRecordDb.tableName);
  return picRecordList.map((e) => PicRecord.fromJson(e)).toList();
}

/// 查询截图
Future<PicRecord?> loadPicRecord(String picName) async {
  final List<Map<String, Object?>> picRecordList = await db
      .query(PicRecordDb.tableName, where: 'picName = ?', whereArgs: [picName]);
  if (picRecordList.isEmpty) {
    return null;
  }
  return PicRecord.fromJson(picRecordList.first);
}
