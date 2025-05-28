import 'package:get_storage/get_storage.dart';

late final GetStorage box;

mixin ConfigStorage {

  /// 实例方法 保存key value
  void save(String key, dynamic value) => staticSave(key, value);

  /// 静态方法 保存key value
  static void staticSave(String key, dynamic value) => box.write(key, value);
}
