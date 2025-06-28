class MacroDb {
  static const tableName = "macro";

  static const ddl = '''
    create table if not exists $tableName (
      id integer primary key autoincrement, -- 主键
      name text, -- 名称
      script text, -- 脚本
      triggerType integer, -- 触发类型
      status integer, -- 状态
      createdOn integer, -- 创建时间
      updatedOn integer -- 更新时间
    );
  ''';
}
