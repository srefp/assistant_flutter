import 'package:assistant/auto_gui/system_control.dart';
import 'package:flutter/services.dart';
import 'package:ulid/ulid.dart';

import '../model/tp_route.dart';
import '../util/db_helper.dart';

class TpRouteDb {
  static const tableName = "route";

  static const ddl = '''
    create table if not exists route (
      id integer primary key autoincrement, -- 主键
      uniqueId text, -- 唯一ID
      scriptName text, -- 脚本名称
      scriptType text, -- 脚本类型
      content text, -- 路线内容
      ratio text, -- 屏幕比例
      videoUrl text, -- 视频地址
      remark text, -- 备注
      author text, -- 作者
      orderNum integer, -- 排序
      createdOn integer, -- 创建时间
      updatedOn integer -- 更新时间
    )
  ''';

  static get initRouteSql async {
    // 转义单引号（将单个'转义为两个''）
    final route6 = await getContent('assets/route/-6.lua');
    final routeMeat = await getContent('assets/route/肉 - 兽肉.lua');
    return '''
    insert into route (scriptName, scriptType, content, ratio, remark, author, orderNum, createdOn, updatedOn) values
    ('-6', '自动传', '$route6', '16:9', '渊下宫第一个点位需要先运行预加载', '瓜老师', 1, 1677609600, 1677609600),
    ('肉 - 兽肉', '自动传', '$routeMeat', '16:9', '', 'srefp', 2, 1677609600, 1677609600);
    ''';
  }

  static Future<String> getContent(String name) async {
    String content = await rootBundle.loadString(name);

    // 转义单引号（将单个'转义为两个''）
    content = content.replaceAll("'", "''");
    return content;
  }
}

Future<List<String>> loadScriptsByType(String selectedScriptType) async {
  // 加载脚本类别下的所有脚本名称
  final List<Map<String, Object?>> scriptNameList = await db.query(
      TpRouteDb.tableName,
      columns: ['scriptName'],
      where: 'scriptType = ?',
      whereArgs: [selectedScriptType]);
  return scriptNameList.map((e) => e['scriptName'] as String).toList();
}

/// 根据名称和类型加载脚本
Future<TpRoute> loadScriptByNameAndType(
    String scriptType, String scriptName) async {
  final List<Map<String, Object?>> scriptNameList = await db.query(
      TpRouteDb.tableName,
      where: 'scriptName = ? and scriptType = ?',
      whereArgs: [scriptName, scriptType]);
  return TpRoute.fromJson(scriptNameList.first);
}

/// 删除脚本
Future<void> deleteScriptByNameAndType(
    String scriptType, String scriptName) async {
  await db.delete(TpRouteDb.tableName,
      where: 'scriptName = ? and scriptType = ?',
      whereArgs: [scriptName, scriptType]);
}

Future<void> updateScript(
  String selectedScriptType,
  String selectedScriptName,
  String content,
) {
  return db.update(
    TpRouteDb.tableName,
    {
      'content': content,
      'updatedOn': DateTime.now().millisecondsSinceEpoch,
    },
    where: 'scriptName = ? and scriptType = ?',
    whereArgs: [selectedScriptName, selectedScriptType],
  );
}

Future<void> addScript(
  String scriptType,
  String scriptName,
  String content,
) {
  return db.insert(
    TpRouteDb.tableName,
    TpRoute(
      uniqueId: Ulid().toString(),
      scriptName: scriptName,
      scriptType: scriptType,
      content: content,
      ratio: SystemControl.ratio.name,
      remark: '',
      author: 'srefp',
      createdOn: DateTime.now().millisecondsSinceEpoch,
      updatedOn: DateTime.now().millisecondsSinceEpoch,
    ).toJson(),
  );
}
