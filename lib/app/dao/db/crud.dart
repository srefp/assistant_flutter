import 'dart:io';

import '../../../helper/db_helper.dart';

/// 插入数据（注意，同一张表的两个新增操作同时发生时会产生Id冲突，必须要在for循环中使用await操作）
Future<void> insertJsonDb(Map<String, dynamic> json, String tableName) async {
  final map = await db.rawQuery('''
select max(orderNum) maxOrderNum, max(id) maxId from $tableName
''');
  int maxOrderNum = (map.first['maxOrderNum'] ?? 0) as int;
  int maxId = (map.first['maxId'] ?? 0) as int;
  json['orderNum'] = maxOrderNum + 1;
  json['id'] = maxId + 1;
  // 在windows平台上插入奇数id，在手机上插入偶数id
  if (Platform.isWindows) {
    while (json['id'] % 2 == 0) {
      json['id']++;
    }
  } else {
    while (json['id'] % 2 == 1) {
      json['id']++;
    }
  }
  await db.insert(tableName, json);
}

/// 插入数据（注意，同一张表的两个新增操作同时发生时会产生Id冲突，必须要在for循环中使用await操作）
Future<bool> insertDb(e, String tableName) async {
  final map = await db.rawQuery('''
select max(orderNum) maxOrderNum, max(id) maxId from $tableName
''');
  int maxOrderNum = (map.first['maxOrderNum'] ?? 0) as int;
  int maxId = (map.first['maxId'] ?? 0) as int;
  e.orderNum = maxOrderNum + 1;
  e.id = maxId + 1;
  // 在windows平台上插入奇数id，在手机上插入偶数id
  if (Platform.isWindows) {
    while (e.id % 2 == 0) {
      e.id++;
    }
  } else {
    while (e.id % 2 == 1) {
      e.id++;
    }
  }
  final id = await db.insert(
    tableName,
    e.toJson(),
  );
  return id != 0;
}

/// 全表查询
Future<List<Map<String, dynamic>>> queryDb(
  String tableName, {
  String? orderBy = 'orderNum desc',
  int deleted = 0,
  String? where,
}) async {
  return await db.query(
    tableName,
    where: where,
    orderBy: orderBy,
  );
}

/// 批量插入或更新数据
Future<List<Operation>> insertOrUpdateListDb(
    List<dynamic> list, String tableName) async {
  List<Operation> operationList = [];
  await Future.wait(list.map((e) => insertOrUpdateDb(e, tableName)
      .then((value) => operationList.add(value))));
  return operationList;
}

enum Operation {
  insert,
  update,
}

/// 插入或更新数据
Future<Operation> insertOrUpdateDb(
  Map<String, dynamic> e,
  String tableName,
) async {
  List<Map<String, dynamic>> data = await db
      .query(tableName, where: 'id = ?', whereArgs: [e['id'].toString()]);
  if (data.isEmpty) {
    await db.insert(tableName, e);
    return Operation.insert;
  } else {
    await db.update(tableName, e, where: 'id = ?', whereArgs: [e['id']]);
    return Operation.update;
  }
}

/// 物理删除
Future<int> physicalDeleteDb(int id, String tableName) async {
  return await db.delete(
    tableName,
    where: 'id = ?',
    whereArgs: [id],
  );
}
