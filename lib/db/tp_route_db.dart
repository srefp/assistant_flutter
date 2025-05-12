import 'package:flutter/services.dart';

class TpRouteDb {
  static const tableName = "route";

  static const ddl = '''
    create table if not exists route (
      id integer primary key autoincrement, -- 主键
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
