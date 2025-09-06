import 'package:path/path.dart';

import 'config_storage.dart';

class AppConfig with ConfigStorage {
  static AppConfig to = AppConfig();
  static const keyDirPath = 'dirPath';
  static const keyCurrentApp = 'currentApp';
  static const keyFirstInstall = 'firstInstall';
  static const keyEulaNotificationDisabled = 'eulaNotificationDisabled';
  static const keyToWindowAfterStarted = 'toWindowAfterStarted';

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
}
