import 'package:get_storage/get_storage.dart';

mixin ConfigStorage {
  GetStorage get box => _box;
  static final _box = GetStorage();

  /// 实例方法 保存key value
  void save(String key, dynamic value) => staticSave(key, value);

  /// 静态方法 保存key value
  static void staticSave(String key, dynamic value) => _box.write(key, value);
}
