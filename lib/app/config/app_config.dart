import 'package:assistant/constant/constant.dart';
import 'package:assistant/constant/script_engine.dart';
import 'package:path/path.dart';

import 'config_storage.dart';

class AppConfig with ConfigStorage {
  static AppConfig to = AppConfig();
  static const keyDirPath = 'dirPath';
  static const keyCurrentApp = 'currentApp';
  static const keyFirstInstall = 'firstInstall';
  static const keyEulaNotificationDisabled = 'eulaNotificationDisabled';
  static const keyToWindowAfterStarted = 'toWindowAfterStarted';
  static const keyBackgroundKeyMouse = 'backgroundKeyMouse';
  static const keyStartWhenRunScript = 'startWhenRunScript';
  static const keyAllowImportScript = 'allowImportScript';
  static const keyDefaultScriptEngine = 'defaultScriptEngine';

  String getDirPath() =>
      box.read(keyDirPath) ?? join('C:', 'Program Files', 'Assistant');

  String getExePath() => join(getDirPath(), 'assistant.exe');

  /// 是否是第一次安装
  bool get firstInstall => box.read(keyFirstInstall) ?? true;

  /// 是否提醒
  bool getEulaNotificationDisabled() =>
      box.read(keyEulaNotificationDisabled) ?? false;

  /// 是否启动后自动跳转到窗口
  bool getToWindowAfterStarted() => box.read(keyToWindowAfterStarted) ?? true;

  /// 是否后台键鼠操作
  bool isBackgroundKeyMouse() => box.read(keyBackgroundKeyMouse) ?? false;

  /// 是否运行脚本时自动启动
  bool isStartWhenRunScript() => box.read(keyStartWhenRunScript) ?? true;

  /// 是否允许引入外部脚本
  bool isAllowImportScript() => box.read(keyAllowImportScript) ?? false;

  /// 默认脚本引擎
  ScriptEngine getDefaultScriptEngine() =>
      EnumUtil.fromCode<ScriptEngine>(
          box.read(keyDefaultScriptEngine) ?? ScriptEngine.js.code,
          ScriptEngine.values);
}
