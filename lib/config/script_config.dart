import 'config_storage.dart';

class ScriptConfig with ConfigStorage {
  static ScriptConfig to = ScriptConfig();
  static const keySelectedDir = 'selectedDir';
  static const keySelectedFile = 'selectedFile';
}
