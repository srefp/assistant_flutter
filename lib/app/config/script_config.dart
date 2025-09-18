import 'config_storage.dart';

class ScriptConfig with ConfigStorage {
  static ScriptConfig to = ScriptConfig();
  static const keySelectedScriptType = 'selectedScriptType';
  static const keySelectedScript = 'selectedScript';
  static const keyVariable = 'variable';

  /// 读取预定义变量
  String getVariable() {
    return box.read(keyVariable) ?? '';
  }

}
