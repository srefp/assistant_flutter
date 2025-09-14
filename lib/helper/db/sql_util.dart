import 'package:assistant/app/windows_app.dart';
import 'package:assistant/helper/extensions/string_extension.dart';

/// 查询表信息的sql
const String selectTableNameSql = r'''
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
where table_name = $1
  and table_schema = 'public';
''';

Future<Map<String, dynamic>> executeQuery(String sql, String tableName) async {
  final connection = await WindowsApp.codeGenModel.connection;
  List<GenColumn> columns = [];

  final rows = await connection.execute(sql, parameters: [tableName]);
  for (var row in rows) {
    columns.add(GenColumn(
      columnName: row[0] as String,
      columnType: row[1] as String,
      identity: row[3] as String,
      columnDefault: row[4] as String?,
      nullable: row[2] as String,
      columnComment: row[5] as String?,
    ));
  }

  return GenTable(tableName: tableName, columns: columns).toMap();
}

Future<dynamic> executeInsert(String sql) async {
  final connection = await WindowsApp.codeGenModel.connection;
  final result = await connection.execute(sql);
  if (result.isNotEmpty) {
    return result.single.first;
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

  Map<String, dynamic> toMap() {
    return {
      'table_name': tableName,
      'tableName': tableCamelName,
      'TableName': tableCamelBigName,
      'comment': comment,
      'apiName': apiName,
      'columns': columns
          .map(
              (e) => e.toMap(notLast: columns.indexOf(e) != columns.length - 1))
          .toList(),
      'year': DateTime.now().year,
    };
  }
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

  toMap({required bool notLast}) {
    return {
      'column_name': columnName,
      'columnName': columnCamelName,
      'sqlStrRes': sqlStrRes,
      'pk': pk,
      'notPk': !pk,
      'nullable': nullable,
      'notNullable': !nullable,
      'columnType': columnType,
      'columnNull': nullable && columnDefault == null,
      'identity': identity,
      'columnDefault': columnDefault,
      'columnComment': columnComment,
      'notLast': notLast,
    };
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
