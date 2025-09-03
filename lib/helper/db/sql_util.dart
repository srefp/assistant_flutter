import 'package:assistant/app/windows_app.dart';
import 'package:assistant/helper/extensions/string_extension.dart';

/// 查询表信息的sql
const String selectTableNameSql = '''
select cols.column_name,    
       cols.udt_name,     
       cols.is_nullable,
       cols.is_identity,
       cols.column_default,     
       pgd.description as column_comment
from information_schema.columns cols
    left join pg_catalog.pg_description pgd 
        on pgd.objsubid = cols.ordinal_position
               and pgd.objoid = (select c.oid				  
                                 from pg_catalog.pg_class c				  
                                 where c.relname = cols.table_name)
where table_name = @tableName
  and table_schema = 'public';
''';

/// 生成代码
void genCode(String tableName, String templateFilePath, String targetDir) {
  // final info = getInfo(tableName);
}

getInfo(String tableName) {
  return executeQuery(selectTableNameSql, tableName);
}

executeQuery(String sql, String tableName) async {
  final connection = WindowsApp.codeGenModel.connection;
  List<GenColumn> columns = [];

  final rows = await connection.execute(sql, parameters: [tableName]);
  for (var row in rows) {
    // columns.add(GenColumn(
    //   columnName: row[0],
    //   columnType: row[1],
    //   identity: row[3],
    //   columnDefault: row[4],
    //   nullable: row[2],
    //   columnComment: row[5],
    // ));
  }
}

class GenTable {
  final String tableName;
  final String comment;
  final String apiName;
  final String tableCamelName;
  final String tableCamelBigName;
  final List<GenColumn> columns;

  GenTable({
    required this.tableName,
    required this.columns,
  })  : tableCamelName = tableName.underLineToCamel,
        tableCamelBigName = tableName.underLineToCamel.firstToUpper,
        comment = getComment(tableName),
        apiName = getApi(tableName);
}

class GenColumn {
  final String columnName;
  final String columnType;
  final String identity;
  final String? columnDefault;
  final String? columnComment;
  final String columnCamelName;
  final String columnCamelBigName;
  final bool nullable;
  final bool pk;
  final String sqlStrRes;

  GenColumn({
    required this.columnName,
    required this.columnType,
    required this.identity,
    this.columnDefault,
    required String nullable,
    required this.columnComment,
  })  : columnCamelName = columnName.underLineToCamel,
        columnCamelBigName = columnName.underLineToCamel.firstToUpper,
        pk = identity == 'YES',
        nullable = nullable == 'YES',
        sqlStrRes = columnType == 'varchar' || columnType == 'timestamptz'
            ? 'getSqlStr(${columnName.underLineToCamel})'
            : columnName.underLineToCamel;

  @override
  String toString() {
    return 'GenColumn{columnName: $columnName, columnType: $columnType, nullable: $nullable, identity: $identity, columnDefault: $columnDefault, columnComment: $columnComment}';
  }
}

/// 表名转注释
getComment(String tableName) {
  return tableName.replaceAll('_', ' ');
}

/// 表名转api名
getApi(String tableName) {
  return tableName.replaceAll('_', "");
}
