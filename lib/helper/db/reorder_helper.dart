import '../date_utils.dart';
import '../db_helper.dart';

/// 更新排序
Future<void> reorderByMapDb(
  Map<int, int> map,
  String tableName, {
  bool syncOperation = false,
}) async {
  map.forEach((key, value) async {
    // 如果是同步操作，就不更改更新日期（需要两端同时排序，未来再考虑）
    Map<String, Object?> values = syncOperation
        ? {
            'orderNum': value,
          }
        : {
            'orderNum': value,
            'updatedAt': currentMillis(),
          };
    await db.update(
      tableName,
      values,
      where: 'id = ?',
      whereArgs: [key],
    );
  });
}
