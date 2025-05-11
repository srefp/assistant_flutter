import 'config_storage.dart';

class ScriptConfig with ConfigStorage {
  static ScriptConfig to = ScriptConfig();
  static const keySelectedScriptType = 'selectedScriptType';
  static const keySelectedScript = 'selectedScript';
}
